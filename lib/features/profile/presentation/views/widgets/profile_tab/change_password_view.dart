import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:pharma_now/features/profile/presentation/providers/profile_provider.dart';
import 'package:pharma_now/core/utils/app_validation.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart'
    show showCustomBar, MessageType;

class ChangePasswordView extends StatefulWidget {
  static const String routeName = "ChangePasswordView";

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<ProfileProvider>(context, listen: false);

    log('Attempting to change password', name: 'ChangePasswordView');
    await provider.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    if (provider.status == ProfileStatus.error) {
      log('Password change failed: ${provider.errorMessage}',
          name: 'ChangePasswordView');
      showCustomBar(
        context,
        provider.errorMessage,
        type: MessageType.error,
      );
    } else {
      log('Password changed successfully', name: 'ChangePasswordView');
      showCustomBar(
        context,
        'Password changed successfully',
        type: MessageType.success,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Change Password',
          isBack: true,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 30),
              CustomTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                lable: 'Current Password',
                icon: Assets.passwordIcon,
                hint: 'Enter your current password',
                textInputType: TextInputType.visiblePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: ColorManager.textInputColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              CustomTextField(
                validator: AppValidation.validatePassword,
                lable: 'New Password',
                icon: Assets.passwordIcon,
                hint: 'Enter your new password',
                textInputType: TextInputType.visiblePassword,
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: ColorManager.textInputColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              CustomTextField(
                validator: (value) => AppValidation.validateConfirmPassword(
                  value,
                  _newPasswordController.text,
                ),
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                lable: 'Confirm New Password',
                icon: Assets.passwordIcon,
                hint: 'Enter your new password',
                textInputType: TextInputType.visiblePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: ColorManager.textInputColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              SizedBox(height: 8),
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
              SizedBox(height: 32),
              ElevatedButton(
                style: ButtonStyles.primaryButton,
                onPressed: provider.isLoading ? null : _changePassword,
                child: provider.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Change Password', style: TextStyles.buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
