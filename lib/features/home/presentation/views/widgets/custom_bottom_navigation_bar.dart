import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ui_model/entities/bottom_navigation_bar_entity.dart';
import '../../ui_model/navigation_bar_item.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.onItemTapped,
    this.initialIndex = 0,
  });

  final ValueChanged<int> onItemTapped;
  final int initialIndex;

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.initialIndex;

    // Advanced animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Sophisticated scale animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390.w, // Full-width with slight padding
      height: 65.h, // Increased height for more comfort

      decoration: BoxDecoration(
        color: Color(0xFFF7FAFF), // Changed to white for cleaner look
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20.r,
            offset: const Offset(0, -3),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: bottomNavigationBarEntity.asMap().entries.map((e) {
          var index = e.key;
          var entity = e.value;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Trigger animation and state update
                _animationController.forward(from: 0.0);
                setState(() {
                  selectedIndex = index;
                  widget.onItemTapped(index);
                });
              },
              child: Center(
                child: NavigationBarItem(
                  isSelected: selectedIndex == index,
                  bottomNavigationBarEntity: entity,
                  animation: _scaleAnimation,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
