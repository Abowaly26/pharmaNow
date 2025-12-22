import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/utils/app_validation.dart';
import 'package:pharma_now/core/widgets/bottom_pop_up.dart';
import 'package:pharma_now/core/widgets/custom_text_field.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_in_view.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart'
    show showCustomBar, MessageType;

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/utils/text_styles.dart';

class ResetPasswordViewBody extends StatefulWidget {
  const ResetPasswordViewBody({super.key, this.oobCode});
  final String? oobCode;

  @override
  State<ResetPasswordViewBody> createState() => _ResetPasswordViewBodyState();
}

class _ResetPasswordViewBodyState extends State<ResetPasswordViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  bool _passwordVisible = false;
  bool _confirmVisible = false;
  String? _emailForReset; // Retrieved from verifyPasswordResetCode

  @override
  void initState() {
    super.initState();
    _verifyLinkIfProvided();
  }

  Future<void> _verifyLinkIfProvided() async {
    final code = widget.oobCode;
    if (code == null || code.isEmpty) return;
    final repo = getIt<AuthRepo>();
    final result = await repo.verifyPasswordResetCode(code);
    result.fold(
      (failure) {
        showCustomBar(
          context,
          failure.message,
          type: MessageType.error,
        );
        // Navigate back to forgot password screen after a delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, SignInView.routeName);
          }
        });
      },
      (email) => setState(() => _emailForReset = email),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final code = widget.oobCode;
    if (code == null || code.isEmpty) {
      showCustomBar(
        context,
        'Invalid or missing reset link.',
        type: MessageType.error,
      );
      return;
    }
    setState(() => _submitting = true);
    final repo = getIt<AuthRepo>();
    final result = await repo.confirmPasswordReset(
        oobCode: code, newPassword: _passwordController.text.trim());
    result.fold(
      (failure) {
        showCustomBar(
          context,
          failure.message,
          type: MessageType.error,
        );
      },
      (_) {
        showSuccessBottomSheet(
          context,
          'Your password has been changed successfully. You can now sign in with your new password.',
          () {
            Navigator.pushReplacementNamed(context, SignInView.routeName);
          },
        );
      },
    );
    setState(() => _submitting = false);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 42.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset Your Password',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Create a new password for your account',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 32.h),
            if (_emailForReset != null) ...[
              Text(
                'Account: $_emailForReset',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 16.h),
            ],
            CustomTextField(
              controller: _passwordController,
              textInputType: TextInputType.visiblePassword,
              lable: 'New Password',
              icon: Assets.passwordIcon,
              hint: 'Enter your new password',
              validator: AppValidation.validatePassword,
              obscureText: !_passwordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _confirmController,
              textInputType: TextInputType.visiblePassword,
              lable: 'Confirm New Password',
              icon: Assets.passwordIcon,
              hint: 'Re-enter your new password',
              validator: (value) => AppValidation.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              obscureText: !_confirmVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _confirmVisible = !_confirmVisible;
                  });
                },
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Password must be at least 6 characters and contain uppercase, lowercase, and number',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              style: ButtonStyles.primaryButton,
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ))
                  : Text(
                      'Reset Password',
                      style: TextStyles.buttonLabel,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
