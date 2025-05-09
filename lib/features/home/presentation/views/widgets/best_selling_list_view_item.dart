import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/enitites/medicine_entity.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_style.dart';

class BestSellingListViewItem extends StatelessWidget {
  final int index;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final MedicineEntity medicineEntity;

  const BestSellingListViewItem({
    super.key,
    required this.index,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.medicineEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 12.w),
      child: Column(
        children: [
          _buildTopContainer(),
          _buildBottomContainer(),
        ],
      ),
    );
  }

  Widget _buildTopContainer() {
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
                  ? Container(
                      color: ColorManager.textInputColor,
                      height: 80.h,
                      width: 73.w,
                    )
                  : Image.network(
                      medicineEntity.subabaseORImageUrl!,
                      fit: BoxFit.contain,
                      height: 80.h,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: ColorManager.textInputColor,
                        height: 80.h,
                        width: 73.w,
                        child: const Center(child: Text('Image Error')),
                      ),
                    ),
            ),
          ),
          // "New" banner
          Positioned(
            top: 0,
            left: 0,
            child: medicineEntity.isNewProduct
                ? SvgPicture.asset(
                    Assets.bannerNewProduct,
                    height: 80.h,
                    width: 106.w,
                  )
                : Container(),
          ),
          // Favorite icon
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: onFavoritePressed,
              child: SvgPicture.asset(
                isFavorite ? Assets.fav : Assets.nFav,
                width: 24.w,
                height: 24.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContainer() {
    return Container(
      width: 162.w,
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
            SizedBox(
              width: 175.w,
              child: Text(
                medicineEntity.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.listView_product_name,
              ),
            ),
            Text(
              medicineEntity.pharmacyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.listView_product_subInf,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${medicineEntity.price} EGP',
                    style: TextStyles.listView_product_name.copyWith(
                        fontSize: 10.sp, color: const Color(0xFF20B83A)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.r),
                  child: GestureDetector(
                    onTap: () {
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
            )
          ],
        ),
      ),
    );
  }
}
