import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/cubits/medicine_cubit/medicine_cubit.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/category_widget.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/home_view_body.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/new%20_products_list_view_item.dart';
import 'package:pharma_now/features/home/presentation/views/product_view.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/section_widget.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view_item.dart';
import 'package:pharma_now/features/new%20products/presentation/views/new_products_view.dart';
import 'package:pharma_now/features/offers/presentation/views/offers_view.dart';

import '../../../../../core/services/get_it_service.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_style.dart';
import '../../../../shopping by category/presentation/views/categories_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicineCubit(
        getIt.get<MedicineRepo>(),
      ),
      child: const HomeViewBody(),
    );
  }
}
