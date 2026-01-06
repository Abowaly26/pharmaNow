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
import 'package:permission_handler/permission_handler.dart';
import 'package:pharma_now/core/services/auth_navigation_observer.dart';
import 'package:pharma_now/core/services/notification_log_service.dart';
import 'package:pharma_now/core/services/user_settings_service.dart';
import 'package:pharma_now/core/services/fcm_service.dart';
import 'package:pharma_now/features/notifications/presentation/models/notification_payload.dart';
import 'package:pharma_now/core/network/network_cubit.dart';
import 'package:pharma_now/core/network/network_state.dart';
import 'package:pharma_now/features/splash/presentation/views/no_internet_view.dart';

import 'core/services/custom_bloc_observer.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupGetit();
  debugPrint("Handling a background message: ${message.messageId}");

  try {
    // 1. Check System Permission
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      debugPrint("[BackgroundHandler] System permission denied, ignoring");
      return;
    }

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

    // 2. Check User Settings Toggles (Must match foreground logic)
    final settingsService = getIt<UserSettingsService>();
    final settings = await settingsService.getSettings();
    bool isEnabled = true;

    if (payload.type == 'offer' || payload.type == 'promo') {
      isEnabled = settings.offers;
    } else if (payload.type == 'order') {
      isEnabled = settings.orders;
    } else {
      isEnabled = settings.systemNotifications;
    }

    if (!isEnabled) {
      debugPrint("[BackgroundHandler] Category ${payload.type} is disabled");
      return;
    }

    final logService = getIt<NotificationLogService>();
    await logService.addLog(payload, notificationId: message.messageId);
  } catch (e) {
    debugPrint("Error in background handler: $e");
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize Essential Services (Blocking startup for stability)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await prefs.init();
    setupGetit();

    final networkCubit = NetworkCubit();

    runApp(PharmaNow(networkCubit: networkCubit));

    // 2. Initialize Secondary Services (Non-blocking)
    _initializeSecondaryServices();
  } catch (e) {
    debugPrint("Critical startup error: $e");
    runApp(const PharmaNow());
  }
}

Future<void> _initializeSecondaryServices() async {
  try {
    // Initialize things that don't need to block initial frame
    await Future.wait<void>([
      SupabaseStorageService.initSupabase(),
      _initializeLocalNotifications(),
      FCMService.instance.init(),
    ]);

    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      );
    } catch (e) {
      debugPrint("Firebase App Check failed silently: $e");
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    Bloc.observer = CustomBlocObserver();

    // Handle initializations that depend on UI or Context safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _initDynamicLinks();
      } catch (e) {
        debugPrint("Dynamic links init failed: $e");
      }
    });

    debugPrint("Secondary services initialized successfully");
  } catch (e) {
    debugPrint("Error in secondary services initialization: $e");
  }
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

  // Register Android Notification Channels for granular control
  final androidPlugin = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin != null) {
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'pharma_now_orders',
        'Order Updates',
        description: 'Notifications about your orders and delivery status',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'pharma_now_offers',
        'Offers & Promotions',
        description: 'Exclusive discounts and pharmaceutical offers',
        importance: Importance.high,
        playSound: true,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'pharma_now_system',
        'System Notifications',
        description: 'Important app updates and security alerts',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
    );
  }
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
  final PendingDynamicLinkData? initialData =
      await FirebaseDynamicLinks.instance.getInitialLink();
  if (initialData != null) {
    _handleDynamicLink(initialData);
  }

  FirebaseDynamicLinks.instance.onLink.listen((event) {
    _handleDynamicLink(event);
  }).onError((error) {
    debugPrint("Dynamic Link error: $error");
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
  final NetworkCubit? networkCubit;
  const PharmaNow({super.key, this.networkCubit});

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
          await user.reload();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' || e.code == 'user-disabled') {
            await FirebaseAuth.instance.signOut();
          }
        } catch (e) {
          debugPrint('UserCheckTimer error: $e');
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
        if (widget.networkCubit != null)
          BlocProvider.value(value: widget.networkCubit!)
        else
          BlocProvider(create: (_) => NetworkCubit()),
        ...FavoritesInjection.getFavoritesProviders(),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  fontFamily: 'Inter',
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: const Color(0xFF3638DA)),
                ),
                navigatorKey: navigatorKey,
                navigatorObservers: [authNavigationObserver],
                onGenerateRoute: onGenerateRoute,
                initialRoute: SplashView.routeName,
                builder: (context, child) {
                  return BlocBuilder<NetworkCubit, NetworkState>(
                    builder: (context, state) {
                      return Stack(
                        children: [
                          if (child != null) child,
                          if (state is NetworkDisconnected ||
                              state is NetworkChecking)
                            Positioned.fill(
                              child: NoInternetView(
                                isChecking: state is NetworkChecking,
                                onRetry: () {
                                  context
                                      .read<NetworkCubit>()
                                      .checkConnection();
                                },
                                onCheckSettings: () {
                                  context
                                      .read<NetworkCubit>()
                                      .checkConnection();
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              )),
    );
  }
}
