import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharma_now/core/utils/text_style.dart';
import 'package:pharma_now/features/favorites/presentation/views/favorites.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/color_manger.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharma_now/core/utils/text_style.dart';

class NewProductsListViewItem extends StatelessWidget {
  final int index;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const NewProductsListViewItem({
    super.key,
    required this.index,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Column(
        children: [
          Container(
            width: 148.w,
            decoration: BoxDecoration(
              color: index.isOdd
                  ? ColorManager.lightBlueColorF5C
                  : ColorManager.lightGreenColorF5C,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              border: Border.all(color: ColorManager.greyColorC6),
            ),
            child: Stack(
              children: [
                // Product image container
                Container(
                  height: 80.h,
                  alignment: Alignment.topLeft,
                  child: SvgPicture.asset(
                    height: 80.h,
                    width: 106.w,
                    Assets.bannerNewProduct,
                    // width: 106,
                  ),
                ),

                // Favorite icon positioned absolutely
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      isFavorite ? Assets.fav : Assets.nFav,
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomContainer(),
        ],
      ),
    );
  }

  Widget _buildBottomContainer() {
    return Container(
      width: 148.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: ColorManager.buttom_info,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 148.w,
              child: Padding(
                padding: EdgeInsets.only(top: 8.r),
                child: Text(
                  'Product Name',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.listView_product_name,
                ),
              ),
            ),
            Text(
              'Category',
              overflow: TextOverflow.ellipsis,
              style: TextStyles.listView_product_subInf,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.r),
                  child: Text('\$19.99',
                      style: TextStyles.listView_product_name
                          .copyWith(fontSize: 12.sp)),
                ),
                SvgPicture.asset(
                  Assets.cart,
                  width: 32.w,
                  height: 32.h,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
