import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';

import 'package:pharma_now/features/home/presentation/views/widgets/medicines_list_view_bloc_builder.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view_bloc_builder.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/section_widget.dart';

import '../../../../../core/cubits/best_selling_cubit/best_selling_cubit.dart';
import '../../../../../core/cubits/medicines_cubit/medicine_cubit.dart';
import '../../../../../core/cubits/offers_cubit/offers_cubit.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_styles.dart';
import '../../../../../core/widgets/searchtextfield.dart';
import '../../../../info_medicines/presentation/views/info_medicines_view.dart';
import '../../../../search/presentation/cubit/cubit/search_cubit.dart';
import '../../../../search/presentation/views/search_view.dart';

import '../../../../info_offers/presentation/views/info_offers_view.dart';
import 'best_selling_list_view_bloc_builder.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  // Controller for the banner PageView
  late PageController _bannerController;
  int _currentBannerIndex = 0;

  // For refreshing state control
  final RefreshController _refreshController = RefreshController();

  // Sample banner data - you can replace this with your actual data
  final List<BannerItem> _banners = [
    BannerItem(
      image: Assets.rectangleBanner,
      title: 'Discount',
      discount: '50%',
      buttonText: 'Buy Now',
      overlayImage: Assets.medicineBro, // Add your overlay image asset here
    ),
    BannerItem(
      image: Assets.rectangleBanner,
      title: 'Special',
      discount: '30%',
      buttonText: 'Shop Now',
      overlayImage: Assets.publicHealth, // Add your overlay image asset here
    ),
    BannerItem(
      image: Assets.rectangleBanner,
      title: 'New Arrival',
      discount: '20%',
      buttonText: 'Explore',
      overlayImage: Assets.medicineAmico, // Add your overlay image asset here
    ),
  ];

  @override
  void initState() {
    _bannerController = PageController(initialPage: 0);
    _loadData();
    // Auto-sliding functionality
    _startAutoSlide();

    super.initState();
  }

  // Function to load data
  void _loadData() {
    context.read<MedicinesCubit>().getMedicines();
    context.read<BestSellingCubit>().getBestSellingMedicines();
    context.read<OffersCubit>().getMedicinesoffers();
  }

  // Function to handle refresh event
  Future<void> _onRefresh() async {
    // Reload all data
    _loadData();

    // Wait to complete the refresh (adjust time as needed)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Complete refresh and stop loading indicator
    _refreshController.refreshCompleted();
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (_currentBannerIndex < _banners.length - 1) {
          _currentBannerIndex++;
        } else {
          _currentBannerIndex = 0;
        }

        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );

        _startAutoSlide();
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: const WaterDropHeader(
          waterDropColor: ColorManager.secondaryColor,
          complete: Icon(Icons.check, color: ColorManager.secondaryColor),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: BlocProvider(
                  create: (context) => GetIt.instance<SearchCubit>(),
                  child: Searchtextfield(
                    readOnly: true,
                    onTap: () {
                      Navigator.pushNamed(context, SearchView.routeName);
                    },
                  ),
                ),
              ),
              _buildBannerSlider(),
              SectionWidget(
                sectionTitle: 'Offers',
                onTap: () {
                  Navigator.pushNamed(context, OffersView.routeName);
                },
              ),
              OffersListViewBlocBuilder(),
              SizedBox(
                height: 8,
              ),
              SectionWidget(
                sectionTitle: 'Medicines',
                onTap: () {
                  Navigator.pushNamed(
                      context, InfoMedicinesView.routeName);
                },
              ),
              MedicineListViewBlocBuilder(),

              // Best selling section with BlocBuilder to check data availability
              BlocBuilder<BestSellingCubit, BestSellingState>(
                builder: (context, state) {
                  if (state is BestSellingSuccess &&
                      state.medicines.isNotEmpty) {
                    // Show best selling section only if data exists
                    return Column(
                      children: [
                        SectionWidget(
                          sectionTitle: 'Best selling',
                          onTap: () {
                            Navigator.pushNamed(
                                context, OffersView.routeName);
                          },
                        ),
                        BestSellingListViewBlocBuilder(),
                      ],
                    );
                  } else {
                    // If no data, don't show anything
                    return SizedBox();
                  }
                },
              ),
              SizedBox(
                height: 48,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 200.h, // Adjust height as needed
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildBannerItem(_banners[index]);
            },
          ),
        ),
        SizedBox(height: 8.h),
        // Banner indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => Container(
              width: 8.w,
              height: 8.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBannerIndex == index
                    ? ColorManager.secondaryColor.withOpacity(0.88)
                    : ColorManager.colorOfsecondPopUp.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(BannerItem banner) {
    return Stack(
      children: [
        // Background banner
        Container(
          width: double.infinity,
          height: 180.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SvgPicture.asset(
              width: double.infinity,
              banner.image,
              fit: BoxFit.fill,
            ),
          ),
        ),

        // Overlay image (positioned where you want it)
        if (banner.overlayImage != null)
          Positioned(
            top: 6.h,
            right: 20.w,
            child: Container(
              height: 173.h,
              width: 173.w,
              child: SvgPicture.asset(
                banner.overlayImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),

        // Text content (already in your code)
        Positioned(
          top: 16.h,
          left: 16.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}

// Banner data model
class BannerItem {
  final String image;
  final String title;
  final String discount;
  final String buttonText;
  final String? overlayImage; // New field for overlay image

  BannerItem({
    required this.image,
    required this.title,
    required this.discount,
    required this.buttonText,
    this.overlayImage, // Optional overlay image
  });
}

// Custom refresh controller class
class RefreshController {
  bool _isRefreshing = false;
  bool _isLoading = false;

  bool get isRefreshing => _isRefreshing;
  bool get isLoading => _isLoading;

  void refreshCompleted() {
    _isRefreshing = false;
  }

  void loadComplete() {
    _isLoading = false;
  }

  void refreshFailed() {
    _isRefreshing = false;
  }

  void loadFailed() {
    _isLoading = false;
  }

  void requestRefresh() {
    if (_isRefreshing) return;
    _isRefreshing = true;
  }

  void requestLoading() {
    if (_isLoading) return;
    _isLoading = true;
  }

  void dispose() {
    // Nothing to dispose
  }
}

// Custom pull-to-refresh widget
class SmartRefresher extends StatefulWidget {
  final Widget child;
  final RefreshController controller;
  final Future<void> Function() onRefresh;
  final Widget header;

  const SmartRefresher({
    Key? key,
    required this.child,
    required this.controller,
    required this.onRefresh,
    required this.header,
  }) : super(key: key);

  @override
  State<SmartRefresher> createState() => _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await widget.onRefresh(),
      backgroundColor: Colors.white,
      color: ColorManager.secondaryColor,
      displacement: 20.0,
      strokeWidth: 2.5,
      child: widget.child,
    );
  }
}

// Custom water drop header widget
class WaterDropHeader extends StatelessWidget {
  final Color waterDropColor;
  final Widget complete;

  const WaterDropHeader({
    Key? key,
    required this.waterDropColor,
    required this.complete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox
        .shrink(); // Hide this element as we're using built-in RefreshIndicator
  }
}
