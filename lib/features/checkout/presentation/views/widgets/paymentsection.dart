import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/paymentitem.dart';

class PaymentSection extends StatelessWidget {
  const PaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        PaymentItem(
            title: "application summary",
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "subtotal :",
                      style: AppStyles.regular(14, color: Color(0xFF4E5556)),
                    ),
                    Spacer(),
                    Text(
                      "150 EGP",
                      style: AppStyles.semi16TextWhite
                          .copyWith(color: ColorManager.blackColor),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "delivery :",
                      style: AppStyles.regular(14, color: Color(0xFF4E5556)),
                    ),
                    Spacer(),
                    Text(
                      "30 EGP",
                      style: AppStyles.semi16TextWhite
                          .copyWith(color: ColorManager.blackColor),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 1,
                  indent: 30,
                  endIndent: 30,
                  color: Color(0xffcacece),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Total",
                      style: AppStyles.bold(16),
                    ),
                    Spacer(),
                    Text(
                      "180 EGP",
                      style: AppStyles.bold(16),
                    ),
                  ],
                )
              ],
            ))
      ],
    );
  }
}
