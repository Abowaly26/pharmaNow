import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:pharma_now/features/auth/presentation/views/forget_password_view.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/verification_reset_email_body.dart';

import '../../../../core/utils/color_manger.dart';

class VerifiViewForgetpassword extends StatelessWidget {
  const VerifiViewForgetpassword({super.key, required this.email});
  static const routeName = 'verificationView';
  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Verification',
        ),
      ),
      body: VerificationResetEmailBody(email: email),
    );
  }
}
