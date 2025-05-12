import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/Cart/presentation/views/widgets/cart_view_body.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';

import '../../../core/utils/color_manger.dart';
import '../../../core/widgets/custom_app_bar.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});
  static const routeName = 'CartView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Cart',
        ),
      ),
      body: CartViewBody(),
    );
  }
}
