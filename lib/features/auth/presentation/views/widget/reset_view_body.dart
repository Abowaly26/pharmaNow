import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/utils/app_validation.dart';
import 'package:pharma_now/core/widgets/bottom_pop_up.dart';
import 'package:pharma_now/core/widgets/custom_text_field.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_in_view.dart';

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
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (email) => setState(() => _emailForReset = email),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final code = widget.oobCode;
    if (code == null || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or missing reset link.')));
      return;
    }
    setState(() => _submitting = true);
    final repo = getIt<AuthRepo>();
    final result = await repo.confirmPasswordReset(
        oobCode: code, newPassword: _passwordController.text.trim());
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        showSuccessBottomSheet(
          context,
          'Your password has been changed successfully. You can now sign in.',
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
          children: [
            if (_emailForReset != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Reset for: $_emailForReset',
                    style: TextStyles.inputLabel16),
              ),
              SizedBox(height: 16.h),
            ],
            CustomTextField(
              controller: _passwordController,
              textInputType: TextInputType.visiblePassword,
              lable: 'Password',
              icon: Assets.passwordIcon,
              hint: 'Enter your password',
              validator: AppValidation.validatePassword,
              obscureText: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _confirmController,
              textInputType: TextInputType.visiblePassword,
              lable: 'Confirm Password',
              icon: Assets.passwordIcon,
              hint: 'Re-enter your password',
              validator: (value) => AppValidation.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              obscureText: true,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              style: ButtonStyles.primaryButton,
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      'Reset',
                      style: TextStyles.buttonLabel,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
