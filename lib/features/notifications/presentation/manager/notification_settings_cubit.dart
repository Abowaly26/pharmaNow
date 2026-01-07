import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharma_now/core/services/user_settings_service.dart';
import 'package:pharma_now/features/notifications/presentation/models/user_notification_settings.dart';
import 'notification_settings_state.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final UserSettingsService _settingsService;

  NotificationSettingsCubit(this._settingsService)
      : super(NotificationSettingsInitial());

  Future<void> loadSettings() async {
    // 1. Instant Load from Cache
    try {
      final status = await Permission.notification.status;
      final isAllowed = status.isGranted;
      final settings =
          await _settingsService.getSettings(); // This will hit cache first

      emit(NotificationSettingsLoaded(
        settings: settings,
        isPermissionAllowed: isAllowed,
      ));

      // 2. Background Sync (Silent)
      _syncSettingsWithRemote();
    } catch (e) {
      // Fallback is still Loaded with defaults if cache fails
      emit(NotificationSettingsLoaded(
        settings: UserNotificationSettings(),
        isPermissionAllowed: false,
      ));
    }
  }

  Future<void> _syncSettingsWithRemote() async {
    try {
      final remoteSettings =
          await _settingsService.getSettings(forceRefresh: true);
      if (state is NotificationSettingsLoaded) {
        final currentState = state as NotificationSettingsLoaded;
        if (remoteSettings != currentState.settings) {
          emit(currentState.copyWith(settings: remoteSettings));
        }
      }
    } catch (_) {
      // Ignore background sync errors to maintain seamless experience
    }
  }

  Future<void> toggleSystemNotifications(bool value) async {
    await _updateSetting((s) => UserNotificationSettings(
          systemNotifications: value,
          offers: s.offers,
          orders: s.orders,
        ));
  }

  Future<void> toggleOffers(bool value) async {
    await _updateSetting((s) => UserNotificationSettings(
          systemNotifications: s.systemNotifications,
          offers: value,
          orders: s.orders,
        ));
  }

  Future<void> toggleOrders(bool value) async {
    await _updateSetting((s) => UserNotificationSettings(
          systemNotifications: s.systemNotifications,
          offers: s.offers,
          orders: value,
        ));
  }

  Future<void> _updateSetting(
      UserNotificationSettings Function(UserNotificationSettings)
          updateFn) async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;

      if (!currentState.isPermissionAllowed) {
        // We handle this in UI, but safe to keep here
        return;
      }

      final newSettings = updateFn(currentState.settings);

      // Optimistic update
      emit(currentState.copyWith(settings: newSettings));

      try {
        await _settingsService.updateSettings(newSettings);
        // Maybe emit a temporary success state for showing a snackbar if needed
      } catch (e) {
        // Rollback on error
        emit(currentState);
        emit(const NotificationSettingsError(
            "Failed to update settings. Please try again."));
        // Re-emit loaded with original settings
        emit(currentState);
      }
    }
  }

  Future<void> checkPermissions() async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;
      final status = await Permission.notification.status;
      final isAllowed = status.isGranted;

      if (isAllowed && !currentState.isPermissionAllowed) {
        // Permission was just granted, force enable all
        final allOnSettings = UserNotificationSettings(
          systemNotifications: true,
          offers: true,
          orders: true,
        );
        await _settingsService.updateSettings(allOnSettings);
        emit(NotificationSettingsLoaded(
          settings: allOnSettings,
          isPermissionAllowed: true,
        ));
      } else {
        emit(currentState.copyWith(isPermissionAllowed: isAllowed));
      }
    }
  }
}
