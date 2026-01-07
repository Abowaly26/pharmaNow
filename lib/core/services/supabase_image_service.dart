class SupabaseImageService {
  /// Generates a public HTTPS URL for an image stored in Supabase.
  /// Used for providing images in FCM payloads.
  static String? getPublicUrl(String bucket, String path) {
    try {
      // Assuming SupabaseStorageService has access to the client
      // This is a helper to ensure we always have valid HTTPS URLs
      return 'https://tqovoskyntovlyeoxuow.supabase.co/storage/v1/object/public/$bucket/$path';
    } catch (e) {
      return null;
    }
  }
}
