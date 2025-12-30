import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/cubits/medicines_cubit/medicine_cubit.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/home_view_body.dart';

import '../../../../../core/cubits/offers_cubit/offers_cubit.dart';
import '../../../../../core/services/get_it_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MedicinesCubit(getIt.get<MedicineRepo>()),
        ),
        BlocProvider(
          create: (context) => OffersCubit(getIt.get<MedicineRepo>()),
        ),
      ],
      child: const HomeViewBody(),
    );
  }
}
