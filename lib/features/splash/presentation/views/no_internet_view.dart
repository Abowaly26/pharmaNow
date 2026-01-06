import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NoInternetView extends StatefulWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onCheckSettings;

  const NoInternetView({
    super.key,
    this.onRetry,
    this.onCheckSettings,
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
                  // Glow Effect
                  Container(
                    width: 160.w,
                    height: 160.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3638DA).withOpacity(0.05),
                    ),
                  ),
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3638DA).withOpacity(0.1),
                    ),
                  ),
                  // Main Icon Circle
                  Container(
                    width: 160.w,
                    height: 160.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF8FAFC), // Slate-50
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFF1F5F9), // Slate-100
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 64.sp,
                        color: const Color(0xFF3638DA),
                      ),
                    ),
                  ),
                  // Red Pulsing Dot
                  Positioned(
                    top: 32.h,
                    right: 32.w,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red
                                    .withOpacity(0.5 * _fadeAnimation.value),
                                blurRadius: 8 * _scaleAnimation.value,
                                spreadRadius: 2 * _scaleAnimation.value,
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
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A), // Slate-900
                  height: 1.2,
                ),
              ),
              SizedBox(height: 12.h),

              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "We can't reach pharmNow right now. Please check your internet connection settings and try again.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B), // Slate-500
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 48.h),

              // Retry Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: widget.onRetry,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Retry',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
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
                  textStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
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
