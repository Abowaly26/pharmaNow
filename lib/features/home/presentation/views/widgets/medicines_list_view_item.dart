import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/Cart/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/core/utils/app_images.dart' show Assets;

import '../../../../../core/enitites/medicine_entity.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_styles.dart';
import '../../../../../core/widgets/shimmer_loading_placeholder.dart';
import '../../../../../features/favorites/presentation/widgets/favorite_button.dart';

class MedicineListViewItem extends StatelessWidget {
  final int index;
  final MedicineEntity medicineEntity;
  final VoidCallback? onTap;

  const MedicineListViewItem({
    super.key,
    required this.index,
    required this.medicineEntity,
    this.onTap,
  });

  // Getter to determine stock status from medicine quantity
  StockStatus get stockStatus {
    if (medicineEntity.quantity <= 0) {
      return StockStatus.outOfStock;
    }
    if (medicineEntity.quantity < 10) {
      return StockStatus.lowStock;
    }
    return StockStatus.inStock;
  }

  // Convert medicine entity to model for storing in favorites
  Map<String, dynamic> _convertEntityToModel() {
    return {
      'id': medicineEntity.code,
      'name': medicineEntity.name,
      'price': medicineEntity.price,
      'imageUrl': medicineEntity.subabaseORImageUrl,
      'pharmacyName': medicineEntity.pharmacyName,
      'discountRating': medicineEntity.discountRating,
      'isNewProduct': medicineEntity.isNewProduct,
      'description': medicineEntity.description,
      'quantity': medicineEntity.quantity,
    };
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.only(end: 12.w),
        child: Column(
          children: [
            _buildTopContainer(context),
            _buildBottomContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContainer(BuildContext context) {
    return Container(
      width: 162.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: index.isOdd
            ? ColorManager.lightBlueColorF5C
            : ColorManager.lightGreenColorF5C,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
        border: Border.all(color: ColorManager.greyColorC6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(5.r),
            child: Center(
              child: medicineEntity.subabaseORImageUrl == null ||
                      medicineEntity.subabaseORImageUrl!.isEmpty
                  ? Container(
                      color: ColorManager.textInputColor.withOpacity(0.2),
                      height: 80.h,
                      width: 80.w,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: medicineEntity.subabaseORImageUrl!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => _buildLoadingAnimation(),
                        errorWidget: (context, url, error) =>
                            const Center(child: Text('No image available')),
                      ),
                    ),
            ),
          ),
          Positioned(bottom: 4.h, right: 4.w, child: _buildStockIndicator()),
          // Banner logic - Show either New banner OR Discount banner
          // Priority: 1. New product banner, 2. Discount banner, 3. No banner
          Positioned(
            top: medicineEntity.isNewProduct ? 0 : 8.h,
            left: 0,
            child: medicineEntity.isNewProduct
                ? SvgPicture.asset(
                    Assets.bannerNewProduct,
                    height: 80.h,
                    width: 106.w,
                  )
                : (medicineEntity.discountRating != null &&
                        medicineEntity.discountRating > 0)
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
                              "${medicineEntity.discountRating}%",
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

          Positioned(
            top: 8.h,
            right: 8.w,
            child: FavoriteButton(
              itemId: medicineEntity.code,
              itemData: _convertEntityToModel(),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContainer(BuildContext context) {
    return Container(
      width: 161.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: ColorManager.buttom_info,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Row(
              children: [
                Flexible(
                  child: Text(
                    medicineEntity.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.listView_product_name,
                  ),
                ),
                SizedBox(width: 16.w),
                _buildQuantityStatus(),
              ],
            ),
            Text(
              medicineEntity.pharmacyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.listView_product_name.copyWith(
                fontSize: 10.sp,
                color: ColorManager.textInputColor,
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(left: 4.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show the original price with strikethrough if there's a discount
                      if (medicineEntity.discountRating > 0)
                        Text(
                          '${medicineEntity.price} EGP',
                          style: TextStyles.listView_product_name.copyWith(
                            fontSize: 10.sp,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      // Show discounted price or regular price
                      Text(
                        medicineEntity.discountRating > 0
                            ? '${_calculateDiscountedPrice(medicineEntity.price.toDouble(), medicineEntity.discountRating.toDouble()).split('.')[0]} EGP'
                            : '${medicineEntity.price} EGP',
                        style: TextStyles.listView_product_name.copyWith(
                          fontSize: 11.sp,
                          color: const Color(0xFF20B83A),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.r,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<CartCubit>()
                            .addMedicineToCart(medicineEntity);
                        // Add to cart functionality
                      },
                      child: SvgPicture.asset(
                        Assets.cart,
                        width: 32.w,
                        height: 32.h,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return ShimmerLoadingPlaceholder(
      width: 80.w,
      height: 80.h,
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
        statusText = 'Low Stock';
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
        border: Border.all(color: statusColor.withOpacity(0.3)),
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

  // Helper method to calculate the discounted price
  String _calculateDiscountedPrice(
      double originalPrice, double discountPercentage) {
    double discountAmount = originalPrice * (discountPercentage / 100);
    double discountedPrice = originalPrice - discountAmount;
    return discountedPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '');
  }
}
