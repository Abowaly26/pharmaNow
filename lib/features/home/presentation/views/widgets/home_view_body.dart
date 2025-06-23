import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';

import 'package:pharma_now/features/home/presentation/views/widgets/medicines_list_view_bloc_builder.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view_bloc_builder.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/section_widget.dart';

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

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  PageController? _bannerController;
  int _currentBannerIndex = 0;
  bool _isDisposed = false;

  // Sample banner data
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
      overlayImage: Assets.medicineAmico,
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  void _initializeComponents() {
    try {
      WidgetsBinding.instance.addObserver(this);
      _bannerController = PageController(initialPage: 0);
      _loadData();
    } catch (e) {
      debugPrint('Error initializing components: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    try {
      if (state == AppLifecycleState.resumed && !_isDisposed && mounted) {
        _loadData();
      }
    } catch (e) {
      debugPrint('Error in lifecycle change: $e');
    }
  }

  void _loadData() {
    try {
      if (!mounted || _isDisposed) return;

      final medicinesCubit = context.read<MedicinesCubit>();
      final offersCubit = context.read<OffersCubit>();

      medicinesCubit.getMedicines();
      offersCubit.getMedicinesoffers();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _onRefresh() async {
    try {
      _loadData();
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('Error refreshing: $e');
    }
  }

  void _navigateToSearch() {
    try {
      if (!mounted) return;
      Navigator.pushNamed(context, SearchView.routeName);
    } catch (e) {
      debugPrint('Error navigating to search: $e');
    }
  }

  void _navigateToOffers() {
    try {
      if (!mounted) return;
      Navigator.pushNamed(context, OffersView.routeName);
    } catch (e) {
      debugPrint('Error navigating to offers: $e');
    }
  }

  void _navigateToMedicines() {
    try {
      if (!mounted) return;
      Navigator.pushNamed(context, InfoMedicinesView.routeName);
    } catch (e) {
      debugPrint('Error navigating to medicines: $e');
    }
  }

  void _onBannerPageChanged(int index) {
    try {
      if (!mounted || _isDisposed) return;
      setState(() {
        _currentBannerIndex = index;
      });
    } catch (e) {
      debugPrint('Error changing banner page: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    try {
      WidgetsBinding.instance.removeObserver(this);
      _bannerController?.dispose();
    } catch (e) {
      debugPrint('Error disposing: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: ColorManager.secondaryColor,
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildBannerSlider(),
                _buildOffersSection(),
                const OffersListViewBlocBuilder(),
                SizedBox(height: 8.h),
                _buildMedicinesSection(),
                const MedicineListViewBlocBuilder(),
                SizedBox(height: 48.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: BlocProvider(
        create: (context) => GetIt.instance<SearchCubit>(),
        child: Searchtextfield(
          readOnly: true,
          onTap: _navigateToSearch,
        ),
      ),
    );
  }

  Widget _buildOffersSection() {
    return SectionWidget(
      sectionTitle: 'Offers',
      onTap: _navigateToOffers,
    );
  }

  Widget _buildMedicinesSection() {
    return SectionWidget(
      sectionTitle: 'Medicines',
      onTap: _navigateToMedicines,
    );
  }

  Widget _buildBannerSlider() {
    if (_banners.isEmpty) {
      return SizedBox(height: 200.h);
    }

    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: _onBannerPageChanged,
            itemBuilder: (context, index) {
              if (index >= _banners.length) return const SizedBox.shrink();
              return _buildBannerItem(_banners[index]);
            },
          ),
        ),
        SizedBox(height: 8.h),
        _buildBannerIndicators(),
      ],
    );
  }

  Widget _buildBannerIndicators() {
    return Row(
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
    );
  }

  Widget _buildBannerItem(BannerItem banner) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Stack(
        children: [
          // Background banner
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

          // Overlay image
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

          // Text content
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
                  onPressed: () {
                    // Add your button logic here
                  },
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
          child: const Center(
            child: Icon(Icons.image_not_supported),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error loading SVG: $e');
      return Container(
        color: ColorManager.secondaryColor.withOpacity(0.1),
        child: const Center(
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
