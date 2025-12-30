import 'package:flutter/material.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

class ActiveItem extends StatelessWidget {
  const ActiveItem({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 11.5,
          backgroundColor: ColorManager.secondaryColor,
          child: Icon(
            Icons.check,
            color: ColorManager.primaryColor,
            size: 18,
          ),
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            color: ColorManager.secondaryColor,
            fontSize: 14,
            fontFamily: "Cairo",
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        )
      ],
    );
  }
}
