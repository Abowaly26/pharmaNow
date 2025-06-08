import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/Cart/presentation/views/widgets/cart_items_list.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/widgets/cart_header.dart';
import 'package:pharma_now/core/widgets/cart_item.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/text_styles.dart';
import '../../cubits/cart_cubit/cart_cubit.dart';

class CartViewBody extends StatelessWidget {
  const CartViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  CartHeader(),
                ],
              ),
            ),
            CartItemsList(
                cartItems: context.read<CartCubit>().cartEntity.cartItems),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
        Positioned(
          bottom: MediaQuery.sizeOf(context).height * 0.035.h,
          left: 16.w,
          right: 16.w,
          child: ElevatedButton(
            style: ButtonStyles.primaryButton,
            onPressed: () {},
            child: Text(
              'pay ${context.watch<CartCubit>().cartEntity.calculateTotalPrice()} EGP',
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
