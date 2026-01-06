import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import 'package:pharma_now/features/home/presentation/views/widgets/medicines_list_view_bloc_builder.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view_bloc_builder.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/section_widget.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/banner_slider.dart';

import '../../../../../core/cubits/medicines_cubit/medicine_cubit.dart';
import '../../../../../core/cubits/offers_cubit/offers_cubit.dart';
import '../../../../../core/utils/color_manger.dart';
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
  bool _isDisposed = false;

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
      _loadData();
    } catch (e) {
      debugPrint('Error initializing components: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    try {
      if (state == AppLifecycleState.resumed) {
        if (mounted && !_isDisposed) {
          _loadData();
        }
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

  @override
  void dispose() {
    _isDisposed = true;
    try {
      WidgetsBinding.instance.removeObserver(this);
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
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                _buildSearchBar(),
                SizedBox(height: 4.h),
                const BannerSlider(),
                SizedBox(height: 4.h),
                _buildOffersSection(),
                SizedBox(height: 4.h),
                const OffersListViewBlocBuilder(),
                SizedBox(height: 8.h),
                _buildMedicinesSection(),
                SizedBox(height: 4.h),
                const MedicineListViewBlocBuilder(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
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
}
