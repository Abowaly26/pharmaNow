import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_now/core/services/database_service.dart';
import 'package:pharma_now/features/notifications/presentation/models/user_notification_settings.dart';

class UserSettingsService {
  final DatabaseService _databaseService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserSettingsService(this._databaseService);

  String? get _uid => _auth.currentUser?.uid;

  /// Get user notification settings from Firestore.
  Future<UserNotificationSettings> getSettings() async {
    if (_uid == null) return UserNotificationSettings();

    final data = await _databaseService.getData(
      path: 'users',
      docuementId: '$_uid/settings/notifications',
    );

    if (data != null && data is Map<String, dynamic>) {
      return UserNotificationSettings.fromMap(data);
    }

    return UserNotificationSettings();
  }

  /// Update user notification settings.
  Future<void> updateSettings(UserNotificationSettings settings) async {
    if (_uid == null) return;

    await _databaseService.addData(
      path: 'users/$_uid/settings',
      data: settings.toMap(),
      documentId: 'notifications',
    );
  }
}
