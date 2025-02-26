import 'package:flutter/material.dart';
import 'package:pharma_now/features/splash/presentation/views/splash_view.dart';

import '../../features/on_boarding/presentation/views/on_boarding_view.dart';

Route<dynamic> onGenerateRoute(RouteSettings setting) {
  switch (setting.name) {
    case SplashView.routeName:
      return MaterialPageRoute(builder: (context) => const SplashView());
    case OnBoardingView.routeName:
      return MaterialPageRoute(builder: (context) => const OnBoardingView());

    default:
      return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}
