import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/cubits/offers_cubit/offers_cubit.dart';
import 'package:pharma_now/features/info_offers/presentation/views/widgets/info_offers_list_view_bloc_builder.dart';

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
    return Column(
      children: const [
        Expanded(child: InfoOffersListViewBlocBuilder()),
      ],
    );
  }
}
