import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharma_now/Cart/presentation/cubits/cart_item_cubit/cart_item_cubit.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/widgets/cart_item_action_buttons.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_styles.dart';
import '../../../../../core/widgets/shimmer_loading_placeholder.dart';
import '../../Cart/presentation/cubits/cart_cubit/cart_cubit.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    super.key,
    required this.cartItemEntity,
  });

  final CartItemEntity cartItemEntity;

  // Getter to determine stock status from medicine quantity
  StockStatus get stockStatus {
    if (cartItemEntity.medicineEntity.quantity <= 0) {
      return StockStatus.outOfStock;
    }
    if (cartItemEntity.medicineEntity.quantity < 10) {
      return StockStatus.lowStock;
    }
    return StockStatus.inStock;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartItemCubit, CartItemState>(
      buildWhen: (previous, current) {
        if (current is CartItemUpdated) {
          if (current.cartItemEntity == cartItemEntity) {
            return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        return InkWell(
          child: Padding(
            padding: EdgeInsets.only(
              top: 10.h,
              left: 16.r,
              right: 16.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLeftContainer(),
                _buildRightContainer(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeftContainer() {
    return Container(
      width: 106.w,
      height: 124.h,
      decoration: BoxDecoration(
        color: ColorManager.lightBlueColorF5C,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.r), bottomLeft: Radius.circular(8.r)),
        border: Border.all(color: ColorManager.greyColorC6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Product Image
          Padding(
            padding: EdgeInsets.all(5.r),
            child: Center(
              child: cartItemEntity.medicineEntity.subabaseORImageUrl == null
                  ? SizedBox(
                      height: 120.h,
                      width: 100.w,
                    )
                  : Image.network(
                      cartItemEntity.medicineEntity.subabaseORImageUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildLoadingAnimation();
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('No image available')),
                    ),
            ),
          ),
          Positioned(bottom: 4.h, right: 4.w, child: _buildStockIndicator()),

          // Banner logic - Show either New banner OR Discount banner
          Positioned(
            top: cartItemEntity.medicineEntity.isNewProduct ? 0 : 8.h,
            left: 0,
            child: cartItemEntity.medicineEntity.isNewProduct
                ? SvgPicture.asset(
                    Assets.bannerNewProduct,
                    height: 80.h,
                    width: 80.w,
                  )
                : cartItemEntity.medicineEntity.discountRating != null &&
                        cartItemEntity.medicineEntity.discountRating > 0
                    ? Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          SvgPicture.asset(
                            Assets.gold_banner,
                            height: 24.h,
                            width: 48.w,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 1.h,
                              left: 20.0.h,
                            ),
                            child: Text(
                              "${cartItemEntity.medicineEntity.discountRating}%",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildRightContainer(BuildContext context) {
    return Container(
      width: 237.w,
      height: 124.h,
      decoration: BoxDecoration(
        color: ColorManager.buttom_info,
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(8.r), topRight: Radius.circular(8.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.r, right: 8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.r),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            cartItemEntity.medicineEntity.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.listView_product_name,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _buildQuantityStatus(),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context
                        .read<CartCubit>()
                        .deleteMedicineFromCart(cartItemEntity);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.r),
                    child: SvgPicture.asset(
                      Assets.trash,
                      width: 25.w,
                      height: 25.h,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              cartItemEntity.medicineEntity.pharmacyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.listView_product_name.copyWith(
                fontSize: 11.sp,
                color: ColorManager.textInputColor,
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 8.r, right: 8.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CartItemActionButtons(cartItemEntity: cartItemEntity),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show the original price with strikethrough if there's a discount
                      if (cartItemEntity.medicineEntity.discountRating > 0)
                        Text(
                          '${cartItemEntity.calculateTotalPrice()} EGP',
                          style: TextStyles.listView_product_name.copyWith(
                            fontSize: 14.sp,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      // Show discounted price or regular price
                      Text(
                        cartItemEntity.medicineEntity.discountRating > 0
                            ? '${calculateDiscountedPrice(cartItemEntity.calculateTotalPrice().toDouble(), cartItemEntity.medicineEntity.discountRating.toDouble()).split('.')[0]} EGP'
                            : '${cartItemEntity.calculateTotalPrice()} EGP',
                        style: TextStyles.listView_product_name.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: const Color(0xFF20B83A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator() {
    final Color indicatorColor;
    switch (stockStatus) {
      case StockStatus.outOfStock:
        indicatorColor = Colors.red;
        break;
      case StockStatus.lowStock:
        indicatorColor = Colors.orange;
        break;
      case StockStatus.inStock:
        indicatorColor = Colors.green;
        break;
    }

    return Container(
      width: 12.w,
      height: 12.h,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: indicatorColor.withOpacity(0.3),
            blurRadius: 4.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStatus() {
    final String statusText;
    final Color statusColor;

    switch (stockStatus) {
      case StockStatus.outOfStock:
        statusText = 'Out';
        statusColor = Colors.red;
        break;
      case StockStatus.lowStock:
        statusText =
            'Low Stock (${cartItemEntity.medicineEntity.quantity} left)';
        statusColor = Colors.orange;
        break;
      case StockStatus.inStock:
        statusText = 'Stock';
        statusColor = Colors.green;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 8.sp,
          color: statusColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return ShimmerLoadingPlaceholder(
        width: 100.w,
        height: 120.h,
        baseColor: Colors.white.withOpacity(0.2),
        highlightColor: ColorManager.secondaryColor.withOpacity(0.4));
  }

  // Helper method to calculate the discounted price
  String calculateDiscountedPrice(
      double originalPrice, double discountPercentage) {
    double discountAmount = originalPrice * (discountPercentage / 100);
    double discountedPrice = originalPrice - discountAmount;
    return discountedPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '');
  }
}
