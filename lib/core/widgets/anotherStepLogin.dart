import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharma_now/core/utils/text_style.dart';

class AnotherStepLogin extends StatelessWidget {
  const AnotherStepLogin({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
  });
  final String text;
  final String icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: SvgPicture.asset(
          icon,
          width: 24.w,
          height: 24.h,
        ),
        label: Text(
          text,
          style: TextStyles.textOfAnotherContinue,
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Color(0xFFEFF0F6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
