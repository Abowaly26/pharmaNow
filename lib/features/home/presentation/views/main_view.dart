import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/home_appbar.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/home_view.dart';

import '../../../../core/utils/color_manger.dart';
import '../../../favorites/presentation/views/favorites.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../../../search/presentation/views/search_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});
  static const routeName = 'MyHomePage';

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _items = [
    const Icon(Icons.home, size: 28),
    const Icon(Icons.search, size: 28),
    const Icon(Icons.favorite, size: 28),
    const Icon(Icons.person, size: 28),
  ];

  final List<Widget> _screens = [
    const HomeView(),
    const SearchView(),
    const FavoriteView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: ColorManager.primaryColor,
        appBar: _currentIndex == 0
            ? PreferredSize(
                preferredSize: Size.fromHeight(104.h),
                child: HomeAppbar(),
              )
            : null,
        // Display the currently selected screen based on _currentIndex
        body: _screens[_currentIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: CurvedNavigationBar(
            color: Color(0xFF4046FF),
            buttonBackgroundColor: Color(0xFF4046FF),
            backgroundColor: Colors.transparent,
            height: 58,
            animationCurve: Curves.bounceInOut,
            animationDuration: const Duration(milliseconds: 400),
            index: _currentIndex,
            items: _items,
            onTap: (index) => setState(() {
              _currentIndex = index;
            }),
          ),
        ),
      ),
    );
  }
}
