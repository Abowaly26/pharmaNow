import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/features/notifications/presentation/models/notification_payload.dart';
import 'package:pharma_now/core/services/notification_log_service.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/features/notifications/presentation/views/notification_view.dart';

/// Service responsible for handling incoming FCM messages and routing them.
class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> _navigatorKey =
      getIt<GlobalKey<NavigatorState>>();
  final NotificationLogService _logService = getIt<NotificationLogService>();

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

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
        "[NotificationService] Foreground Message Received: ${message.messageId}");
    final payload = _parsePayload(message);
    if (payload == null) {
      debugPrint(
          "[NotificationService] Warning: Could not parse message payload");
      return;
    }
    debugPrint("[NotificationService] Showing SnackBar for: ${payload.title}");

    // Save to Firestore logs
    _logService.addLog(payload, notificationId: message.messageId);

    // Show local system notification (foreground)
    _showLocalNotification(payload);

    // Show an in‑app banner / snackbar.
    final context = _navigatorKey.currentState?.overlay?.context;
    if (context != null) {
      final isArabic = Localizations.localeOf(context)
          .languageCode
          .toLowerCase()
          .startsWith('ar');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.all(12),
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 5),
          content: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _navigateToRoute(payload);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorManager.colorLines),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (payload.imageUrl != null &&
                        payload.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          payload.imageUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: ColorManager.secondaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: ColorManager.secondaryColor,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payload.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: ColorManager.blackColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            payload.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorManager.greyColor.withOpacity(0.95),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              _navigateToRoute(payload);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.secondaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isArabic ? 'فتح' : 'Open',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: ColorManager.colorLines,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 18,
                            icon: const Icon(Icons.close,
                                size: 18, color: Colors.black87),
                            onPressed: () => ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      debugPrint("[NotificationService] Error: Navigator context is null");
    }
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

  Future<void> _showLocalNotification(NotificationPayload payload) async {
    final plugin = getIt<FlutterLocalNotificationsPlugin>();
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pharma_now_channel',
      'PharmaNow Notifications',
      channelDescription: 'Notifications from PharmaNow app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
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
