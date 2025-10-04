import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/widgets/custom_text_field.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/utils/text_styles.dart';

class ResetPasswordViewBody extends StatelessWidget {
  const ResetPasswordViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 42.h),
      child: Column(
        children: [
          CustomTextField(
            textInputType: TextInputType.visiblePassword,
            lable: 'Password',
            icon: Assets.passwordIcon,
            hint: 'Enter your pasword',
          ),
          SizedBox(
            height: 16.h,
          ),
          CustomTextField(
            textInputType: TextInputType.visiblePassword,
            lable: 'Confirm Password',
            icon: Assets.passwordIcon,
            hint: 'Enter your pasword',
          ),
          SizedBox(
            height: 32.h,
          ),
          ElevatedButton(
            style: ButtonStyles.primaryButton,
            // onPressed: () =>
            // SuccessBottomSheet(text: 'Account created successfully!'),
            onPressed: () {},
            child: Text(
              'Reset',
              style: TextStyles.buttonLabel,
            ),
          ),
        ],
      ),
    );
  }
}
