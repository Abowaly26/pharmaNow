import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

class TextStyles {
  TextStyles._();

  static TextStyle skip = TextStyle(
      fontSize: 18.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.normal,
      color: ColorManager.greyColor);

  static TextStyle title = TextStyle(
      fontSize: 26.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      color: ColorManager.primaryColor);

  static TextStyle description = TextStyle(
      fontSize: 13.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.normal,
      color: ColorManager.primaryColor);

  static TextStyle appBarTitle18 = TextStyle(
    color: ColorManager.blackColor,
    fontSize: 18.sp,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );

  static TextStyle inputLabel16 = TextStyle(
    color: ColorManager.blackColor,
    fontSize: 16.sp,
    fontFamily: 'Inter',
    fontWeight: FontWeight.normal,
  );
  static TextStyle forgetPassword = TextStyle(
    color: Color(0xFF5356AB),
    fontSize: 12.sp,
    fontFamily: 'Inter',
    fontWeight: FontWeight.normal,
  );

  static TextStyle buttonLabel = TextStyle(
      fontSize: 14.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      color: ColorManager.primaryColor);

  static TextStyle orDividerText = TextStyle(
    color: Color(0xFF6C7278),
    fontSize: 12.sp,
    fontFamily: 'Inter',
    fontWeight: FontWeight.normal,
  );

  static TextStyle textOfAnotherContinue = TextStyle(
      fontSize: 14.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      color: ColorManager.blackColor);

  static TextStyle callToActionText = TextStyle(
      fontSize: 12.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      color: Color(0xFF6C7278));

  static TextStyle callToActionSignUP = TextStyle(
      fontSize: 12.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      color: Color(0xFF4D81E7));
}
