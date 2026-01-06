import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NoInternetView extends StatefulWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onCheckSettings;
  final bool isChecking;

  const NoInternetView({
    super.key,
    this.onRetry,
    this.onCheckSettings,
    this.isChecking = false,
  });

  @override
  State<NoInternetView> createState() => _NoInternetViewState();
}

class _NoInternetViewState extends State<NoInternetView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              // Animating Icon Container
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Subtle Background Glow
                  Container(
                    width: 220.w,
                    height: 220.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3638DA).withOpacity(0.08),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  // Main Icon Circle
                  Container(
                    width: 170.w,
                    height: 170.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 72.sp,
                        color: const Color(0xFF3638DA),
                      ),
                    ),
                  ),
                  // Red Pulse Dot (Top Right)
                  Positioned(
                    top: 25.h,
                    right: 25.w,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: 14.w,
                          height: 14.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF6B6B), // Soft Red
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B)
                                    .withOpacity(0.4 * _fadeAnimation.value),
                                blurRadius: 10 * _scaleAnimation.value,
                                spreadRadius: 2 * _scaleAnimation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Purple Pulse Dot (Bottom Left)
                  Positioned(
                    bottom: 25.h,
                    left: 25.w,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7E81FF), // Lavender/Purple
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7E81FF)
                                    .withOpacity(0.3 * _fadeAnimation.value),
                                blurRadius: 8 * _scaleAnimation.value,
                                spreadRadius: 1 * _scaleAnimation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Title
              Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A), // Slate-900
                  height: 1.2,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 12.h),

              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "We can't reach pharmNow right now. Please check your internet connection settings and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B), // Slate-500
                    height: 1.5,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              SizedBox(height: 48.h),

              // Retry Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: widget.isChecking ? null : widget.onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3638DA),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF3638DA).withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: widget.isChecking
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh_rounded, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16.h),

              // Check Settings Button
              TextButton(
                onPressed: widget.onCheckSettings,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B), // Slate-500
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                child: const Text('Check Connection Settings'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
