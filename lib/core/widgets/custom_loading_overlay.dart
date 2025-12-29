import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

class CustomLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? child;
  final bool showCard;

  const CustomLoadingOverlay({
    super.key,
    required this.isLoading,
    this.title = 'Processing',
    this.subtitle = 'Please wait while we handle your request...',
    this.icon,
    this.child,
    this.showCard = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        if (isLoading)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.15),
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: !showCard
                        ? const SizedBox.shrink()
                        : Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28.r),
                            elevation: 15,
                            shadowColor: Colors.black26,
                            child: Container(
                              width: 300.w,
                              padding: EdgeInsets.symmetric(
                                vertical: 36.h,
                                horizontal: 24.w,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildProgressIndicator(),
                                  SizedBox(height: 28.h),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1A1D23),
                                      letterSpacing: 0.3,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      height: 1.5,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.none,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  _buildSecureBadge(),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 72.h,
          width: 72.h,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(
              ColorManager.secondaryColor.withOpacity(0.1),
            ),
          ),
        ),
        SizedBox(
          height: 72.h,
          width: 72.h,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorManager.secondaryColor,
                ),
              );
            },
          ),
        ),
        Icon(
          icon ?? Icons.auto_awesome_rounded,
          color: ColorManager.secondaryColor,
          size: 32.sp,
        ),
      ],
    );
  }

  Widget _buildSecureBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 16.sp,
            color: const Color(0xFF9EA5B1),
          ),
          SizedBox(width: 8.w),
          Text(
            'SECURE TRANSACTION',
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF9EA5B1),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
