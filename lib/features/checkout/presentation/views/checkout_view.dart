import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/checkout_view_body.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/features/cart/di/cart_injection.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

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
      child: Stack(
        children: [
          Scaffold(
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
          if (_isProcessing)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: Colors.black.withOpacity(0.12),
                  child: Center(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      elevation: 10,
                      child: Container(
                        width: 280.w,
                        padding: EdgeInsets.symmetric(
                            vertical: 32.h, horizontal: 24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 64.h,
                                  width: 64.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorManager.secondaryColor
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 64.h,
                                  width: 64.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorManager.secondaryColor),
                                  ),
                                ),
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  color: ColorManager.secondaryColor,
                                  size: 24.sp,
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'Processing Order',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 0.5,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Securely verifying your details and placing your order...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                height: 1.5,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_outline,
                                      size: 14.sp, color: Colors.grey[400]),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Secure Checkout',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
