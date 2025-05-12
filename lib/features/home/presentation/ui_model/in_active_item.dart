import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/utils/color_manger.dart';

class InActiveItem extends StatelessWidget {
  const InActiveItem({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      image,
      width: 22.w,
      height: 22.h,
      colorFilter: ColorFilter.mode(
        Color(0xFF4E5556),
        BlendMode.srcIn,
      ),
    );
  }
}
