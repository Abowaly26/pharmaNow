import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

import '../utils/text_styles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.lable,
      required this.icon,
      required this.hint,
      this.onSaved,
      required this.textInputType,
      this.validator,
      this.controller,
      this.obscureText = false,
      this.suffixIcon});
  final String lable;
  final String icon;
  final String hint;
  final TextInputType textInputType;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              lable,
              style: TextStyles.inputLabel16,
            ),
          ],
        ),
        SizedBox(
          height: 8.h,
        ),
        TextFormField(
          obscureText: obscureText,
          controller: controller,
          keyboardType: textInputType,
          onSaved: onSaved,
          validator: validator,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: ColorManager.textInputColor)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: ColorManager.redColor)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: ColorManager.redColor,
                  )),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: ColorManager.textInputColor)),
              prefixIcon: Padding(
                padding: EdgeInsets.all(12.r),
                child: SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                ),
              ),
              hintText: hint,
              hintStyle: TextStyle(color: ColorManager.textInputColor),
              suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

class CustomTextFieldm extends StatelessWidget {
  const CustomTextFieldm(
      {super.key,
      required this.lable,
      required this.hint,
      this.onSaved,
      required this.textInputType,
      this.validator,
      this.controller,
      this.obscureText = false,
      this.suffixIcon,
      this.onChanged});
  final String lable;
  final String hint;
  final TextInputType textInputType;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              lable,
              style: TextStyles.inputLabel16,
            ),
          ],
        ),
        SizedBox(
          height: 8.h,
        ),
        TextFormField(
          obscureText: obscureText,
          controller: controller,
          keyboardType: textInputType,
          onSaved: onSaved,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: ColorManager.textInputColor)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: ColorManager.redColor)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: ColorManager.redColor,
                  )),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: ColorManager.textInputColor)),
              hintText: hint,
              hintStyle: TextStyle(color: ColorManager.textInputColor),
              suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}
