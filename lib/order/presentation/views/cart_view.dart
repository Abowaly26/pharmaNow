import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/order/presentation/cubits/cart_item_cubit/cart_item_cubit.dart';
import 'package:pharma_now/order/presentation/views/widgets/cart_view_body.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';

import '../../../core/utils/color_manger.dart';
import '../../../core/widgets/custom_app_bar.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});
  static const routeName = 'CartView';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartItemCubit(),
      child: Scaffold(
        backgroundColor: ColorManager.primaryColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48.sp),
          child: PharmaAppBar(
            title: 'Cart',
          ),
        ),
        body: CartViewBody(),
      ),
    );
  }
}
