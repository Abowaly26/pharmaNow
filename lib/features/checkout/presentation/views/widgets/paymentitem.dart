import 'package:flutter/cupertino.dart';
import 'package:pharma_now/core/utils/appdecoration.dart';
import 'package:pharma_now/core/utils/text_styles.dart';

class PaymentItem extends StatelessWidget {
  const PaymentItem({super.key, required this.title, required this.child});
final String title;
final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,style: AppStyles.bold(14),),
        SizedBox(height: 8,),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16,horizontal: 8),
          decoration: AppDecoration.greyBoxDecoration,
          child:child ,
        )
      ],
    );
  }
}
