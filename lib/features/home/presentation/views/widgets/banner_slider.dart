import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/button_style.dart';
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
      title: 'Discount',
      discount: '50%',
      buttonText: 'Buy Now',
      overlayImage: Assets.medicineBro,
    ),
    BannerItem(
      image: Assets.rectangleBanner,
      title: 'Special',
      discount: '30%',
      buttonText: 'Shop Now',
      overlayImage: Assets.publicHealth,
    ),
    BannerItem(
      image: Assets.rectangleBanner,
      title: 'New Arrival',
      discount: '20%',
      buttonText: 'Explore',
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
        SizedBox(
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
        SizedBox(height: 12.h),
        SmoothPageIndicator(
          controller: _bannerController,
          count: _banners.length,
          effect: WormEffect(
            dotHeight: 8.h,
            dotWidth: 8.w,
            spacing: 8.w,
            dotColor: ColorManager.colorOfsecondPopUp.withOpacity(0.5),
            activeDotColor: ColorManager.secondaryColor.withOpacity(0.88),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _buildBannerItem(BannerItem banner) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 180.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: ColorManager.secondaryColor.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: _buildSvgImage(banner.image),
            ),
          ),
          if (banner.overlayImage != null)
            Positioned(
              top: 6.h,
              right: 20.w,
              child: SizedBox(
                height: 173.h,
                width: 173.w,
                child: _buildSvgImage(banner.overlayImage!),
              ),
            ),
          Positioned(
            top: 16.h,
            left: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  banner.title,
                  style: TextStyles.bold24Black,
                ),
                Text(
                  banner.discount,
                  style: TextStyles.bold24Black
                      .copyWith(color: ColorManager.redColorF5),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  style: ButtonStyles.smallButton,
                  onPressed: () {},
                  child: Text(
                    banner.buttonText,
                    style: TextStyles.buttonLabel,
                  ),
                )
              ],
            ),
          )
        ],
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
  final String discount;
  final String buttonText;
  final String? overlayImage;

  BannerItem({
    required this.image,
    required this.title,
    required this.discount,
    required this.buttonText,
    this.overlayImage,
  });
}
