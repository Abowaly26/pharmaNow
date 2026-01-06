import 'package:flutter/material.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/main_view_body.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';

class MainViewBodyBlocConsummer extends StatelessWidget {
  const MainViewBodyBlocConsummer({
    super.key,
    required this.CurrentViewIndex,
  });

  final int CurrentViewIndex;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartItemAdded) {
          showCustomBar(
            context,
            'Added to cart',
            duration: const Duration(seconds: 1),
            type: MessageType.success,
          );
        }
        if (state is CartItemRemoved) {
          showCustomBar(
            context,
            'Removed from cart',
            duration: const Duration(seconds: 1),
            type: MessageType.success,
          );
        }
        if (state is CartError) {
          showCustomBar(
            context,
            state.message,
            duration: const Duration(seconds: 2),
            type: MessageType.error,
          );
        }
      },
      child: MainViewbody(CurrentViewIndex: CurrentViewIndex),
    );
  }
}
