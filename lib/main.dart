import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/services/supabase_storage.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/core/helper_functions/on_generate_route.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/features/favorites/di/favorites_injection.dart';
import 'package:pharma_now/features/profile/presentation/providers/profile_provider.dart';
import 'package:pharma_now/features/splash/presentation/views/splash_view.dart';
import 'package:pharma_now/firebase_options.dart';
import 'package:pharma_now/core/services/firebase_auth_service.dart';
import 'package:pharma_now/features/auth/presentation/views/Reset_password_view.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_in_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_now/core/services/auth_navigation_observer.dart';
import 'package:pharma_now/core/services/notification_log_service.dart';
import 'package:pharma_now/core/services/fcm_service.dart';
import 'package:pharma_now/features/notifications/presentation/models/notification_payload.dart';

import 'core/services/custom_bloc_observer.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupGetit(); // Need this to use our services in background isolate
  debugPrint("Handling a background message: ${message.messageId}");

  // Save to Firestore logs
  try {
    // We need to parse the payload manually here since we don't want to rely on the singleton's private methods
    final data = message.data;
    NotificationPayload? payload;

    if (data.containsKey('payload')) {
      final Map<String, dynamic> map = jsonDecode(data['payload']);
      payload = NotificationPayload.fromMap(map);
    } else {
      payload = NotificationPayload(
        type: data['type'] ?? 'system',
        entityId: data['entityId'],
        route: data['route'],
        imageUrl: data['image'],
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
      );
    }

    final logService = getIt<NotificationLogService>();
    await logService.addLog(payload, notificationId: message.messageId);
    debugPrint("Background message saved to logs");
  } catch (e) {
    debugPrint("Error saving background message to logs: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Parallelize independent initializations to speed up startup
  await Future.wait<void>([
    SupabaseStorageService.initSupabase(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    prefs.init(),
  ]);

  // App Check must be initialized after Firebase.initializeApp
  // Using debug provider for emulator/dev testing to resolve "No AppCheckProvider installed"
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    );
    debugPrint("Firebase App Check initialized successfully");
  } catch (e) {
    debugPrint("Firebase App Check initialization failed: $e");
  }

  setupGetit();

  await _initializeLocalNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FCMService.instance.init();
  Bloc.observer = CustomBlocObserver();

  runApp(const PharmaNow());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initDynamicLinks();
  });
}

Future<void> _initializeLocalNotifications() async {
  final plugin = getIt<FlutterLocalNotificationsPlugin>();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await plugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      _handleLocalNotificationTap(response.payload);
    },
  );
}

void _handleLocalNotificationTap(String? payload) {
  if (payload == null || payload.isEmpty) return;
  try {
    final Map<String, dynamic> data = jsonDecode(payload);
    final String? route = data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(route);
    }
  } catch (e) {
    debugPrint('Error parsing local notification payload: $e');
  }
}

final GlobalKey<NavigatorState> navigatorKey =
    getIt<GlobalKey<NavigatorState>>();
final AuthNavigationObserver authNavigationObserver = AuthNavigationObserver();

Future<void> _initDynamicLinks() async {
  // Handle the initial dynamic link if the app is opened from a terminated state
  final PendingDynamicLinkData? initialData =
      await FirebaseDynamicLinks.instance.getInitialLink();
  if (initialData != null) {
    _handleDynamicLink(initialData);
  }

  // Listen for dynamic links while the app is in foreground/background
  FirebaseDynamicLinks.instance.onLink.listen((event) {
    _handleDynamicLink(event);
  }).onError((error) {
    // You may want to log or show an error
  });
}

void _handleDynamicLink(PendingDynamicLinkData data) {
  final Uri link = data.link;
  final mode = link.queryParameters['mode'];
  final oobCode = link.queryParameters['oobCode'];
  if (mode == 'resetPassword' && oobCode != null && oobCode.isNotEmpty) {
    navigatorKey.currentState?.pushNamed(
      ResetPasswordView.routeName,
      arguments: oobCode,
    );
  }
}

class PharmaNow extends StatefulWidget {
  const PharmaNow({super.key});

  @override
  State<PharmaNow> createState() => _PharmaNowState();
}

class _PharmaNowState extends State<PharmaNow> {
  Timer? _userCheckTimer;

  @override
  void initState() {
    super.initState();
    _listenToAuthChanges();
    _startUserCheckTimer();
  }

  @override
  void dispose() {
    _userCheckTimer?.cancel();
    super.dispose();
  }

  void _startUserCheckTimer() {
    _userCheckTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          debugPrint('UserCheckTimer: Reloading user...');
          await user.reload();
          debugPrint('UserCheckTimer: User reloaded successfully');
        } on FirebaseAuthException catch (e) {
          debugPrint('UserCheckTimer: FirebaseAuthException [${e.code}]');
          if (e.code == 'user-not-found' || e.code == 'user-disabled') {
            debugPrint(
                'UserCheckTimer: Security threat/Deletion detected, signing out');
            await FirebaseAuth.instance.signOut();
          }
        } catch (e) {
          debugPrint('UserCheckTimer: Error reloading user: $e');
        }
      }
    });
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        bool isPublic = authNavigationObserver.isCurrentRoutePublic;
        if (!isPublic) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (navigatorKey.currentState != null) {
              final authService = FirebaseAuthService();
              if (authService.isNormalLogout) {
                authService.setNormalLogout(false);
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  SignInView.routeName,
                  (route) => false,
                  arguments: {'accountDeleted': false, 'loggedOut': true},
                );
              } else if (authService.isUserDeleted) {
                authService.setUserDeleted(false);
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  SignInView.routeName,
                  (route) => false,
                  arguments: {'accountDeleted': true, 'reason': 'user'},
                );
              } else {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  SignInView.routeName,
                  (route) => false,
                  arguments: {'accountDeleted': true, 'reason': 'admin'},
                );
              }
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...FavoritesInjection.getFavoritesProviders(),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: ScreenUtilInit(
          designSize: Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                navigatorObservers: [authNavigationObserver],
                onGenerateRoute: onGenerateRoute,
                initialRoute: SplashView.routeName,
              )),
    );
  }
}
