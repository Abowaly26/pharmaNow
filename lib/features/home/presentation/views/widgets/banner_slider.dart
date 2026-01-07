import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider>
    with WidgetsBindingObserver {
  late PageController _bannerController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  final List<BannerItem> _banners = [
    BannerItem(
      image: Assets.rectangleBanner,
      title: 'Medicine Locator',
      subtitle: 'Find rare medications quickly from trusted nearby pharmacies.',
      badgeText: 'RARE MEDS',
      primaryColor: const Color(0xFF3478F6), // Satin Azure
      backgroundColor: const Color(0xFFEBF3FF),
      overlayImage: Assets.medicineBro,
    ),
    BannerItem(
      image: Assets.rectangleBanner,
      title: 'Exclusive Deals',
      subtitle:
          'Save more with exclusive offers from verified local pharmacies.',
      badgeText: 'SAVINGS',
      primaryColor: const Color(0xFF10B981), // Crystal Mint
      backgroundColor: const Color(0xFFECFDF5),
      overlayImage: Assets.publicHealth,
    ),
    BannerItem(
      image: Assets.rectangleBanner,
      title: 'Trusted Medical Delivery',
      subtitle:
          'Your medications delivered safely and on time, when you need them.',
      badgeText: 'TRUSTED',
      primaryColor: const Color(0xFF8B5CF6), // Velvet Amethyst
      backgroundColor: const Color(0xFFF5F3FF),
      overlayImage: 'assets/images/on_boarding_image_1.svg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: 0);
    WidgetsBinding.instance.addObserver(this);
    // Start auto-scroll after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _banners.isNotEmpty) {
        _startBannerAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    // It's crucial to dispose of the controller and cancel the timer
    _stopBannerAutoScroll();
    _bannerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      // Restart the timer when the app comes back to the foreground
      _startBannerAutoScroll();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Stop the timer when the app is not active
      _stopBannerAutoScroll();
    }
  }

  void _startBannerAutoScroll() {
    if (_bannerTimer?.isActive == true || _banners.length <= 1) return;

    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_bannerController.hasClients) {
        timer.cancel();
        return;
      }

      _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;

      _bannerController.animateToPage(
        _currentBannerIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopBannerAutoScroll() {
    _bannerTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_banners.isEmpty) {
      return SizedBox(height: 200.h);
    }

    return Column(
      children: [
        Listener(
          onPointerDown: (_) => _stopBannerAutoScroll(),
          onPointerUp: (_) => _startBannerAutoScroll(),
          onPointerCancel: (_) => _startBannerAutoScroll(),
          child: SizedBox(
            height: 182.h,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              onPageChanged: (index) {
                // Update the index on manual swipe
                _currentBannerIndex = index;
              },
              itemBuilder: (context, index) {
                return _buildBannerItem(_banners[index]);
              },
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SmoothPageIndicator(
          controller: _bannerController,
          count: _banners.length,
          effect: WormEffect(
            dotHeight: 6.h,
            dotWidth: 6.w,
            spacing: 10.w,
            dotColor: ColorManager.secondaryColor.withOpacity(0.1),
            activeDotColor: ColorManager.secondaryColor,
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _buildBannerItem(BannerItem banner) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Premium Soft Background
            Container(
              width: double.infinity,
              height: 182.h,
              decoration: BoxDecoration(
                color: banner.backgroundColor,
              ),
            ),

            // Abstract Decorative Elements (Blobs for depth) - Style 2
            Positioned(
              top: -50.h,
              right: -30.w,
              child: Container(
                width: 150.w,
                height: 150.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: banner.primaryColor.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -20.h,
              left: 50.w,
              child: Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: banner.primaryColor.withOpacity(0.1),
                ),
              ),
            ),

            // Background SVG Pattern (Low opacity)
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: _buildSvgImage(banner.image),
              ),
            ),

            // Illustration with Depth
            if (banner.overlayImage != null)
              Positioned(
                right: 5.w,
                top: 10.h,
                bottom: 10.h,
                child: Hero(
                  tag: 'banner_image_${banner.title}',
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    width: 160.w,
                    child: _buildSvgImage(banner.overlayImage!),
                  ),
                ),
              ),

            // Text Content - Refined Typography
            Positioned(
              left: 26.w,
              top: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphism-style Badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: banner.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: banner.primaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      banner.badgeText,
                      style: TextStyles.bold16White.copyWith(
                        color: banner.primaryColor,
                        fontSize: 9.sp,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: 160.w,
                    child: Text(
                      banner.title,
                      style: TextStyles.bold24Black.copyWith(
                        color: const Color(0xFF2D3748),
                        fontSize: 22.sp,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: 160.w,
                    child: Text(
                      banner.subtitle,
                      style: TextStyles.regular16White.copyWith(
                        color: const Color(0xFF718096),
                        fontSize: 12.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Full Banner Interaction
            Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: banner.primaryColor.withOpacity(0.05),
                highlightColor: banner.primaryColor.withOpacity(0.02),
                onTap: () {
                  // Navigate or perform action
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSvgImage(String assetPath) {
    try {
      return SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          color: ColorManager.secondaryColor.withOpacity(0.1),
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              size: 60.sp,
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error loading SVG: $e');
      return Container(
        color: ColorManager.secondaryColor.withOpacity(0.1),
        child: Center(
          child: Icon(Icons.image_not_supported),
        ),
      );
    }
  }
}

// Banner data model
class BannerItem {
  final String image;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color primaryColor;
  final Color backgroundColor;
  final String? overlayImage;

  BannerItem({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.primaryColor,
    required this.backgroundColor,
    this.overlayImage,
  });
}
