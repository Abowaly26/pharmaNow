import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/helper_functions/show_custom_bar.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:get_it/get_it.dart';

class CartSnackBarListener extends StatelessWidget {
  final Widget child;

  const CartSnackBarListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        // Use the navigator's context to ensure we have access to Overlay and Navigator
        final navigatorKey = GetIt.instance<GlobalKey<NavigatorState>>();
        final targetContext = navigatorKey.currentContext ?? context;

        if (state is CartItemAdded) {
          showCustomBar(
            targetContext,
            'Added to cart successfully',
            type: MessageType.success,
          );
        } else if (state is CartItemRemoved) {
          showCustomBar(
            targetContext,
            'Removed "${state.removedItem.medicineEntity.name}"',
            type: MessageType.info,
            actionLabel: 'Undo',
            onAction: () {
              context.read<CartCubit>().undoDeleteMedicine(state.removedItem);
            },
          );
        } else if (state is CartError) {
          showCustomBar(
            targetContext,
            state.message,
            type: MessageType.error,
          );
        }
      },
      child: child,
    );
  }
}
