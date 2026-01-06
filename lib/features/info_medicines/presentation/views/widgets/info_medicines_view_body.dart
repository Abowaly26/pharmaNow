import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/cubits/medicines_cubit/medicine_cubit.dart';
import 'package:pharma_now/features/info_medicines/presentation/views/widgets/info_medicines_list_view_bloc_builder.dart';

import '../../../../order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';

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
      },
      child: Column(
        children: const [
          Expanded(child: MedicinesListViewBlocBuilder()),
        ],
      ),
    );
  }
}
