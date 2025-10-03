import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:pharma_now/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/custom_bottom_navigation_bar.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/home_appbar.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/main_view_body_bloc_consummer.dart';

import '../../../../order/presentation/views/cart_view.dart';
import '../../../../core/utils/color_manger.dart';
import '../../../favorites/presentation/views/favorites.dart';
import '../../../profile/presentation/views/profile_view.dart';
import 'widgets/main_view_body.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});
  static const routeName = 'MyHomePage';

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int CurrentViewIndex = 0;
  @override
  Widget build(BuildContext context) {
    final cartCubit = GetIt.instance<CartCubit>();

    return BlocProvider.value(
      value: cartCubit,
      child: Scaffold(
        extendBody: true,
        backgroundColor: ColorManager.primaryColor,
        appBar: CurrentViewIndex == 0
            ? PreferredSize(
                preferredSize: Size.fromHeight(80.h),
                child: HomeAppbar(),
              )
            : null,
        bottomNavigationBar: CustomBottomNavigationBar(
          onItemTapped: (int value) {
            CurrentViewIndex = value;
            setState(() {});
          },
        ),
        body: SafeArea(
          child: MainViewBodyBlocConsummer(
            CurrentViewIndex: CurrentViewIndex,
          ),
        ),
      ),
    );
  }
}















          //  Scaffold(
          //   extendBody: true,
          //   backgroundColor: ColorManager.primaryColor,
          //   appBar: _currentIndex == 0
          //       ? PreferredSize(
          //           preferredSize: Size.fromHeight(80.h),
          //           child: HomeAppbar(),
          //         )
          //       : null,
          //   // Display the currently selected screen based on _currentIndex
          //   body: _screens[_currentIndex],
          //   bottomNavigationBar: Theme(
          //     data: Theme.of(context).copyWith(
          //       iconTheme: const IconThemeData(color: Colors.white),
          //     ),
          //     child: CurvedNavigationBar(
          //       color: Color(0xFF5555FF),
          //       buttonBackgroundColor: Color(0xFF5555FF),
          //       backgroundColor: Colors.transparent,
          //       height: 58,
          //       animationCurve: Curves.bounceInOut,
          //       animationDuration: const Duration(milliseconds: 400),
          //       index: _currentIndex,
          //       items: _items,
          //       onTap: (index) => setState(() {
          //         _currentIndex = index;
          //       }),
          //     ),
          //   ),
          // ),