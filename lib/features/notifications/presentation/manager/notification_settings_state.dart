import 'package:equatable/equatable.dart';
import 'package:pharma_now/features/notifications/presentation/models/user_notification_settings.dart';

abstract class NotificationSettingsState extends Equatable {
  const NotificationSettingsState();

  @override
  List<Object?> get props => [];
}

class NotificationSettingsInitial extends NotificationSettingsState {}

class NotificationSettingsLoading extends NotificationSettingsState {}

class NotificationSettingsLoaded extends NotificationSettingsState {
  final UserNotificationSettings settings;
  final bool isPermissionAllowed;

  const NotificationSettingsLoaded({
    required this.settings,
    required this.isPermissionAllowed,
  });

  @override
  List<Object?> get props => [settings, isPermissionAllowed];

  NotificationSettingsLoaded copyWith({
    UserNotificationSettings? settings,
    bool? isPermissionAllowed,
  }) {
    return NotificationSettingsLoaded(
      settings: settings ?? this.settings,
      isPermissionAllowed: isPermissionAllowed ?? this.isPermissionAllowed,
    );
  }
}

class NotificationSettingsError extends NotificationSettingsState {
  final String message;

  const NotificationSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationSettingsUpdateSuccess extends NotificationSettingsState {}
