import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/widgets/shimmer_loading_placeholder.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_style.dart';
import '../../../../../features/favorites/presentation/widgets/favorite_button.dart';

class InfoOffersListViewItem extends StatelessWidget {
  final int index;
  final Function()? onTap;
  final MedicineEntity medicineEntity;

  const InfoOffersListViewItem({
    super.key,
    required this.index,
    this.onTap,
    required this.medicineEntity,
  });
  
  // تحويل كيان الدواء إلى نموذج للحفظ في المفضلة
  // تحويل كيان الدواء إلى نموذج للحفظ في المفضلة
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
    };
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          top: 12.h,
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
  }

  Widget _buildLeftContainer() {
    return Container(
      width: 106.w,
      height: 124.h, // Added fixed height to match InfoMedicinesListViewItem
      decoration: BoxDecoration(
        color: index.isEven
            ? ColorManager.lightBlueColorF5C
            : ColorManager.lightGreenColorF5C,
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
              child: medicineEntity.subabaseORImageUrl == null
                  ? SizedBox(
                      height: 120.h,
                      width: 100.w,
                    )
                  : Image.network(
                      medicineEntity.subabaseORImageUrl!,
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
          // Discount banner - updated positioning to match InfoMedicinesListViewItem
          Positioned(
            top: 8.h,
            left: 0,
            child: medicineEntity.discountRating > 0
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
        padding: EdgeInsets.only(left: 8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 148.w,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.r),
                    child: Text(
                      medicineEntity.name,
                      maxLines:
                          1, // Added maxLines to match InfoMedicinesListViewItem
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.listView_product_name,
                    ),
                  ),
                ),
                // زر المفضلة - يستخدم مكون FavoriteButton المشترك لإضافة/إزالة العرض من المفضلة
                // Favorite button - uses the shared FavoriteButton component to add/remove offer from favorites
                Padding(
                  padding: EdgeInsets.only(right: 8.r, top: 4.r),
                  child: FavoriteButton(
                    itemId: medicineEntity.code,
                    itemData: _convertEntityToModel(),
                    size: 24,
                  ),
                ),
              ],
            ),
            Text(
              medicineEntity.pharmacyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.listView_product_name.copyWith(
                fontSize: 11.sp,
                color: ColorManager.textInputColor,
              ),
            ),
            SizedBox(height: 4.h),
            // Add description here
            Text(
              medicineEntity.description ?? 'No description available',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                color: ColorManager.greyColor,
                height: 1.2,
              ),
            ),
            const Spacer(),
            // Updated padding to match InfoMedicinesListViewItem
            Padding(
              padding: EdgeInsets.only(bottom: 8.r, right: 8.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
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
                  // Removed extra padding around cart icon to match InfoMedicinesListViewItem
                  GestureDetector(
                    onTap: () {
                      // Add to cart functionality
                    },
                    child: SvgPicture.asset(
                      Assets.cart,
                      width: 32.w,
                      height: 32.h,
                    ),
                  ),
                ],
              ),
            ),
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

  // Helper method to calculate the discounted price
  String _calculateDiscountedPrice(
      double originalPrice, double discountPercentage) {
    double discountAmount = originalPrice * (discountPercentage / 100);
    double discountedPrice = originalPrice - discountAmount;
    return discountedPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '');
  }
}
