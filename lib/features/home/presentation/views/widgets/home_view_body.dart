import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/category_list_view.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/category_widget.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/medicines_list_view.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/medicines_list_view_bloc_builder.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view_bloc_builder.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view_item.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/section_widget.dart';

import '../../../../../core/cubits/medicines_cubit/medicine_cubit.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_style.dart';
import '../../../../new products/presentation/views/new_products_view.dart';
import '../../../../offers/presentation/views/offers_view.dart';
import '../../../../shopping by category/presentation/views/categories_view.dart';
import '../medicine_details_view.dart';
import 'best_selling_list_view.dart';
import 'best_selling_list_view_bloc_builder.dart';
import 'medicines_list_view_item.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  // Controller for the banner PageView
  late PageController _bannerController;
  int _currentBannerIndex = 0;

  // Sample banner data - you can replace this with your actual data
  final List<BannerItem> _banners = [
    BannerItem(
      image: Assets.home_bannner,
      title: 'Discount',
      discount: '50%',
      buttonText: 'Buy Now',
    ),
    BannerItem(
      image: Assets.home_bannner, // Replace with other banner images
      title: 'Special',
      discount: '30%',
      buttonText: 'Shop Now',
    ),
    BannerItem(
      image: Assets.home_bannner, // Replace with other banner images
      title: 'New Arrival',
      discount: '20%',
      buttonText: 'Explore',
    ),
  ];

  @override
  void initState() {
    _bannerController = PageController(initialPage: 0);
    context.read<MedicineCubit>().getMedicines();
    context.read<MedicineCubit>().getBestSellingMedicines();
    context.read<MedicineCubit>().getMedicinesoffers();

    // Auto-sliding functionality
    _startAutoSlide();

    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerSlider(),
            // SectionWidget(
            //   sectionTitle: 'Categories',
            //   onTap: () {
            //     Navigator.pushReplacementNamed(
            //         context, CategoriesView.routeName);
            //   },
            // ),
            // CategoriesListView(),

            SectionWidget(
              sectionTitle: 'Best selling',
              onTap: () {
                Navigator.pushReplacementNamed(context, OffersView.routeName);
              },
            ),

            BestSellingListViewBlocBuilder(),
            SectionWidget(
              sectionTitle: 'Offers',
              onTap: () {
                Navigator.pushReplacementNamed(context, OffersView.routeName);
              },
            ),

            OffersListViewBlocBuilder(),
            SizedBox(
              height: 8,
            ),

            SectionWidget(
              sectionTitle: 'Medicines',
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, NewProductView.routeName);
              },
            ),
            MedicineListViewBlocBuilder(),
            SizedBox(
              height: 48,
            )
          ],
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
        Container(
          width: double.infinity,
          height: 1800.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              width: double.infinity,
              banner.image,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
          top: 30,
          left: 42,
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

  BannerItem({
    required this.image,
    required this.title,
    required this.discount,
    required this.buttonText,
  });
}
