import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

import '../../../../../core/utils/text_styles.dart';
import 'UnSelectedItem.dart';
import 'isSelecteditem.dart';

class ShipingItem extends StatelessWidget {
  const ShipingItem({super.key, required this.title, required this.subtitle,
    required this.price,
   required this.isSelected, required this.onTap});
 final String title,subtitle,price;
 final isSelected;
 final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.only(
          top:16 ,
          left: 13,
          right: 28,
          bottom: 16,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Color(0x33D9D9D9),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                   color: isSelected? ColorManager.secondaryColor
                  :  Colors.transparent
              ),
                borderRadius:BorderRadius.circular(4)
            )
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isSelected? Isselecteditem():
              Unselecteditem(),
              SizedBox(width: 10,),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                  style: TextStyles.semiBold13,
                  ),
                  SizedBox(height: 6,),
                  Text(subtitle,
                  style: AppStyles.regular12Text.copyWith(color: Colors.black.withOpacity(.5)),
                  ),
                ],
              ),
              Spacer(),
              Center(
                child: Text("$price EGP",
                  style:AppStyles.bold(13).copyWith(color:ColorManager.secondaryColor ) ,),
              )
            ],
          ),
        ),
      ),
    ) ;
  }
}






//Container(
//       width: 343,
//       height: 81,
//       padding: EdgeInsets.only(
//         top:16 ,
//         left: 13,
//         right: 28,
//         bottom: 16,
//       ),
//       clipBehavior: Clip.antiAlias,
//       decoration: ShapeDecoration(
//           shape: RoundedRectangleBorder()
//
//       ),
//     )