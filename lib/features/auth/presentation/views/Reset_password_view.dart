import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/auth/presentation/views/forget_password_view.dart';

import 'package:pharma_now/features/auth/presentation/views/widget/reset_view_body.dart';

import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});
  static const routeName = 'ResetPassword';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Reset Password',
          isBack: true,
          onPressed: () => Navigator.pushReplacementNamed(
              context, ForgetPasswordView.routeName),
        ),
      ),
      body: ResetPasswordViewBody(),
    );
  }
}
