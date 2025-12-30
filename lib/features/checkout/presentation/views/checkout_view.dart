import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/checkout_view_body.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/features/cart/di/cart_injection.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pharma_now/core/widgets/custom_loading_overlay.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});
  static const routeName = "checkoutV";

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  bool _isProcessing = false;

  void _onProcessingChanged(bool value) {
    setState(() {
      _isProcessing = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartCubit>.value(
      value: getIt<CartCubit>(),
      child: CustomLoadingOverlay(
        isLoading: _isProcessing,
        title: 'Processing Order',
        subtitle: 'Securely verifying your details and placing your order...',
        icon: Icons.shopping_cart_outlined,
        child: Scaffold(
          backgroundColor: ColorManager.primaryColor,
          resizeToAvoidBottomInset: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48.sp),
            child: PharmaAppBar(
              title: 'Checkout',
              isBack: !_isProcessing,
              onPressed: _isProcessing
                  ? null
                  : () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.pop(context);
                    },
            ),
          ),
          body: CheckoutViewBody(
            onProcessingChanged: _onProcessingChanged,
          ),
        ),
      ),
    );
  }
}
