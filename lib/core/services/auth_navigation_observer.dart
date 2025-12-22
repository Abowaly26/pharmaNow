import 'package:flutter/material.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_in_view.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_up_view.dart';
import 'package:pharma_now/features/auth/presentation/views/verification_view_signup.dart';
import 'package:pharma_now/features/auth/presentation/views/forget_password_view.dart';
import 'package:pharma_now/features/auth/presentation/views/Reset_password_view.dart';
import 'package:pharma_now/features/on_boarding/presentation/views/onboarding_view.dart';
import 'package:pharma_now/features/splash/presentation/views/splash_view.dart';

class AuthNavigationObserver extends NavigatorObserver {
  String? currentRoute;

  final List<String> publicRoutes = [
    SplashView.routeName,
    OnboardingView.routeName,
    SignInView.routeName,
    SingnUpView.routeName,
    VerificationView.routeName,
    ForgetPasswordView.routeName,
    ResetPasswordView.routeName,
  ];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      currentRoute = route.settings.name;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      currentRoute = previousRoute?.settings.name;
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      currentRoute = newRoute?.settings.name;
    }
  }

  bool get isCurrentRoutePublic {
    return currentRoute != null && publicRoutes.contains(currentRoute);
  }
}
