import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_images.dart';
import '../utils/color_manger.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({
    super.key,
    required this.isChecked,
    required this.onChecked,
    this.size,
  });

  final bool isChecked;
  final ValueChanged<bool> onChecked;
  final double? size;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          onChecked(!isChecked);
        },
        child: AnimatedContainer(
          width: size ?? 18.w,
          height: size ?? 18.h,
          duration: const Duration(milliseconds: 300),
          decoration: ShapeDecoration(
            color: isChecked ? ColorManager.secondaryColor : Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.5.w,
                color: isChecked ? Colors.transparent : const Color(0xffDCDEDE),
              ),
              borderRadius: BorderRadius.circular(6.w),
            ),
          ),
          child: isChecked
              ? Padding(
                  padding: EdgeInsets.all(2.w),
                  child: SvgPicture.asset(
                    Assets.checkMark,
                  ),
                )
              : null,
        ),
      );
}
