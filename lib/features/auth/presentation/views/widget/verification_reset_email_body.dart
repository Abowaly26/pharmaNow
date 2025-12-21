import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_in_view.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart'
    show showCustomBar, MessageType;
import 'package:pharma_now/core/utils/color_manger.dart';

import '../../../../../core/utils/app_images.dart';

class VerificationResetEmailBody extends StatefulWidget {
  const VerificationResetEmailBody({super.key, required this.email});
  final String email;

  @override
  State<VerificationResetEmailBody> createState() =>
      _VerificationResetEmailBodyState();
}

class _VerificationResetEmailBodyState
    extends State<VerificationResetEmailBody> {
  bool _resending = false;
  int _cooldown = 0; // seconds
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    _timer?.cancel();
    setState(() => _cooldown = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown -= 1);
      }
    });
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    final repo = getIt<AuthRepo>();
    final result = await repo.sendPasswordResetEmail(widget.email.trim());
    result.fold(
      (failure) => showCustomBar(
        context,
        failure.message,
        type: MessageType.error,
      ),
      (_) {
        showCustomBar(
          context,
          'Password reset link sent successfully! Please check your email.',
          type: MessageType.success,
        );
        _startCooldown(60);
      },
    );
    if (mounted) setState(() => _resending = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 48.h),
        child: Column(
          children: [
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
              'Check Your Email',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'We have sent a password reset link to:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24.h),
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
                              _cooldown > 0
                                  ? ''
                                  : 'Request a new password reset link',
                              style: TextStyles.callToActionText,
                            ),
                            if (_cooldown > 0)
                              RichText(
                                text: TextSpan(
                                  style: TextStyles.callToActionText,
                                  children: [
                                    const TextSpan(
                                        text: 'Resend available in   '),
                                    TextSpan(
                                      text:
                                          '${(_cooldown ~/ 60).toString().padLeft(2, '0')}:${(_cooldown % 60).toString().padLeft(2, '0')}',
                                      style:
                                          TextStyles.callToActionText.copyWith(
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
                          onPressed:
                              (_cooldown > 0 || _resending) ? null : _resend,
                          child: _resending
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
                  if (_cooldown > 0) ...[
                    SizedBox(height: 10.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100.r),
                      child: LinearProgressIndicator(
                        minHeight: 6.h,
                        value: _cooldown == 0 ? 0 : 1 - (_cooldown / 60),
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
              onPressed: () {
                Navigator.pushReplacementNamed(context, SignInView.routeName);
              },
              child: Text(
                'Back to Login',
                style: TextStyles.buttonLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
