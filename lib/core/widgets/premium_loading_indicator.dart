import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

class PremiumLoadingIndicator extends StatelessWidget {
  final double? size;
  final IconData? icon;
  final Color? color;

  const PremiumLoadingIndicator({
    super.key,
    this.size,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorSize = size ?? 72.h;
    final primaryColor = color ?? ColorManager.secondaryColor;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background track
        SizedBox(
          height: indicatorSize,
          width: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(
              primaryColor.withOpacity(0.1),
            ),
          ),
        ),
        // Rotating indicator
        SizedBox(
          height: indicatorSize,
          width: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(
              primaryColor,
            ),
          ),
        ),
        // Center icon
        Icon(
          icon ?? Icons.auto_awesome_rounded,
          color: primaryColor,
          size: (indicatorSize * 0.44),
        ),
      ],
    );
  }
}
