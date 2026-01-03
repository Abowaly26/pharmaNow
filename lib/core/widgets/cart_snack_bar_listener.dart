import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/helper_functions/show_custom_bar.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';

class CartSnackBarListener extends StatelessWidget {
  final Widget child;

  const CartSnackBarListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartItemAdded) {
          showCustomBar(
            context,
            'Added to cart successfully',
            type: MessageType.success,
          );
        } else if (state is CartItemRemoved) {
          showCustomBar(
            context,
            'Removed from cart',
            type: MessageType.info,
          );
        } else if (state is CartError) {
          showCustomBar(
            context,
            state.message,
            type: MessageType.error,
          );
        }
      },
      child: child,
    );
  }
}
