import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/widgets/cart_header.dart';
import 'package:pharma_now/core/widgets/premium_loading_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/checkout/presentation/views/checkout_view.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_item_cubit/cart_item_cubit.dart';

import 'package:pharma_now/features/order/presentation/views/widgets/cart_items_list.dart';

import '../../cubits/cart_cubit/cart_cubit.dart';

class CartViewBody extends StatelessWidget {
  const CartViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state is! CartLoaded && state is! CartInitial) {
          return const Center(
              child:
                  PremiumLoadingIndicator()); // Or some other loading/error state
        }
        final cartEntity = (state as dynamic).cartEntity as CartEntity;

        // Check if cart is empty
        if (cartEntity.cartItems.isEmpty) {
          return _buildEmptyCartState();
        }

        // Calculate original total price
        double originalTotal = cartEntity.calculateTotalPrice();

        // Calculate total discount (you can change this value as needed)
        double discountPercentage =
            _calculateTotalDiscount(cartEntity.cartItems);

        // Calculate final price after discount
        double finalTotal =
            _calculateFinalPrice(originalTotal, discountPercentage);

        return Column(
          children: [
            const CartHeader(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  CartItemsList(cartItems: cartEntity.cartItems),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 24.h),
                  ),
                ],
              ),
            ),
            // Fixed bottom container for checkout
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show price details if there's a discount
                    if (discountPercentage > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Original Price:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_formatPrice(originalTotal)} EGP',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Discount (${_formatPrice(discountPercentage)}%):',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            '-${_formatPrice(originalTotal - finalTotal)} EGP',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Divider(
                          height: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],

                    // Final checkout button
                    BlocListener<CartItemCubit, CartItemState>(
                      listener: (context, state) {},
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cartEntity.cartItems.isEmpty
                                ? Colors.grey.shade400
                                : ColorManager.secondaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, CheckoutView.routeName);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '${_formatPrice(finalTotal)} EGP',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget for empty cart state
  Widget _buildEmptyCartState() {
    return Column(
      children: [
        // Cart Header
        const CartHeader(),

        // Empty cart content
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Empty cart image
                Container(
                  width: 280.w,
                  height: 280.h,
                  margin: EdgeInsets.only(bottom: 24.h),
                  child: SvgPicture.asset(
                    Assets.addToCart,
                    fit: BoxFit.contain,
                  ),
                ),

                // Main text
                Text(
                  'Ups!... Empty cart',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                // Subtitle text
                Text(
                  'Please continue shopping and add to cart',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return price.round().toString();
  }

  // Helper method to calculate the discounted price
  String _calculateDiscountedPrice(
      double originalPrice, double discountPercentage) {
    double discountAmount = originalPrice * (discountPercentage / 100);
    double discountedPrice = originalPrice - discountAmount;
    return _formatPrice(discountedPrice);
  }

  // Calculate total discount percentage
  double _calculateTotalDiscount(List<CartItemEntity> cartItems) {
    if (cartItems.isEmpty) return 0.0;

    double totalOriginalPrice = 0.0;
    double totalDiscountedPrice = 0.0;

    for (var item in cartItems) {
      num itemOriginalPrice = item.medicineEntity.price * item.count;
      num itemDiscountedPrice = itemOriginalPrice;

      // If the product has a discount
      if (item.medicineEntity.discountRating > 0) {
        itemDiscountedPrice =
            itemOriginalPrice * (1 - item.medicineEntity.discountRating / 100);
      }

      totalOriginalPrice += itemOriginalPrice;
      totalDiscountedPrice += itemDiscountedPrice;
    }

    if (totalOriginalPrice == 0) return 0.0;

    return ((totalOriginalPrice - totalDiscountedPrice) / totalOriginalPrice) *
        100;
  }

  // Calculate final price after discount
  double _calculateFinalPrice(double originalPrice, double discountPercentage) {
    if (discountPercentage <= 0) return originalPrice;

    return originalPrice * (1 - discountPercentage / 100);
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
