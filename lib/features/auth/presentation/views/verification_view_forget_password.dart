import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:pharma_now/features/auth/presentation/views/forget_password_view.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/verification_view_body_forgetPassword.dart';

import '../../../../core/utils/color_manger.dart';

class VerifiViewForgetpassword extends StatelessWidget {
  const VerifiViewForgetpassword({super.key});
  static const routeName = 'verificationView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Verification',
          isBack: true,
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, ForgetPasswordView.routeName);
          },
        ),
      ),
      body: VerifiBodyForgetPass(),
    );
  }
}
