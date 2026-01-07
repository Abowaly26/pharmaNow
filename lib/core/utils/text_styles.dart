import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  static const TextStyle semiBold13 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  static final TextStyle settingItemTitle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static final TextStyle settingItemSubTitle = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: Colors.grey[600],
  );
}

class AppStyles {
  static TextStyle regular(double fontSize, {Color color = Colors.black}) {
    return TextStyle(
      fontFamily: 'CustomFont',
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  static TextStyle bold(double fontSize, {Color color = Colors.black}) {
    return TextStyle(
      fontFamily: 'CustomFont',
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle italic(double fontSize, {Color color = Colors.black}) {
    return TextStyle(
      fontFamily: 'CustomFont',
      fontSize: fontSize,
      fontStyle: FontStyle.italic,
      color: color,
    );
  }

  // خط مائل وعريض
  static TextStyle boldItalic(double fontSize, {Color color = Colors.black}) {
    return TextStyle(
      fontFamily: 'CustomFont',
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      color: color,
    );
  }

  // خط الحجم الكبير
  static TextStyle large(double fontSize, {Color color = Colors.black}) {
    return TextStyle(
      fontFamily: 'CustomFont',
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  static TextStyle regular12Text = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColor.primarycolor,
      fontFamily: 'Poppins');
  static TextStyle regular11SalePrice = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColor.primarycolor,
      fontFamily: 'Poppins');
  static TextStyle regular14Text = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColor.primarycolor,
      fontFamily: 'Poppins');
  static TextStyle regular18White = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: AppColor.whitecolor,
      fontFamily: 'Poppins');
  static TextStyle light14SearchHint = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w300,
      color: AppColor.primarycolor,
      fontFamily: 'Poppins');
  static TextStyle light16White = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w300,
      color: AppColor.whitecolor,
      fontFamily: 'Poppins');
  static TextStyle light18HintText = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      color: AppColor.whitecolor,
      fontFamily: 'Poppins');
  static TextStyle semi16TextWhite = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColor.whitecolor,
      fontFamily: 'Poppins');
  static TextStyle semi20Primary = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColor.primarycolor,
      fontFamily: 'Poppins');
  static TextStyle semi24White = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColor.whitecolor,
      fontFamily: 'Poppins');
  static TextStyle medium14Category = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColor.primarycolor,
      fontFamily: 'Poppins');
  static TextStyle medium14LightPrimary = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColor.primarycolor,
      fontFamily: 'Poppins');
  static TextStyle medium14PrimaryDark = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColor.primarycolor,
      fontFamily: 'Poppins');
  static TextStyle medium18Header = TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w500,
      color: AppColor.primarycolor,
      fontFamily: 'Poppins');
  static TextStyle medium18White = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColor.whitecolor,
      fontFamily: 'Poppins');
  static TextStyle medium20White = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: AppColor.whitecolor,
      fontFamily: 'Poppins');
}

class AppColor {
  static const Color primarycolor = Color(0xff004182);
  static const Color secondcolor = Color(0xffF2FEFF);
  static const Color whitecolor = Color(0xffFFFFFF);
  static const Color blackColor = Color(0xff000000);
}
