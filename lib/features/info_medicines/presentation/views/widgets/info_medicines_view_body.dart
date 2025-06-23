import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/cubits/medicines_cubit/medicine_cubit.dart';
import 'package:pharma_now/features/info_medicines/presentation/views/widgets/info_medicines_list_view_bloc_builder.dart';
import '../../../../../Cart/presentation/cubits/cart_cubit/cart_cubit.dart';

class InfoMedicinesViewBody extends StatefulWidget {
  const InfoMedicinesViewBody({super.key});

  @override
  _InfoMedicinesViewBodyState createState() => _InfoMedicinesViewBodyState();
}

class _InfoMedicinesViewBodyState extends State<InfoMedicinesViewBody> {
  @override
  void initState() {
    super.initState();
    context.read<MedicinesCubit>().getMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartItemAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added to cart',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: const Color.fromARGB(255, 109, 193, 111),
              width: MediaQuery.of(context).size.width * 0.4,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42),
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        if (state is CartItemRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Removed from cart',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: const Color.fromARGB(255, 109, 193, 111),
              width: MediaQuery.of(context).size.width * 0.4,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42),
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Column(
        children: const [
          Expanded(child: MedicinesListViewBlocBuilder()),
        ],
      ),
    );
  }
}
