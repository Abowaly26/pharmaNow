import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/constants.dart';
import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/features/auth/presentation/views/singn_in_view.dart';

import '../../../../core/utils/color_manger.dart';
import '../../../../core/utils/text_style.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // Get responsive dimensions based on screen constraints
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildCard(),
                      ],
                    ),
                  )
                ],
              ),
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
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPage(
      OnboardingData onboardingData, double height, double width) {
    // Use proportional spacing for consistent appearance across screen sizes
    final verticalSpacing = height * 0.03;
    final imageHeight = height * 0.35;

    return Column(
      children: [
        _topBar(width),
        SizedBox(height: verticalSpacing * 2),
        SvgPicture.asset(
          onboardingData.imagePath,
          height: imageHeight,
          width: width * 0.8,
          fit: BoxFit.contain,
        ),
        SizedBox(height: verticalSpacing * 3),
        _buildInfoWidget(onboardingData, height, width)
      ],
    );
  }

  Widget _topBar(double width) {
    // Use fractional values for consistent spacing
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

  Widget _buildCard() {
    return Expanded(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            width: double.infinity,
            child: SvgPicture.asset(
              Assets.informationCard,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoWidget(
      OnboardingData onboardingData, double height, double width) {
    // Calculate spacing based on screen height for consistent proportions
    final verticalSpacing = height * 0.03;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: verticalSpacing,
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              onboardingData.title,
              style: TextStyles.title,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: verticalSpacing),
            Container(
              constraints: BoxConstraints(
                maxWidth: width * 0.9,
              ),
              child: Text(
                onboardingData.description,
                style: TextStyles.description,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: verticalSpacing),
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
            SizedBox(height: verticalSpacing),
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
            )
          ],
        ),
      ),
    );
  }
}
