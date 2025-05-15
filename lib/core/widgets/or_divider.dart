import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(
          thickness: 1,
          color: ColorManager.colorLines,
        )),
        SizedBox(width: 18.w),
        Text('Or',
            textAlign: TextAlign.center, style: TextStyles.orDividerText),
        SizedBox(width: 18.w),
        Expanded(child: Divider(color: ColorManager.colorLines)),
      ],
    );
  }
}
