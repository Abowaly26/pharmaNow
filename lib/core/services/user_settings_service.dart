import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_now/core/services/database_service.dart';
import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/features/notifications/presentation/models/user_notification_settings.dart';

class UserSettingsService {
  final DatabaseService _databaseService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _notifSettingsKey = 'cached_notification_settings';

  UserSettingsService(this._databaseService);

  String? get _uid => _auth.currentUser?.uid;

  /// Get user notification settings from Firestore with local cache support.
  Future<UserNotificationSettings> getSettings(
      {bool forceRefresh = false}) async {
    if (_uid == null) return UserNotificationSettings();

    // 1. Try Cache First if not forcing refresh
    if (!forceRefresh) {
      final cachedData = prefs.getString(_notifSettingsKey);
      if (cachedData.isNotEmpty) {
        try {
          return UserNotificationSettings.fromMap(jsonDecode(cachedData));
        } catch (_) {
          // If cache is corrupted, proceed to fetch
        }
      }
    }

    // 2. Fetch from Firestore
    try {
      final data = await _databaseService.getData(
        path: 'users',
        docuementId: '$_uid/settings/notifications',
      );

      if (data != null && data is Map<String, dynamic>) {
        final settings = UserNotificationSettings.fromMap(data);
        // 3. Update Cache
        await prefs.setString(_notifSettingsKey, jsonEncode(settings.toMap()));
        return settings;
      }
    } catch (_) {
      // Return cached data if available on network failure
      final cachedData = prefs.getString(_notifSettingsKey);
      if (cachedData.isNotEmpty) {
        return UserNotificationSettings.fromMap(jsonDecode(cachedData));
      }
    }

    return UserNotificationSettings();
  }

  /// Update user notification settings and local cache.
  Future<void> updateSettings(UserNotificationSettings settings) async {
    if (_uid == null) return;

    // Update Local Cache Immediately
    await prefs.setString(_notifSettingsKey, jsonEncode(settings.toMap()));

    // Update Firestore
    await _databaseService.addData(
      path: 'users/$_uid/settings',
      data: settings.toMap(),
      documentId: 'notifications',
    );
  }
}
