import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/features/home/presentation/ui_model/active_item.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/bottom_navigation_bar_entity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/in_active_item.dart';

class NavigationBarItem extends StatelessWidget {
  const NavigationBarItem({
    super.key,
    required this.isSelected,
    required this.bottomNavigationBarEntity,
    required this.animation,
  });

  final bool isSelected;
  final BottomNavigationBarEntity bottomNavigationBarEntity;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? animation.value : 1.0,
          child: isSelected
              ? ActiveItem(
                  text: bottomNavigationBarEntity.label,
                  image: bottomNavigationBarEntity.activeImage,
                )
              : InActiveItem(
                  image: bottomNavigationBarEntity.inActiveImage,
                ),
        );
      },
    );
  }
}
