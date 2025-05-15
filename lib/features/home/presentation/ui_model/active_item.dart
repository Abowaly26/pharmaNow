import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/utils/color_manger.dart';
import '../../../../core/utils/text_styles.dart';

class ActiveItem extends StatelessWidget {
  const ActiveItem({super.key, required this.text, required this.image});

  final String text;
  final String image;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(
          right: 7.w,
        ),
        decoration: ShapeDecoration(
          color: const Color(0xFFEEEEEE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              decoration: ShapeDecoration(
                color: ColorManager.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Center(
                  child: SvgPicture.asset(
                image,
                width: 18.w,
                height: 18.h,
              )),
            ),
            SizedBox(
              width: 3.w,
            ),
            Text(
              text,
              style: TextStyles.semiBold11
                  .copyWith(color: ColorManager.secondaryColor),
            )
          ],
        ),
      ),
    );
  }
}
