import 'package:flutter/material.dart';
import 'package:pharma_now/Cart/presentation/views/cart_view.dart';
import 'package:pharma_now/features/Medical_Assistant/MedicalAssistant%20.dart';
import 'package:pharma_now/features/Medical_Assistant/chat_bot/chat_bot.dart';
import 'package:pharma_now/features/auth/presentation/views/Reset_password_view.dart';
import 'package:pharma_now/features/auth/presentation/views/singn_in_view.dart';
import 'package:pharma_now/features/auth/presentation/views/singn_up_view.dart';
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

Route<dynamic> onGenerateRoute(RouteSettings setting) {
  switch (setting.name) {
    case SplashView.routeName:
      return MaterialPageRoute(builder: (context) => const SplashView());

    case CheckoutView.routeName:
      return MaterialPageRoute(builder: (context) => const CheckoutView());

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

    case ProfileView.routeName:
      return MaterialPageRoute(builder: (context) => const ProfileView());

    case Notifications.routeName:
      return MaterialPageRoute(builder: (context) => Notifications());

    case EditProfile.routeName:
      return MaterialPageRoute(builder: (context) => EditProfile());

    case ChangePasswordView.routeName:
      return MaterialPageRoute(builder: (context) => ChangePasswordView());

    case MedicineDetailsView.routeName:
      return MaterialPageRoute(builder: (context) => MedicineDetailsView());

    case MedicalAssistant.routeName:
      return MaterialPageRoute(builder: (context) => MedicalAssistant());

    case CartView.routeName:
      return MaterialPageRoute(builder: (context) => CartView());

    case ChatPage.routeName:
      return MaterialPageRoute(builder: (context) => ChatPage());

    case ForgetPasswordView.routeName:
      return MaterialPageRoute(
          builder: (context) => const ForgetPasswordView());

    default:
      return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}
