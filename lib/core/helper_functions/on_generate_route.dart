import 'package:flutter/material.dart';
import 'package:pharma_now/features/order/presentation/views/cart_view.dart';

import 'package:pharma_now/features/auth/presentation/views/Reset_password_view.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_in_view.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_up_view.dart';
import 'package:pharma_now/features/splash/presentation/views/splash_view.dart';

import '../../features/auth/presentation/views/forget_password_view.dart';
import '../../features/auth/presentation/views/verification_view_signup.dart';
import '../../features/checkout/presentation/views/checkout_view.dart';
import '../../features/favorites/presentation/views/favorites.dart';
import '../../features/home/presentation/views/main_view.dart';
import '../../features/home/presentation/views/medicine_details_view.dart';
import '../../features/info_medicines/presentation/views/info_medicines_view.dart';
import '../../features/notifications/presentation/views/notification_view.dart';

import '../../features/info_offers/presentation/views/info_offers_view.dart';
import '../../features/on_boarding/presentation/views/onboarding_view.dart';
import '../../features/profile/presentation/views/profile_view.dart';
import '../../features/profile/presentation/views/widgets/profile_tab/edit_profile_view.dart';
import '../../features/profile/presentation/views/widgets/profile_tab/notification_view.dart';
import '../../features/profile/presentation/views/widgets/profile_tab/change_password_view.dart';
import '../../features/search/presentation/views/search_view.dart';
import '../../features/medical_assistant/chat_bot.dart';

Route<dynamic> onGenerateRoute(RouteSettings setting) {
  switch (setting.name) {
    case SplashView.routeName:
      return MaterialPageRoute(
        builder: (context) => const SplashView(),
        settings: setting,
      );

    case CheckoutView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CheckoutView(),
        settings: setting,
      );

    case OnboardingView.routeName:
      return MaterialPageRoute(
        builder: (context) => const OnboardingView(),
        settings: setting,
      );

    case SignInView.routeName:
      return MaterialPageRoute(
        builder: (context) => const SignInView(),
        settings: setting,
      );

    case SingnUpView.routeName:
      return MaterialPageRoute(
        builder: (context) => const SingnUpView(),
        settings: setting,
      );

    case VerificationView.routeName:
      return MaterialPageRoute(
        builder: (context) => const VerificationView(),
        settings: setting,
      );

    case ResetPasswordView.routeName:
      final code = setting.arguments as String?;
      return MaterialPageRoute(
          builder: (context) => ResetPasswordView(oobCode: code));

    case MainView.routeName:
      return MaterialPageRoute(
        builder: (context) => const MainView(),
        settings: setting,
      );

    case FavoriteView.routeName:
      return MaterialPageRoute(
        builder: (context) => const FavoriteView(),
        settings: setting,
      );

    case InfoMedicinesView.routeName:
      return MaterialPageRoute(
        builder: (context) => const InfoMedicinesView(),
        settings: setting,
      );

    case NotificationView.routeName:
      return MaterialPageRoute(
        builder: (context) => const NotificationView(),
        settings: setting,
      );

    case OffersView.routeName:
      return MaterialPageRoute(
        builder: (context) => const OffersView(),
        settings: setting,
      );

    case SearchView.routeName:
      return MaterialPageRoute(
        builder: (context) => const SearchView(),
        settings: setting,
      );

    case ProfileView.routeName:
      return MaterialPageRoute(
        builder: (context) => const ProfileView(),
        settings: setting,
      );

    case Notifications.routeName:
      return MaterialPageRoute(
        builder: (context) => Notifications(),
        settings: setting,
      );

    case EditProfile.routeName:
      return MaterialPageRoute(
        builder: (context) => EditProfile(),
        settings: setting,
      );

    case ChangePasswordView.routeName:
      return MaterialPageRoute(
        builder: (context) => ChangePasswordView(),
        settings: setting,
      );

    case MedicineDetailsView.routeName:
      return MaterialPageRoute(
        builder: (context) => MedicineDetailsView(),
        settings: setting,
      );

    case CartView.routeName:
      return MaterialPageRoute(
        builder: (context) => CartView(),
        settings: setting,
      );

    case ForgetPasswordView.routeName:
      return MaterialPageRoute(
        builder: (context) => const ForgetPasswordView(),
        settings: setting,
      );

    case ChatPage.routeName:
      return MaterialPageRoute(
        builder: (context) => const ChatPage(),
        settings: setting,
      );

    default:
      return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}
