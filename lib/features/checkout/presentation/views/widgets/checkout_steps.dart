import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/active_item.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/inactive_item.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/step_item.dart';
import 'package:pharma_now/features/home/presentation/ui_model/in_active_item.dart';

import '../../../../../core/utils/color_manger.dart';

class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({
    super.key,
    required this.currentPage,
    required this.pageController,
  });

  final int currentPage;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        namedSteps.length,
        (index) => Expanded(
          child: GestureDetector(
            onTap: () {
              if (index <= currentPage) {
                pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Left connector (transparent for the first step)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index == 0
                              ? Colors.transparent
                              : (index <= currentPage
                                  ? ColorManager.secondaryColor
                                  : Colors.grey[300]),
                        ),
                      ),
                      _buildStepCircle(index),
                      // Right connector (transparent for the last step)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index == namedSteps.length - 1
                              ? Colors.transparent
                              : (index < currentPage
                                  ? ColorManager.secondaryColor
                                  : Colors.grey[300]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    namedSteps[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: index <= currentPage
                          ? ColorManager.secondaryColor
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(int index) {
    bool isActive = index <= currentPage;
    bool isCompleted = index < currentPage;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? ColorManager.secondaryColor : Colors.grey[300],
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: ColorManager.secondaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              )
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}

List<String> namedSteps = ["Delivery", "Address", "Payment"];
