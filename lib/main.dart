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

class PharmaNow extends StatelessWidget {
  const PharmaNow({super.key});

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
                onGenerateRoute: onGenerateRoute,
                initialRoute: SplashView.routeName,
              )),
    );
  }
}
