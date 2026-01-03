import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/medicine_details_view_body.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/core/widgets/premium_loading_indicator.dart';

import '../../../../core/utils/app_images.dart';

class MedicineDetailsView extends StatelessWidget {
  static const String routeName = "ProductView";

  final MedicineEntity? medicineEntity;
  final bool fromCart;
  final bool fromFavorites;

  const MedicineDetailsView({
    super.key,
    this.medicineEntity,
    this.fromCart = false,
    this.fromFavorites = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.instance<CartCubit>(),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final isLoading = state is CartLoading || state is CartInitial;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: isLoading
                ? null
                : AppBar(
                    centerTitle: true,
                    backgroundColor: ColorManager.secondaryColor,
                    title: const Text(
                      "Details",
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: IconButton(
                      onPressed: () {
                        if (fromCart || fromFavorites) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(
                              context, MainView.routeName);
                        }
                      },
                      icon: SvgPicture.asset(
                        Assets.arrowLeft,
                        width: 24,
                        height: 24,
                        color: ColorManager.primaryColor,
                      ),
                    ),
                  ),
            body: isLoading
                ? const Center(child: PremiumLoadingIndicator())
                : medicineEntity != null
                    ? MedicineDetailsViewBody(
                        medicineEntity: medicineEntity!,
                        fromCart: fromCart,
                        fromFavorites: fromFavorites,
                      )
                    : const Center(
                        child: Text('Medicine details not available')),
          );
        },
      ),
    );
  }
}
