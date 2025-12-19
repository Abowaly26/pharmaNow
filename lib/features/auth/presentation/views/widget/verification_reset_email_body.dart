import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';

import '../../../../../core/utils/app_images.dart';

class VerificationResetEmailBody extends StatefulWidget {
  const VerificationResetEmailBody({super.key, required this.email});
  final String email;

  @override
  State<VerificationResetEmailBody> createState() => _VerificationResetEmailBodyState();
}

class _VerificationResetEmailBodyState extends State<VerificationResetEmailBody> {
  bool _resending = false;
  int _cooldown = 0; // seconds
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown([int seconds = 30]) {
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
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link sent again. Please check your email.')),
        );
        _startCooldown(30);
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
              'Check your email',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Text(
              'We have sent a password reset link to:\n${widget.email}\n\nPlease open your email and tap the reset link. You will be redirected back to the app to create a new password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Colors.black54, height: 1.4),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              style: ButtonStyles.primaryButton,
              onPressed: (_cooldown > 0 || _resending) ? null : _resend,
              child: _resending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      _cooldown > 0 ? 'Resend in $_cooldown s' : 'Resend Email',
                      style: TextStyles.buttonLabel,
                    ),
            ),
            SizedBox(height: 8.h),
            Text(
              'After clicking the link, you will be redirected to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
