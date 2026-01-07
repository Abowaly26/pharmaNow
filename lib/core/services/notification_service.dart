import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/features/notifications/presentation/models/notification_payload.dart';
import 'package:pharma_now/core/services/notification_log_service.dart';
import 'package:pharma_now/features/notifications/presentation/views/notification_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharma_now/core/services/user_settings_service.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

/// Service responsible for handling incoming FCM messages and routing them.
class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> _navigatorKey =
      getIt<GlobalKey<NavigatorState>>();
  final NotificationLogService _logService = getIt<NotificationLogService>();
  final UserSettingsService _settingsService = getIt<UserSettingsService>();

  /// Initialize listeners for foreground, background and terminated states.
  Future<void> init() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // When the app is opened from a terminated state via a notification
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }

    // When the app is in background and opened via a notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
        "[NotificationService] Foreground Message Received: ${message.messageId}");

    // 1. Check System Permission
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      debugPrint("[NotificationService] Permission denied, ignoring message");
      return;
    }

    final payload = _parsePayload(message);
    if (payload == null) {
      debugPrint(
          "[NotificationService] Warning: Could not parse message payload");
      return;
    }

    // 2. Check User Settings Toggles
    final settings = await _settingsService.getSettings();
    bool isEnabled = true;

    if (payload.type == 'offer' || payload.type == 'promo') {
      isEnabled = settings.offers;
    } else if (payload.type == 'order') {
      isEnabled = settings.orders;
    } else {
      isEnabled = settings.systemNotifications;
    }

    if (!isEnabled) {
      debugPrint(
          "[NotificationService] Notification type ${payload.type} is disabled in settings");
      return;
    }

    debugPrint("[NotificationService] Showing SnackBar for: ${payload.title}");

    // Save to Firestore logs
    _logService.addLog(payload, notificationId: message.messageId);

    // Show local system notification (foreground)
    _showLocalNotification(payload);

    // Show a premium in-app banner
    _showInAppBanner(payload);
  }

  void _showInAppBanner(NotificationPayload payload) {
    final context = _navigatorKey.currentState?.overlay?.context;
    if (context == null) return;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    bool isRemoved = false;

    void safeRemove() {
      if (!isRemoved && overlayEntry.mounted) {
        isRemoved = true;
        overlayEntry.remove();
      }
    }

    overlayEntry = OverlayEntry(
      builder: (context) => _InAppNotificationBanner(
        payload: payload,
        onTap: () {
          safeRemove();
          _navigateToRoute(payload);
        },
        onDismiss: safeRemove,
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after 5 seconds with safety check
    Future.delayed(const Duration(seconds: 5), () {
      safeRemove();
    });
  }

  void _handleMessageTap(RemoteMessage message) {
    debugPrint(
        "[NotificationService] Notification Tapped: ${message.messageId}");
    final payload = _parsePayload(message);
    if (payload == null) return;
    debugPrint("[NotificationService] Navigating to: ${payload.route}");

    // Save to Firestore logs (if not already saved by handlers)
    _logService.addLog(payload, notificationId: message.messageId);

    _navigateToRoute(payload);
  }

  NotificationPayload? _parsePayload(RemoteMessage message) {
    try {
      final data = message.data;
      // Expect the custom payload to be JSON encoded under the key 'payload'.
      if (data.containsKey('payload')) {
        final Map<String, dynamic> map = jsonDecode(data['payload']);
        return NotificationPayload.fromMap(map);
      }
      // Fallback to direct fields if they exist.
      return NotificationPayload(
        type: data['type'] ?? 'unknown',
        entityId: data['entityId'],
        route: data['route'],
        imageUrl: data['image'],
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
      );
    } catch (e) {
      // If parsing fails, ignore the message.
      return null;
    }
  }

  void _navigateToRoute(NotificationPayload payload) {
    final String route = (payload.route == null || payload.route!.isEmpty)
        ? NotificationView.routeName
        : payload.route!;
    _navigatorKey.currentState?.pushNamed(route);
  }

  /// Show a local notification for common app cases (e.g. Added to Fav, Success actions).
  Future<void> showSystemNotification({
    required String title,
    required String body,
    String? route,
    String type = 'system',
  }) async {
    // 1. Check System Permission
    final status = await Permission.notification.status;
    if (!status.isGranted) return;

    // 2. Check User Settings
    final settings = await _settingsService.getSettings();
    bool isEnabled = true;
    if (type == 'offer') {
      isEnabled = settings.offers;
    } else if (type == 'order') {
      isEnabled = settings.orders;
    } else {
      isEnabled = settings.systemNotifications;
    }

    if (!isEnabled) return;

    final payload = NotificationPayload(
      title: title,
      body: body,
      route: route,
      type: type,
    );

    // Save to logs
    _logService.addLog(payload);

    // Show local notification
    _showLocalNotification(payload);
  }

  Future<void> _showLocalNotification(NotificationPayload payload) async {
    final plugin = getIt<FlutterLocalNotificationsPlugin>();

    String channelId = 'pharma_now_system';
    String channelName = 'System Notifications';
    Importance importance = Importance.defaultImportance;

    if (payload.type == 'order') {
      channelId = 'pharma_now_orders';
      channelName = 'Order Updates';
      importance = Importance.max;
    } else if (payload.type == 'offer' || payload.type == 'promo') {
      channelId = 'pharma_now_offers';
      channelName = 'Offers & Promotions';
      importance = Importance.high;
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notifications related to $channelName',
      importance: importance,
      priority: Priority.high,
      showWhen: true,
      color: ColorManager.secondaryColor,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final String route = (payload.route == null || payload.route!.isEmpty)
        ? NotificationView.routeName
        : payload.route!;

    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      payload.title,
      payload.body,
      platformChannelSpecifics,
      payload: jsonEncode({'route': route}),
    );
  }
}

class _InAppNotificationBanner extends StatefulWidget {
  final NotificationPayload payload;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationBanner({
    required this.payload,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _entranceController.forward();
    _progressController.forward().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entranceAnimation,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 12,
          right: 12,
          child: Transform.scale(
            scale: _entranceAnimation.value,
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: _entranceAnimation.value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Directionality(
          textDirection: Localizations.localeOf(context).languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => widget.onDismiss(),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          child: Row(
                            children: [
                              _buildIcon(),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.payload.title,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: ColorManager.blackColor,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      widget.payload.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        height: 1.4,
                                        color: ColorManager.blackColor
                                            .withOpacity(0.7),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: ColorManager.greyColor.withOpacity(0.35),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            return LinearProgressIndicator(
                              value: 1 - _progressController.value,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getThemeColor(widget.payload.type)
                                    .withOpacity(0.4),
                              ),
                              minHeight: 3,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getThemeColor(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return const Color(0xFFF59E0B);
      case 'offer':
        return const Color(0xFF10B981);
      default:
        return ColorManager.secondaryColor;
    }
  }

  Widget _buildIcon() {
    if (widget.payload.imageUrl != null &&
        widget.payload.imageUrl!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(widget.payload.imageUrl!),
        ),
      );
    }
    final color = _getThemeColor(widget.payload.type);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        _getIconData(widget.payload.type),
        size: 22,
        color: color,
      ),
    );
  }

  IconData _getIconData(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag_rounded;
      case 'offer':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }
}
