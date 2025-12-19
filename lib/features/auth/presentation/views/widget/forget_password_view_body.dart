import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';
import 'package:pharma_now/core/utils/app_validation.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/widgets/custom_text_field.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/core/widgets/bottom_pop_up.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/text_styles.dart';

class ForgetPasswordViewBody extends StatefulWidget {
  const ForgetPasswordViewBody({super.key});

  @override
  State<ForgetPasswordViewBody> createState() => _ForgetPasswordViewBodyState();
}

class _ForgetPasswordViewBodyState extends State<ForgetPasswordViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final result = await getIt<AuthRepo>().sendPasswordResetEmail(email);

      if (!mounted) return;

      result.fold(
        (failure) {
          buildErrorBar(context, failure.message);
        },
        (_) {
          showSuccessBottomSheet(
            context,
            'Password reset link has been sent. Please check your email.',
            () {
              Navigator.pop(context);
            },
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  Assets.forget_password,
                  width: 370.w,
                  height: 240.h,
                ),
              ),
              SizedBox(height: 67.h),
              CustomTextField(
                controller: _emailController,
                textInputType: TextInputType.emailAddress,
                lable: 'Enter your email to receive reset link',
                icon: Assets.emailIcon,
                hint: 'Enter your email',
                validator: AppValidation.validateEmail,
              ),
              SizedBox(height: 40.h),
              ElevatedButton(
                style: ButtonStyles.primaryButton,
                onPressed: _isLoading ? null : _sendResetEmail,
                child: Text(
                  _isLoading ? 'Sending...' : 'Send Reset Link',
                  style: TextStyles.buttonLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
