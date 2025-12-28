import 'dart:io';
import 'dart:developer';

import 'package:path/path.dart';
import 'package:pharma_now/core/services/storage_service.dart';

import 'package:path/path.dart' as b;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService implements StorageService {
  static late Supabase _supabase;
  static const String _profileImagesBucket = 'Profile_images';
  static const String _medicinesImagesBucket = 'Medicines_images';

  static createBuckets(String bucketName) async {
    var buckets = await _supabase.client.storage.listBuckets();
    bool isBucketExists = false;

    for (var bucket in buckets) {
      if (bucket.id == bucketName) {
        isBucketExists = true;
        break;
      }
    }

    if (!isBucketExists) {
      await _supabase.client.storage.createBucket(
        bucketName,
        const BucketOptions(public: true),
      );
    }
  }

  static initSupabase() async {
    try {
      // Check if already initialized
      try {
        Supabase.instance;
        log('Supabase already initialized', name: 'SupabaseStorageService');
        return;
      } catch (e) {
        // Not initialized, proceed
      }

      _supabase = await Supabase.initialize(
        url: 'https://jzvdrawjkkqbxvhpefhd.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6dmRyYXdqa2txYnh2aHBlZmhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxMTM4NTEsImV4cCI6MjA2MTY4OTg1MX0.M9LnQMmqCCtVsb4HoWkJLw6tnRFzCg4VJHYgb3mh8C8',
      );

      log('Supabase initialized successfully', name: 'SupabaseStorageService');

      // Initialize buckets
      await _initializeBuckets();
    } catch (e) {
      log('Error initializing Supabase: $e', name: 'SupabaseStorageService');
    }
  }

  static Future<void> _initializeBuckets() async {
    try {
      await createBuckets(_profileImagesBucket);
      await createBuckets(_medicinesImagesBucket);
    } catch (e) {
      log('Error creating buckets: $e', name: 'SupabaseStorageService');
    }
  }

  @override
  Future<String> uploadFile(File file, String path) async {
    String fileName = b.basename(file.path);
    String extensionName = b.extension(file.path);
    await _supabase.client.storage
        .from(_medicinesImagesBucket)
        .upload('$path/$fileName.$extensionName', file);

    final String publicUrl = _supabase.client.storage
        .from(_medicinesImagesBucket)
        .getPublicUrl('$path/$fileName.$extensionName');
    return publicUrl;
  }

  /// Upload profile image for a user
  /// Returns the public URL of the uploaded image
  Future<String> uploadProfileImage(File file, String userId) async {
    final String extensionName = b.extension(file.path);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${userId}_$timestamp$extensionName';

    // Thoroughly delete all old profile images (root and folder) before uploading new one
    await deleteProfileImage(userId);

    final String uploadPath = '$userId/$fileName';

    // Upload new profile image
    try {
      await _supabase.client.storage
          .from(_profileImagesBucket)
          .upload(uploadPath, file);

      final String publicUrl = _supabase.client.storage
          .from(_profileImagesBucket)
          .getPublicUrl(uploadPath);

      return publicUrl;
    } on SocketException catch (e) {
      log('Network error uploading profile image: $e',
          name: 'SupabaseStorageService');
      throw Exception(
          'Network error: Failed to connect to Supabase. Please check your internet connection and ensure your Supabase project is active.');
    } catch (e) {
      log('Error during profile image upload: $e',
          name: 'SupabaseStorageService');
      rethrow;
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

  Future<void> deleteFile(String filePath) async {
    await _supabase.client.storage
        .from(_medicinesImagesBucket)
        .remove([filePath]);
  }
}
