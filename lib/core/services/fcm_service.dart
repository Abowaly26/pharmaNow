import 'package:pharma_now/core/services/notification_service.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/services/fcm_token_manager.dart';

/// Central service that coordinates FCM token lifecycle and incoming notifications.
class FCMService {
  final FCMTokenManager _tokenManager;
  final NotificationService _notificationService;

  FCMService(this._tokenManager, this._notificationService);

  static FCMService get instance => getIt<FCMService>();

  /// Initialize token handling and notification listeners.
  Future<void> init() async {
    await _tokenManager.init();
    await _notificationService.init();
  }

  /// Delete the token for the current device (used on logout).
  Future<void> deleteCurrentToken() async {
    await _tokenManager.deleteCurrentToken();
  }

  /// Delete all tokens for the user (used on account deletion).
  Future<void> deleteAllTokens() async {
    await _tokenManager.deleteAllTokens();
  }
}
