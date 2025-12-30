import 'package:flutter/material.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

class Isselecteditem extends StatelessWidget {
  const Isselecteditem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: ShapeDecoration(
        color: ColorManager.secondaryColor,
          shape:OvalBorder(
              side: BorderSide(
                  width: 4,
                  color: Colors.white
              )
          ) ),
    );
  }
}
