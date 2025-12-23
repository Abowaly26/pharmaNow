import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_now/constants.dart';
import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_in_view.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';

import '../../../../../core/services/firebase_auth_service.dart';
import '../../../../on_boarding/presentation/views/onboarding_view.dart';
import 'package:pharma_now/features/auth/presentation/views/verification_view_signup.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    excuteNavigation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          child: SvgPicture.asset(Assets.splashViewImage),
        ),
      ],
    );
  }

  void excuteNavigation() {
    bool isOnBoardingViewSeen = prefs.getBool(kIsOnBoardingViewSeen);

    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('Onboarding Seen: $isOnBoardingViewSeen');
      if (!mounted) return;
      if (isOnBoardingViewSeen) {
        var isLoggedIn = FirebaseAuthService().isLoggedIn();
        if (isLoggedIn) {
          // Check verification status to prevent unverified users from accessing Home
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && user.emailVerified) {
            Navigator.pushReplacementNamed(context, MainView.routeName);
          } else {
            // If logged in but not verified, go directly to verification screen
            Navigator.pushReplacementNamed(context, VerificationView.routeName);
          }
        } else {
          Navigator.pushReplacementNamed(context, SignInView.routeName);
        }
      } else {
        Navigator.pushReplacementNamed(context, OnboardingView.routeName);
      }
    });
  }
}
