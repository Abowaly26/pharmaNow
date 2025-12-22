import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/core/helper_functions/on_generate_route.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/features/favorites/di/favorites_injection.dart';
import 'package:pharma_now/features/profile/presentation/providers/profile_provider.dart';
import 'package:pharma_now/features/splash/presentation/views/splash_view.dart';
import 'package:pharma_now/firebase_options.dart';
import 'package:pharma_now/features/auth/presentation/views/Reset_password_view.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_in_view.dart'; // Import SignInView for the route name
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:pharma_now/core/services/auth_navigation_observer.dart'; // Import AuthNavigationObserver

import 'core/services/custom_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupGetit();
  Bloc.observer = CustomBlocObserver();

  await prefs.init();
  runApp(PharmaNow());
  // Initialize dynamic links after the app is running to ensure plugins are registered
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initDynamicLinks();
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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
          await user.reload();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' || e.code == 'user-disabled') {
            await FirebaseAuth.instance.signOut();
          }
        } catch (e) {
          // Flatten any other errors to avoid crashing the app on network issues
          debugPrint('Error reloading user: $e');
        }
      }
    });
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is signed out or account deleted
        // Check if we are on a protected route
        if (!authNavigationObserver.isCurrentRoutePublic) {
          // Navigate to Sign In and remove all previous routes
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            SignInView.routeName,
            (route) => false,
          );
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
