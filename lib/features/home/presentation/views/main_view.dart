import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/custom_bottom_navigation_bar.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/home_appbar.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/main_view_body_bloc_consummer.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/features/profile/presentation/providers/profile_provider.dart';

import '../../../../core/utils/color_manger.dart';
import 'package:pharma_now/core/widgets/custom_loading_overlay.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});
  static const routeName = 'MyHomePage';

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int currentViewIndex = 0;
  @override
  Widget build(BuildContext context) {
    final cartCubit = GetIt.instance<CartCubit>();

    return BlocProvider.value(
      value: cartCubit,
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final isNavigatingOut = profileProvider.isNavigatingOut;
          debugPrint('MainView: build - isNavigatingOut: $isNavigatingOut');

          return CustomLoadingOverlay(
            isLoading: isNavigatingOut,
            showCard: false,
            child: Scaffold(
              extendBody: true,
              backgroundColor: ColorManager.primaryColor,
              appBar: currentViewIndex == 0
                  ? PreferredSize(
                      preferredSize: Size.fromHeight(80.h),
                      child: HomeAppbar(),
                    )
                  : null,
              bottomNavigationBar: CustomBottomNavigationBar(
                onItemTapped: (int value) {
                  currentViewIndex = value;
                  setState(() {});
                },
              ),
              body: SafeArea(
                child: MainViewBodyBlocConsummer(
                  currentViewIndex: currentViewIndex,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
