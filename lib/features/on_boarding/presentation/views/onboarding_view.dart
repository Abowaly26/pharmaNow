import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/constants.dart';
import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_in_view.dart';

import '../../../../core/utils/color_manger.dart';
import '../../../../core/utils/text_styles.dart';
import 'widget/onboarding_data.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  static const routeName = 'OnboardingView';

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'About us',
      description:
          'PharmaNow application helps people to find medicine and  medical cosmetic products at reasonable prices and also provides daily and weekly offers on products',
      imagePath: Assets.onboardingImage1,
    ),
    OnboardingData(
      title: 'E-Pharmacy',
      description:
          'Chat directly with a pharmacist or get instant help anytime with our smart AI chatbot',
      imagePath: Assets.onboardingImage2,
    ),
    OnboardingData(
      title: 'Medical Delivery',
      description:
          'Spend time with your family and we will deliver everything you need',
      imagePath: Assets.onboardingImage3,
    ),
  ];
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _getCardHeight(double screenHeight, double screenWidth) {
    final aspectRatio = screenHeight / screenWidth;

    if (aspectRatio > 2.2) {
      return screenHeight * 0.42;
    } else if (aspectRatio > 1.9) {
      return screenHeight * 0.45;
    } else if (aspectRatio > 1.6) {
      return screenHeight * 0.47;
    } else {
      return screenHeight * 0.50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;

          return Stack(
            children: [
              // Fixed curved card at the bottom - Responsive
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: _getCardHeight(height, width),
                  width: width,
                  child: SvgPicture.asset(
                    Assets.informationCard,
                    fit: BoxFit.fill,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),

              // PageView content on top
              PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => _buildPage(
                  _onboardingData[index],
                  height,
                  width,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPage(
      OnboardingData onboardingData, double height, double width) {
    final verticalSpacing = height * 0.02;
    final imageHeight = height * 0.30;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            _topBar(width),
            SizedBox(height: verticalSpacing),
            SvgPicture.asset(
              onboardingData.imagePath,
              height: imageHeight,
              width: width * 0.8,
              fit: BoxFit.contain,
            ),
            SizedBox(height: verticalSpacing * 8),
            Expanded(
              child: _buildInfoWidget(onboardingData, height, width),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: _currentPage != 0,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: InkWell(
              child: SvgPicture.asset(
                Assets.arrowLeft,
                color: ColorManager.colorOfArrows,
              ),
              onTap: () => _pageController.animateToPage(
                --_currentPage,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              prefs.setBool(kIsOnBoardingViewSeen, true);
              Navigator.pushReplacementNamed(context, SignInView.routeName);
            },
            child: Text(
              'Skip',
              style: TextStyles.skip,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoWidget(
      OnboardingData onboardingData, double height, double width) {
    final verticalSpacing = height * 0.025;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            onboardingData.title,
            style: TextStyles.title,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: verticalSpacing),
          Container(
            constraints: BoxConstraints(
              maxWidth: width * 0.85,
            ),
            child: Text(
              onboardingData.description,
              style: TextStyles.description,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: verticalSpacing * 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _onboardingData
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e == onboardingData
                            ? ColorManager.primaryColor
                            : ColorManager.primaryColor.withAlpha(80),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: verticalSpacing * 1.5),
          GestureDetector(
            child: SvgPicture.asset(Assets.onboardingButton),
            onTap: () {
              if (_currentPage == _onboardingData.length - 1) {
                prefs.setBool(kIsOnBoardingViewSeen, true);
                Navigator.pushReplacementNamed(context, SignInView.routeName);
              } else {
                _pageController.animateToPage(
                  ++_currentPage,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                );
              }
            },
          ),
          SizedBox(height: verticalSpacing),
        ],
      ),
    );
  }
}
