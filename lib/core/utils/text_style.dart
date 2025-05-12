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

  static TextStyle mainTextOfPopUp = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ColorManager.blackColor,
  );

  static TextStyle secdaryTextOfPopUp = TextStyle(
      fontSize: 14.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.normal,
      color: ColorManager.colorOfsecondPopUp);

  static TextStyle bold24Black = TextStyle(
      fontSize: 20.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w900,
      color: ColorManager.blackColor);

  static TextStyle inputLabel = TextStyle(
      fontSize: 16.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.normal,
      color: ColorManager.blackColor);

  static TextStyle sectionTitle = TextStyle(
      fontSize: 14.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      color: ColorManager.blackColor);

  static TextStyle listView_product_name = TextStyle(
      fontSize: 14.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      color: ColorManager.blackColor);

  static TextStyle listView_product_subInf = TextStyle(
      fontSize: 12.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      color: Color(0xFFB8C0CB));

  static const TextStyle semiBold11 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 11,
  );
}
