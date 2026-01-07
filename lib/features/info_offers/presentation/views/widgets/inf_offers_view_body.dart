import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/cubits/offers_cubit/offers_cubit.dart';
import 'package:pharma_now/features/info_offers/presentation/views/widgets/info_offers_list_view_bloc_builder.dart';

import '../../../../order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';

class InfoOffersListViewBody extends StatefulWidget {
  const InfoOffersListViewBody({super.key});

  @override
  _InfoOffersListViewBodyState createState() => _InfoOffersListViewBodyState();
}

class _InfoOffersListViewBodyState extends State<InfoOffersListViewBody> {
  @override
  void initState() {
    super.initState();

    context.read<OffersCubit>().getMedicinesoffers();
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
        } else if (state is CartItemRemoved) {
          showCustomBar(
            context,
            'Removed from cart',
            duration: const Duration(seconds: 1),
            type: MessageType.success,
          );
        } else if (state is CartError) {
          showCustomBar(
            context,
            state.message,
            duration: const Duration(seconds: 2),
            type: MessageType.error,
          );
        }
      },
      child: Column(
        children: [
          Expanded(child: InfoOffersListViewBlocBuilder()),
        ],
      ),
    );
  }
}
