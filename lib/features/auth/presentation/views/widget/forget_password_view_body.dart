import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/features/auth/presentation/views/verification_view_forget_password.dart';
import 'package:pharma_now/features/auth/presentation/views/verification_view_signup.dart';
import 'package:pharma_now/core/widgets/custom_text_field.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/verification_view_body_forgetPassword.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/utils/text_styles.dart';
import '../../../../../core/widgets/bottom_pop_up.dart';

class ForgetPasswordViewBody extends StatelessWidget {
  const ForgetPasswordViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
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
            SizedBox(
              height: 67.h,
            ),
            CustomTextField(
                textInputType: TextInputType.emailAddress,
                lable: 'Enter your email to receive code!',
                icon: Assets.emailIcon,
                hint: 'Enter your email'),
            SizedBox(
              height: 40.h,
            ),
            ElevatedButton(
              style: ButtonStyles.primaryButton,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VerifiViewForgetpassword()),
                );
              },
              child: Text(
                'Send Code',
                style: TextStyles.buttonLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
