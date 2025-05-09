import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/offers/presentation/views/widgets/inf_offers_view_body.dart';
import '../../../../core/cubits/offers_cubit/offers_cubit.dart';
import '../../../../core/repos/medicine_repo/medicine_repo.dart'
    show MedicineRepo;
import '../../../../core/services/get_it_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/offers/presentation/views/widgets/inf_offers_view_body.dart';
import '../../../../core/cubits/offers_cubit/offers_cubit.dart';
import '../../../../core/repos/medicine_repo/medicine_repo.dart'
    show MedicineRepo;
import '../../../../core/services/get_it_service.dart';
import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../home/presentation/views/main_view.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key});

  static const routeName = 'OffersView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
            title: 'Offers',
            isBack: true,
            onPressed: () {
              Navigator.pushReplacementNamed(context, MainView.routeName);
            }),
      ),
      body: BlocProvider(
        create: (context) => OffersCubit(getIt.get<MedicineRepo>()),
        child: const InfoOffersListViewBody(),
      ),
    );
  }
}
