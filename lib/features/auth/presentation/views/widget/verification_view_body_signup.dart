import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';

import '../../../../../core/utils/app_images.dart';
import '../sign_in_view.dart';

class VerificationViewBody extends StatefulWidget {
  const VerificationViewBody({super.key});

  @override
  State<VerificationViewBody> createState() => _VerificationViewBodyState();
}

class _VerificationViewBodyState extends State<VerificationViewBody> {
  bool _sending = false;
  bool _checking = false;
  Timer? _pollTimer;

  Future<void> _resendVerificationEmail() async {
    setState(() => _sending = true);
    final repo = getIt<AuthRepo>();
    final result = await repo.sendEmailVerification();
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent again.'))),
    );
    setState(() => _sending = false);
  }

  Future<void> _checkVerified() async {
    setState(() => _checking = true);
    final repo = getIt<AuthRepo>();
    final result = await repo.reloadAndCheckEmailVerified();
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (isVerified) {
        if (isVerified) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SignInView()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Email not verified yet. Please check your inbox')));
        }
      },
    );
    setState(() => _checking = false);
  }

  @override
  void initState() {
    super.initState();
    // Auto-check every 5 seconds
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final repo = getIt<AuthRepo>();
      final result = await repo.reloadAndCheckEmailVerified();
      result.fold(
        (_) {},
        (isVerified) {
          if (isVerified && mounted) {
            _pollTimer?.cancel();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SignInView()),
            );
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
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
            'A verification link has been sent to your email. Please click the link to verify your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _sending ? null : _resendVerificationEmail,
                child: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Resend Email'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            style: ButtonStyles.primaryButton,
            onPressed: _checking ? null : _checkVerified,
            child: _checking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    'I Verified, Continue',
                    style: TextStyles.buttonLabel,
                  ),
          ),
        ]),
      ),
    );
  }
}
