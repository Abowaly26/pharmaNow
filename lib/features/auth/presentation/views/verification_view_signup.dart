import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_up_view.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/verification_view_body_signup.dart';

import '../../../../core/utils/color_manger.dart';

class VerificationView extends StatelessWidget {
  const VerificationView({super.key});
  static const routeName = 'verificationView';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final fromSplash = args?['fromSplash'] ?? false;

    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Verification',
        ),
      ),
      body: VerificationViewBody(fromSplash: fromSplash),
    );
  }
}
