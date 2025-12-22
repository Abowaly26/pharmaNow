import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';

import '../../../../../../core/helper_functions/build_error_bar.dart'
    show showCustomBar, MessageType;
import '../../../../../core/utils/app_images.dart';
import '../sign_in_view.dart';
import 'package:pharma_now/core/services/firebase_auth_service.dart';

class VerificationViewBody extends StatefulWidget {
  const VerificationViewBody({super.key});

  @override
  State<VerificationViewBody> createState() => _VerificationViewBodyState();
}

class _VerificationViewBodyState extends State<VerificationViewBody> {
  bool _sending = false;

  Timer? _pollTimer;
  Timer? _resendCooldownTimer;
  int _resendCooldownSeconds = 60;
  int _resendCooldownTotalSeconds = 60;

  String _formatCooldown(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startResendCooldown([int seconds = 60]) {
    _resendCooldownTimer?.cancel();
    setState(() {
      _resendCooldownTotalSeconds = seconds;
      _resendCooldownSeconds = seconds;
    });
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendCooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _resendCooldownSeconds = 0);
        return;
      }
      setState(() => _resendCooldownSeconds--);
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (_sending || _resendCooldownSeconds > 0) return;
    setState(() => _sending = true);
    final repo = getIt<AuthRepo>();
    final result = await repo.sendEmailVerification();
    result.fold(
      (failure) => showCustomBar(context, failure.message),
      (_) {
        showCustomBar(
          context,
          'Verification email sent. Please check your inbox or spam.',
          type: MessageType.success,
        );
        _startResendCooldown();
      },
    );
    setState(() => _sending = false);
  }

  Future<void> _navigateToLogin() async {
    try {
      final repo = getIt<AuthRepo>();
      // Reload user data to check latest verification status
      final isVerifiedEither = await repo.reloadAndCheckEmailVerified();

      isVerifiedEither.fold(
        (failure) => showCustomBar(context, failure.message),
        (isVerified) async {
          if (isVerified) {
            // Sign out explicitly before navigating to login (clean slate)
            await FirebaseAuthService().signOut();
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SignInView()),
            );
          } else {
            showCustomBar(context,
                'Please verify your email address first by clicking the link sent to your inbox.',
                type: MessageType.error);
          }
        },
      );
    } catch (e) {
      showCustomBar(context, 'An error occurred. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    // No auto-check loop because user is signed out.
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 48.h),
        child: Column(children: [
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              Assets.verification_image,
              width: 280.w,
              height: 290.h,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Verify your email',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Verification email sent! Check your inbox or spam folder and click the link.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 32.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: ColorManager.buttom_info,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: ColorManager.colorLines),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Didn't receive the email?",
                            style: TextStyles.sectionTitle,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _resendCooldownSeconds > 0
                                ? ''
                                : 'Request a new verification email',
                            style: TextStyles.callToActionText,
                          ),
                          if (_resendCooldownSeconds > 0)
                            RichText(
                              text: TextSpan(
                                style: TextStyles.callToActionText,
                                children: [
                                  const TextSpan(
                                      text: 'Resend available in   '),
                                  TextSpan(
                                    text:
                                        _formatCooldown(_resendCooldownSeconds),
                                    style: TextStyles.callToActionText.copyWith(
                                      color: ColorManager.secondaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    SizedBox(
                      width: 110.w,
                      height: 36.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.secondaryColor,
                          disabledBackgroundColor:
                              ColorManager.lightPurpleColorF5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r)),
                        ),
                        onPressed: (_sending || _resendCooldownSeconds > 0)
                            ? null
                            : _resendVerificationEmail,
                        child: _sending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'Resend',
                                style: TextStyles.buttonLabel,
                              ),
                      ),
                    ),
                  ],
                ),
                if (_resendCooldownSeconds > 0) ...[
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100.r),
                    child: LinearProgressIndicator(
                      minHeight: 6.h,
                      value: _resendCooldownTotalSeconds == 0
                          ? 0
                          : 1 -
                              (_resendCooldownSeconds /
                                  _resendCooldownTotalSeconds),
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          ColorManager.secondaryColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            style: ButtonStyles.primaryButton,
            onPressed: _navigateToLogin,
            child: Text(
              'Return to Login',
              style: TextStyles.buttonLabel,
            ),
          ),
        ]),
      ),
    );
  }
}
