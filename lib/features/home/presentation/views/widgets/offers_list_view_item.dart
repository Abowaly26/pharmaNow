import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../order/presentation/cubits/cart_cubit/cart_cubit.dart';
import '../../../../../core/enitites/medicine_entity.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_styles.dart';
import '../../../../../core/widgets/shimmer_loading_placeholder.dart';
import '../../../../favorites/presentation/views/widgets/favorite_button.dart';

class OffersListViewItem extends StatefulWidget {
  final int index;
  final Function()? onTap;
  final MedicineEntity medicineEntity;

  const OffersListViewItem({
    super.key,
    required this.index,
    this.onTap,
    required this.medicineEntity,
  });

  @override
  State<OffersListViewItem> createState() => _OffersListViewItemState();
}

class _OffersListViewItemState extends State<OffersListViewItem> {
  // Getter to determine stock status from medicine quantity
  StockStatus get stockStatus {
    if (widget.medicineEntity.quantity <= 0) {
      return StockStatus.outOfStock;
    }
    if (widget.medicineEntity.quantity < 10) {
      return StockStatus.lowStock;
    }
    return StockStatus.inStock;
  }

  // Convert medicine entity to model for storing in favorites
  Map<String, dynamic> _convertEntityToModel() {
    return {
      'id': widget.medicineEntity.code,
      'name': widget.medicineEntity.name,
      'price': widget.medicineEntity.price,
      'imageUrl': widget.medicineEntity.subabaseORImageUrl,
      'pharmacyName': widget.medicineEntity.pharmacyName,
      'pharmacyId': widget.medicineEntity.pharmacyId,
      'pharmcyAddress': widget.medicineEntity.pharmcyAddress,
      'discountRating': widget.medicineEntity.discountRating,
      'isNewProduct': widget.medicineEntity.isNewProduct,
      'quantity': widget.medicineEntity.quantity,
      'description': widget.medicineEntity.description,
    };
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.only(end: 11.w),
        child: Column(
          children: [
            _buildTopContainer(),
            _buildBottomContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContainer() {
    return Container(
      width: 161.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: widget.index.isEven
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(5.r),
            child: Center(
              child: widget.medicineEntity.subabaseORImageUrl == null ||
                      widget.medicineEntity.subabaseORImageUrl!.isEmpty
                  ? SizedBox(
                      height: 120.h,
                      width: 100.w,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: widget.medicineEntity.subabaseORImageUrl!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => _buildLoadingAnimation(),
                        errorWidget: (context, url, error) =>
                            const Center(child: Text('No image available')),
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 8.h,
            left: 0,
            child: widget.medicineEntity.discountRating > 0
                ? Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      SvgPicture.asset(
                        Assets.gold_banner,
                        height: 24.h,
                        width: 48.w,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 1.h, left: 20.0.h),
                        child: Text(
                          "${widget.medicineEntity.discountRating}%",
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
              itemId: widget.medicineEntity.code,
              itemData: _convertEntityToModel(),
              size: 24,
            ),
          ),
          Positioned(bottom: 4.h, right: 4.w, child: _buildStockIndicator()),
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
                Expanded(
                  child: Text(
                    widget.medicineEntity.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.listView_product_name,
                  ),
                ),
                SizedBox(width: 8.w),
                Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: _buildQuantityStatus(),
                ),
              ],
            ),
            Text(
              widget.medicineEntity.pharmacyName,
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
                      if (widget.medicineEntity.discountRating > 0)
                        Text(
                          '${widget.medicineEntity.price} EGP',
                          style: TextStyles.listView_product_name.copyWith(
                            fontSize: 10.sp,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      Text(
                        widget.medicineEntity.discountRating > 0
                            ? '${_calculateDiscountedPrice(widget.medicineEntity.price.toDouble(), widget.medicineEntity.discountRating.toDouble()).split('.')[0]} EGP'
                            : '${widget.medicineEntity.price} EGP',
                        style: TextStyles.listView_product_name.copyWith(
                          fontSize: 11.sp,
                          color: const Color(0xFF20B83A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.r,
                    ),
                    child: BlocBuilder<CartCubit, CartState>(
                      builder: (context, cartState) {
                        final cartEntity = cartState.cartEntity;
                        final isInCart =
                            cartEntity.isExist(widget.medicineEntity);
                        final isLoading = cartState.loadingMedicineIds
                            .contains(widget.medicineEntity.code);

                        return GestureDetector(
                          onTap: (isInCart || isLoading)
                              ? null
                              : () {
                                  context
                                      .read<CartCubit>()
                                      .addMedicineToCart(widget.medicineEntity);
                                },
                          child: Opacity(
                            opacity: isInCart ? 0.5 : 1.0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  Assets.frameCart,
                                  width: 32.w,
                                  height: 32.h,
                                ),
                                isLoading
                                    ? SizedBox(
                                        width: 12.w,
                                        height: 12.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            ColorManager.primaryColor,
                                          ),
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        Assets.cartPlus,
                                        width: 24.w,
                                        height: 24.h,
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
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
        width: 100.w,
        height: 120.h,
        baseColor: Colors.white.withOpacity(0.2),
        highlightColor: ColorManager.secondaryColor.withOpacity(0.4));
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

  String _calculateDiscountedPrice(
      double originalPrice, double discountPercentage) {
    double discountAmount = originalPrice * (discountPercentage / 100);
    double discountedPrice = originalPrice - discountAmount;
    return discountedPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '');
  }
}
