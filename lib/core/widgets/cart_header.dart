import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

class CartHeader extends StatelessWidget {
  const CartHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 233, 232, 252)),
      child: Center(
        child: Text(
          'you have items in your cart',
          style: TextStyle(
            color: ColorManager.secondaryColor.withOpacity(0.9),
            fontSize: 14.sp,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w400,
            height: 0.12,
          ),
        ),
      ),
    );
  }
}
