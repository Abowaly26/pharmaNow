import 'dart:io';

import 'package:path/path.dart';
import 'package:pharma_now/core/services/storage_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as b;

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
      await _supabase.client.storage.createBucket(bucketName);
    }
  }

  static initSupabase() async {
    _supabase = await Supabase.initialize(
      url: 'https://jzvdrawjkkqbxqvhpefhd.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6dmRyYXdqa2txYnh2aHBlZmhkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjExMzg1MSwiZXhwIjoyMDYxNjg5ODUxfQ.vCmtvSQIVykYWODNbcxZD9JJENCd6_t65St1ptTuPCM',
    );
    // Initialize profile images bucket
    await createBuckets(_profileImagesBucket);
  }

  @override
  Future<String> uploadFile(File file, String path) async {
    String fileName = b.basename(file.path);
    String extensionName = b.extension(file.path);
    var result = await _supabase.client.storage
        .from(_medicinesImagesBucket)
        .upload('$path/$fileName.$extensionName', file);

    final String publiUrl = _supabase.client.storage
        .from(_medicinesImagesBucket)
        .getPublicUrl('$path/$fileName.$extensionName');
    return publiUrl;
  }

  /// Upload profile image for a user
  /// Returns the public URL of the uploaded image
  Future<String> uploadProfileImage(File file, String userId) async {
    final String extensionName = b.extension(file.path);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${userId}_$timestamp$extensionName';

    // Delete old profile image if exists
    try {
      final List<FileObject> existingFiles =
          await _supabase.client.storage.from(_profileImagesBucket).list();
      final userFiles =
          existingFiles.where((f) => f.name.startsWith('${userId}_')).toList();
      if (userFiles.isNotEmpty) {
        await _supabase.client.storage
            .from(_profileImagesBucket)
            .remove(userFiles.map((f) => f.name).toList());
      }
    } catch (e) {
      // Ignore errors when trying to delete old files
    }

    // Upload new profile image
    await _supabase.client.storage
        .from(_profileImagesBucket)
        .upload(fileName, file);

    final String publicUrl = _supabase.client.storage
        .from(_profileImagesBucket)
        .getPublicUrl(fileName);

    return publicUrl;
  }

  /// Delete profile image for a user
  Future<void> deleteProfileImage(String userId) async {
    try {
      final List<FileObject> existingFiles =
          await _supabase.client.storage.from(_profileImagesBucket).list();
      final userFiles =
          existingFiles.where((f) => f.name.startsWith('${userId}_')).toList();
      if (userFiles.isNotEmpty) {
        await _supabase.client.storage
            .from(_profileImagesBucket)
            .remove(userFiles.map((f) => f.name).toList());
      }
    } catch (e) {
      throw Exception('Failed to delete profile image: $e');
    }
  }

  Future<void> deleteFile(String filePath) async {
    await _supabase.client.storage
        .from(_medicinesImagesBucket)
        .remove([filePath]);
  }
}
