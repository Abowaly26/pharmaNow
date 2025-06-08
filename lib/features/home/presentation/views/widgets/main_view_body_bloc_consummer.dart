import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/main_view_body.dart';

import '../../../../../Cart/presentation/cubits/cart_cubit/cart_cubit.dart';

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
        if (state is CartMedicineAdded) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              textAlign: TextAlign.center,
              'Added to cart',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            backgroundColor: const Color.fromARGB(255, 109, 193, 111),
            width: MediaQuery.of(context).size.width * 0.4,

            // Makes it narrower
            behavior: SnackBarBehavior.floating,
            // This makes it float and allows width customization
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
            duration: const Duration(seconds: 1),
          ));
        }
      },
      child: MainViewbody(CurrentViewIndex: CurrentViewIndex),
    );
  }
}
