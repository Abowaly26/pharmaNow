import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_styles.dart';

class InActiveStepItem extends StatelessWidget {
  const InActiveStepItem({super.key, required this.text, required this.index});
  final String text;
  final String index;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: Color(0xffF2F3F3),
          child: Text(index,style: TextStyles.semiBold13.copyWith(color: ColorManager.blackColor),)
        ),
        SizedBox(width: 4,),
        Text(text,style: TextStyle(color:Color(0xffAAAAAA),
          fontSize: 14,fontFamily: "Cairo",
          fontWeight: FontWeight.w700,
          height: 0,

        ),)
      ],
    );
  }
}
