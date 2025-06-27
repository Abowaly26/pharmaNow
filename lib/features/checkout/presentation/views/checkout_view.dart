import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/checkout_view_body.dart';

import '../../../../Cart/presentation/views/cart_view.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});
  static const routeName = "checkoutV";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PharmaAppBar(
        title: 'shipping',
        isBack: true,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: CheckoutViewBody(),
    );
  }
}
