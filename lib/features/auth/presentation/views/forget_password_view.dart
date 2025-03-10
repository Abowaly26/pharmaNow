import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/auth/presentation/views/login_view.dart';
import 'package:pharma_now/features/auth/presentation/views/singn_up_view.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/forget_password_view_body.dart';

import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({super.key});
  static const routeName = 'ForgetPasswordView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Reset Password',
          isBack: true,
          onPressed: () =>
              Navigator.pushReplacementNamed(context, LoginView.routeName),
        ),
      ),
      body: ForgetPasswordViewBody(),
    );
  }
}
