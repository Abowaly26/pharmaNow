import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/cubits/medicines_cubit/medicine_cubit.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/category_widget.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/home_view_body.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/medicines_list_view_item.dart';
import 'package:pharma_now/features/home/presentation/views/medicine_details_view.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/section_widget.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view_item.dart';
import 'package:pharma_now/features/info_medicines/presentation/views/info_medicines_view.dart';

import '../../../../../core/cubits/best_selling_cubit/best_selling_cubit.dart';
import '../../../../../core/cubits/offers_cubit/offers_cubit.dart';
import '../../../../../core/services/get_it_service.dart';
import '../../../../../core/utils/button_style.dart';

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
          create: (context) => BestSellingCubit(getIt.get<MedicineRepo>()),
        ),
        BlocProvider(
          create: (context) => OffersCubit(getIt.get<MedicineRepo>()),
        ),
      ],
      child: const HomeViewBody(),
    );
  }
}
