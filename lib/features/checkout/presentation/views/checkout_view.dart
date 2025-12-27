import 'package:flutter/material.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/checkout_view_body.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/features/cart/di/cart_injection.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});
  static const routeName = "checkoutV";

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartCubit>.value(
      value: getIt<CartCubit>(),
      child: Scaffold(
        backgroundColor: ColorManager.primaryColor,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48.sp),
          child: PharmaAppBar(
            title: 'Checkout',
            isBack: true,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: CheckoutViewBody(),
      ),
    );
  }
}
