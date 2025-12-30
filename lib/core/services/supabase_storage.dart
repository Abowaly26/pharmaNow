import 'dart:io';
import 'dart:developer';

import 'package:pharma_now/core/services/storage_service.dart';

import 'package:path/path.dart' as b;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService implements StorageService {
  static late Supabase _supabase;
  static bool _isInitialized = false;
  static const String _profileImagesBucket = 'Profile_images';
  static const String _medicinesImagesBucket = 'Medicines_images';
  static const String _paymentProofsBucket = 'Payment_proofs';
  static const String _supabaseUrl = 'https://jzvdrawjkkqbxvhpefhd.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6dmRyYXdqa2txYnh2aHBlZmhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxMTM4NTEsImV4cCI6MjA2MTY4OTg1MX0.M9LnQMmqCCtVsb4HoWkJLw6tnRFzCg4VJHYgb3mh8C8';

  static createBuckets(String bucketName) async {
    try {
      // Attempt to list buckets to check existence
      List<Bucket> buckets = [];
      try {
        buckets = await _supabase.client.storage.listBuckets();
      } catch (e) {
        // If we can't list buckets (e.g., RLS policy), we can't check existence.
        // We'll log a clear instruction and move on.
        log('Note: Skipping automatic check for bucket "$bucketName". Please ensure it exists and is PUBLIC in your Supabase Dashboard.',
            name: 'SupabaseStorageService');
        return;
      }

      bool isBucketExists = false;
      bool isPublic = false;

      for (var bucket in buckets) {
        if (bucket.id == bucketName) {
          isBucketExists = true;
          isPublic = bucket.public;
          break;
        }
      }

      if (!isBucketExists) {
        log('Attempting to create bucket: $bucketName',
            name: 'SupabaseStorageService');
        try {
          await _supabase.client.storage.createBucket(
            bucketName,
            const BucketOptions(public: true),
          );
          log('Successfully created bucket: $bucketName',
              name: 'SupabaseStorageService');
        } catch (e) {
          // If 403, it's expected if using anon key.
          log('Unable to create bucket "$bucketName" automatically (Permission Denied). This is normal for client-side keys. Please create it manually in the Supabase Dashboard and set it to PUBLIC.',
              name: 'SupabaseStorageService');
        }
      } else if (!isPublic) {
        log('Bucket "$bucketName" exists but is not public. Attempting to update...',
            name: 'SupabaseStorageService');
        try {
          await _supabase.client.storage.updateBucket(
            bucketName,
            const BucketOptions(public: true),
          );
        } catch (e) {
          log('Note: Could not update bucket public status (Permission Denied). Ensure "Public Bucket" is ON for "$bucketName" in Dashboard.',
              name: 'SupabaseStorageService');
        }
      }
    } catch (e) {
      log('Unexpected error in createBuckets check for "$bucketName": $e',
          name: 'SupabaseStorageService');
    }
  }

  static initSupabase() async {
    if (_isInitialized) return;
    try {
      log('Initializing Supabase at $_supabaseUrl',
          name: 'SupabaseStorageService');

      _supabase = await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );

      _isInitialized = true;
      log('Supabase initialized successfully', name: 'SupabaseStorageService');

      // Initialize buckets
      await _initializeBuckets();
    } catch (e) {
      log('Error initializing Supabase: $e', name: 'SupabaseStorageService');
      _isInitialized = false;
    }
  }

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      log('Supabase not initialized, attempting to initialize now...',
          name: 'SupabaseStorageService');
      await initSupabase();
    }
    if (!_isInitialized) {
      throw Exception(
          'Supabase failed to initialize. Please check your internet connection.');
    }
  }

  static Future<void> _initializeBuckets() async {
    try {
      await createBuckets(_profileImagesBucket);
      await createBuckets(_medicinesImagesBucket);
      await createBuckets(_paymentProofsBucket);
    } catch (e) {
      log('Error creating buckets: $e', name: 'SupabaseStorageService');
    }
  }

  @override
  Future<String> uploadFile(File file, String path) async {
    await _ensureInitialized();
    try {
      if (!file.existsSync()) {
        throw Exception('File does not exist at path: ${file.path}');
      }

      String fileName = b.basenameWithoutExtension(file.path);
      String extensionName = b.extension(file.path);
      String fullPath = path.isEmpty
          ? '$fileName$extensionName'
          : '$path/$fileName$extensionName';

      log('Uploading file to $_medicinesImagesBucket: $fullPath',
          name: 'SupabaseStorageService');

      final bytes = await file.readAsBytes();

      await _supabase.client.storage.from(_medicinesImagesBucket).uploadBinary(
            fullPath,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extensionName),
              upsert: true,
            ),
          );

      final String publicUrl = _supabase.client.storage
          .from(_medicinesImagesBucket)
          .getPublicUrl(fullPath);
      return publicUrl;
    } catch (e) {
      log('Error in uploadFile: $e', name: 'SupabaseStorageService');
      throw Exception('Upload failed: ${e.toString()}');
    }
  }

  Future<String> uploadPaymentProof(File file, String userId) async {
    await _ensureInitialized();
    try {
      if (!file.existsSync()) {
        throw Exception('File does not exist at path: ${file.path}');
      }

      final String extensionName = b.extension(file.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${timestamp}_proof$extensionName';
      final String uploadPath = '$userId/$fileName';

      log('Uploading payment proof to $_paymentProofsBucket: $uploadPath',
          name: 'SupabaseStorageService');

      final bytes = await file.readAsBytes();

      await _supabase.client.storage.from(_paymentProofsBucket).uploadBinary(
            uploadPath,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extensionName),
              upsert: true,
            ),
          );

      final String publicUrl = _supabase.client.storage
          .from(_paymentProofsBucket)
          .getPublicUrl(uploadPath);

      return publicUrl;
    } on SocketException catch (e) {
      log('Network error uploading payment proof: $e',
          name: 'SupabaseStorageService');
      throw Exception(
          'Network error: Failed to upload payment proof. Please check your connection.');
    } catch (e) {
      log('Error uploading payment proof: $e', name: 'SupabaseStorageService');
      throw Exception('Failed to upload payment proof: ${e.toString()}');
    }
  }

  /// Upload profile image for a user
  /// Returns the public URL of the uploaded image
  Future<String> uploadProfileImage(File file, String userId) async {
    await _ensureInitialized();
    try {
      if (!file.existsSync()) {
        throw Exception('File does not exist: ${file.path}');
      }

      final String extensionName = b.extension(file.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${userId}_$timestamp$extensionName';

      // Thoroughly delete all old profile images (root and folder) before uploading new one
      await deleteProfileImage(userId);

      final String uploadPath = '$userId/$fileName';

      log('Uploading profile image to $_profileImagesBucket: $uploadPath',
          name: 'SupabaseStorageService');

      final bytes = await file.readAsBytes();

      await _supabase.client.storage.from(_profileImagesBucket).uploadBinary(
            uploadPath,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extensionName),
              upsert: true,
            ),
          );

      final String publicUrl = _supabase.client.storage
          .from(_profileImagesBucket)
          .getPublicUrl(uploadPath);

      return publicUrl;
    } on SocketException catch (e) {
      log('Network error uploading profile image: $e',
          name: 'SupabaseStorageService');
      throw Exception(
          'Network error: Failed to connect to Supabase. Please check your internet connection.');
    } catch (e) {
      log('Error during profile image upload: $e',
          name: 'SupabaseStorageService');
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  /// Delete profile image for a user (thorough cleanup of root and folder)
  Future<void> deleteProfileImage(String userId) async {
    try {
      log('Starting thorough cleanup for user: $userId',
          name: 'SupabaseStorageService');

      List<String> filesToDelete = [];

      // 1. Check root for legacy files (named UID_timestamp.jpg)
      try {
        final List<FileObject> rootFiles =
            await _supabase.client.storage.from(_profileImagesBucket).list();
        final legacyFiles = rootFiles
            .where((f) => f.name.startsWith('${userId}_'))
            .map((f) => f.name)
            .toList();
        if (legacyFiles.isNotEmpty) {
          filesToDelete.addAll(legacyFiles);
          log('Found ${legacyFiles.length} legacy files in root',
              name: 'SupabaseStorageService');
        }
      } catch (e) {
        log('Error checking root for legacy files: $e',
            name: 'SupabaseStorageService');
      }

      // 2. Check user-specific folder (userId/...)
      try {
        final List<FileObject> folderFiles = await _supabase.client.storage
            .from(_profileImagesBucket)
            .list(path: userId);
        if (folderFiles.isNotEmpty) {
          final folderPaths =
              folderFiles.map((f) => '$userId/${f.name}').toList();
          filesToDelete.addAll(folderPaths);
          log('Found ${folderPaths.length} files in user folder',
              name: 'SupabaseStorageService');
        }
      } catch (e) {
        log('Error checking user folder: $e', name: 'SupabaseStorageService');
      }

      // 3. Perform removal if any files found
      if (filesToDelete.isNotEmpty) {
        await _supabase.client.storage
            .from(_profileImagesBucket)
            .remove(filesToDelete);
        log('Successfully deleted ${filesToDelete.length} files for user $userId',
            name: 'SupabaseStorageService');
      } else {
        log('No files found to delete for user $userId',
            name: 'SupabaseStorageService');
      }
    } catch (e) {
      log('Error during thorough profile image cleanup: $e',
          name: 'SupabaseStorageService');
    }
  }

  static Future<void> runDiagnostics() async {
    log('--- STARTING SUPABASE DIAGNOSTICS ---', name: 'SupabaseDiagnostics');
    try {
      // 1. Check Bucket Status
      final buckets = await _supabase.client.storage.listBuckets();
      log('Found ${buckets.length} buckets:', name: 'SupabaseDiagnostics');
      for (var bucket in buckets) {
        log(' - [${bucket.id}] Public: ${bucket.public}',
            name: 'SupabaseDiagnostics');
      }

      // 2. Test RLS (List files)
      log('Testing RLS access for $_medicinesImagesBucket...',
          name: 'SupabaseDiagnostics');
      try {
        final files = await _supabase.client.storage
            .from(_medicinesImagesBucket)
            .list(searchOptions: const SearchOptions(limit: 1));
        log('RSL Check Pass: Found ${files.length} files/folders in $_medicinesImagesBucket',
            name: 'SupabaseDiagnostics');

        if (files.isNotEmpty) {
          // 3. Test Public URL
          final testFile = files.first;
          final publicUrl = _supabase.client.storage
              .from(_medicinesImagesBucket)
              .getPublicUrl(testFile.name);
          log('Testing Public URL: $publicUrl', name: 'SupabaseDiagnostics');

          // Simple HTTP check
          final request = await HttpClient().getUrl(Uri.parse(publicUrl));
          final response = await request.close();
          log('Public URL Status Code: ${response.statusCode}',
              name: 'SupabaseDiagnostics');

          if (response.statusCode == 200) {
            log('✅ DIAGNOSIS: EVERYTHING LOOKS GOOD!',
                name: 'SupabaseDiagnostics');
          } else if (response.statusCode == 400) {
            log('❌ DIAGNOSIS FAIL: 400 Bad Request. "Public Bucket" setting is likely OFF in dashboard.',
                name: 'SupabaseDiagnostics');
          } else if (response.statusCode == 404) {
            log('⚠️ DIAGNOSIS WARN: 404 Not Found. File exists in list but public URL failed. Check Public flag.',
                name: 'SupabaseDiagnostics');
          } else {
            log('⚠️ DIAGNOSIS WARN: Unexpected status ${response.statusCode}',
                name: 'SupabaseDiagnostics');
          }
        } else {
          log('⚠️ Bucket is empty, cannot test public URL.',
              name: 'SupabaseDiagnostics');
        }
      } catch (e) {
        log('❌ RLS Check FAIL: Cannot list files. Check your RLS policies.',
            name: 'SupabaseDiagnostics');
        log('Error: $e', name: 'SupabaseDiagnostics');
      }
    } catch (e) {
      log('Diagnostics crashed: $e', name: 'SupabaseDiagnostics');
    }
    log('--- END DIAGNOSTICS ---', name: 'SupabaseDiagnostics');
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
