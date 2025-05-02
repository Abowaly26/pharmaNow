import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/features/profile/presentation/views/profile_view.dart';

import '../../features/favorites/presentation/views/favorites.dart';
import '../../features/home/presentation/views/widgets/home_view.dart';

class NavigationBarddd extends StatelessWidget {
  const NavigationBarddd({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Nav());
  }
}

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int index = 2;

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0;

    final List<Widget> _items = [
      const Icon(Icons.home, size: 30),
      const Icon(Icons.favorite, size: 30),
      const Icon(Icons.chat, size: 30),
      const Icon(Icons.person, size: 30),
    ];

    final List<Widget> _screens = [
      const HomeView(), // Replace with your actual home content screen
      const FavoriteView(),
      // const ChatView(), // This was missing in your original code
      const ProfileView(),
    ];
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        child: CurvedNavigationBar(
          color: Colors.blue,
          buttonBackgroundColor: Colors.purple,
          backgroundColor: Colors.transparent,
          height: 60,
          animationCurve: Curves.bounceInOut,
          animationDuration: const Duration(milliseconds: 300),
          index: _currentIndex,
          items: _items,
          onTap: (index) => setState(() {
            _currentIndex = index;
          }),
        ),
      ),
    );
  }
}
