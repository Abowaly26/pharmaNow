import 'package:flutter/material.dart';
import 'package:pharma_now/features/auth/presentation/views/Reset_password_view.dart';
import 'package:pharma_now/features/auth/presentation/views/singn_in_view.dart';
import 'package:pharma_now/features/auth/presentation/views/singn_up_view.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/forget_password_view_body.dart';
import 'package:pharma_now/features/splash/presentation/views/splash_view.dart';

import '../../features/auth/presentation/views/forget_password_view.dart';
import '../../features/auth/presentation/views/verification_view_signup.dart';
import '../../features/favorites/presentation/views/favorites.dart';
import '../../features/home/presentation/views/main_view.dart';
import '../../features/home/presentation/views/medicine_details_view.dart';
import '../../features/info_medicines/presentation/views/info_medicines_view.dart';
import '../../features/notifications/presentation/views/notification_view.dart';

import '../../features/offers/presentation/views/info_offers_view.dart';
import '../../features/on_boarding/presentation/views/onboarding_view.dart';
import '../../features/profile/presentation/views/profile_view.dart';
import '../../features/profile/presentation/views/widgets/profile_tab/edit_profile_view.dart';
import '../../features/profile/presentation/views/widgets/profile_tab/notification_view.dart';
import '../../features/search/presentation/views/search_view.dart';
import '../../features/shopping by category/presentation/views/categories_view.dart';

Route<dynamic> onGenerateRoute(RouteSettings setting) {
  switch (setting.name) {
    case SplashView.routeName:
      return MaterialPageRoute(builder: (context) => const SplashView());

    case OnboardingView.routeName:
      return MaterialPageRoute(builder: (context) => const OnboardingView());

    case SignInView.routeName:
      return MaterialPageRoute(builder: (context) => const SignInView());

    case SingnUpView.routeName:
      return MaterialPageRoute(builder: (context) => const SingnUpView());

    case VerificationView.routeName:
      return MaterialPageRoute(builder: (context) => const VerificationView());

    case ResetPasswordView.routeName:
      return MaterialPageRoute(builder: (context) => const ResetPasswordView());

    case MainView.routeName:
      return MaterialPageRoute(builder: (context) => const MainView());

    case FavoriteView.routeName:
      return MaterialPageRoute(builder: (context) => const FavoriteView());

    case InfoMedicinesView.routeName:
      return MaterialPageRoute(builder: (context) => const InfoMedicinesView());

    case NotificationView.routeName:
      return MaterialPageRoute(builder: (context) => const NotificationView());

    case OffersView.routeName:
      return MaterialPageRoute(builder: (context) => const OffersView());

    case SearchView.routeName:
      return MaterialPageRoute(builder: (context) => const SearchView());

    case CategoriesView.routeName:
      return MaterialPageRoute(builder: (context) => const CategoriesView());

    case ProfileView.routeName:
      return MaterialPageRoute(builder: (context) => const ProfileView());

    case Notifications.routeName:
      return MaterialPageRoute(builder: (context) => Notifications());

    case EditProfile.routeName:
      return MaterialPageRoute(builder: (context) => EditProfile());

    case ProductView.routeName:
      return MaterialPageRoute(builder: (context) => ProductView());

    case ForgetPasswordView.routeName:
      return MaterialPageRoute(
          builder: (context) => const ForgetPasswordView());

    default:
      return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}
