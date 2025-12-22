import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart'
    show showCustomBar, MessageType;
import 'package:pharma_now/core/utils/app_validation.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/widgets/custom_text_field.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/core/widgets/bottom_pop_up.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/auth/presentation/views/verification_view_forget_password.dart';

class ForgetPasswordViewBody extends StatefulWidget {
  const ForgetPasswordViewBody({super.key});

  @override
  State<ForgetPasswordViewBody> createState() => _ForgetPasswordViewBodyState();
}

class _ForgetPasswordViewBodyState extends State<ForgetPasswordViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final email = _emailController.text.trim();
      final result = await getIt<AuthRepo>().sendPasswordResetEmail(email);

      if (!mounted) return;

      result.fold(
        (failure) {
          showCustomBar(
            context,
            failure.message,
            type: MessageType.error,
          );
        },
        (_) {
          showCustomBar(
            context,
            'Password reset link sent! Check your email or spam folder.',
            type: MessageType.success,
          );

          // Small delay to let the user see the success message
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifiViewForgetpassword(email: email),
                ),
              );
            }
          });
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
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
              SizedBox(height: 30.h),
              Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32.h),
              CustomTextField(
                controller: _emailController,
                textInputType: TextInputType.emailAddress,
                lable: 'Email Address',
                icon: Assets.emailIcon,
                hint: 'Enter your email',
                validator: AppValidation.validateEmail,
              ),
              SizedBox(height: 40.h),
              ElevatedButton(
                style: ButtonStyles.primaryButton,
                onPressed: _isSending ? null : _sendResetEmail,
                child: _isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Send Reset Link',
                        style: TextStyles.buttonLabel,
                      ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF3B82F6),
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Check your email for a password reset link. If you don\'t see it, check your spam folder.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF1E40AF),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
