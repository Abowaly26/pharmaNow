import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';
import 'package:pharma_now/features/info_medicines/presentation/views/widgets/info_medicines_view_body.dart';
import '../../../../core/cubits/medicines_cubit/medicine_cubit.dart';
import '../../../../core/repos/medicine_repo/medicine_repo.dart'
    show MedicineRepo;
import '../../../../core/services/get_it_service.dart';
import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'package:pharma_now/Cart/presentation/cubits/cart_cubit/cart_cubit.dart';

class InfoMedicinesView extends StatelessWidget {
  const InfoMedicinesView({super.key});

  static const routeName = 'NewMedicinesView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Medicines',
          isBack: true,
          onPressed: () {
            Navigator.pushReplacementNamed(context, MainView.routeName);
          },
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider<MedicinesCubit>(
            create: (context) => MedicinesCubit(getIt.get<MedicineRepo>()),
          ),
          BlocProvider<CartCubit>.value(
            value: getIt<CartCubit>(),
          ),
        ],
        child: const InfoMedicinesViewBody(),
      ),
    );
  }
}
