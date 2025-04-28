import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';

import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_style.dart';

// Dummy classes to replace imported dependencies

class OffersListViewItem extends StatelessWidget {
  final int index;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final Function()? onTap;

  const OffersListViewItem(
      {super.key,
      required this.index,
      required this.isFavorite,
      required this.onFavoritePressed,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: Column(
          children: [
            Container(
              width: 148.w,
              decoration: BoxDecoration(
                color: index.isEven
                    ? ColorManager.lightBlueColorF5C
                    : ColorManager.lightGreenColorF5C,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                border: Border.all(color: ColorManager.greyColorC6),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) =>
                            const Text('No image available'),
                        image: NetworkImage('https://via.placeholder.com/150'),
                      ),
                    ),
                    height: 75.h,
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(top: 8.h, right: 8.w),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          alignment: Alignment
                              .centerLeft, // Align text within the stack
                          children: [
                            // 1. The SVG Banner
                            SvgPicture.asset(
                              Assets.gold_banner,
                              height: 24.h,
                              width: 48.w,
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                top: 1.h,
                                left: 20.0.h,
                              ), // Adjust padding to position text
                              child: Text(
                                "50%", // <<< Your Text Here
                                style: TextStyle(
                                  color: Colors
                                      .black, // Choose a contrasting color
                                  fontSize: 9.sp, // Adjust font size
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onFavoritePressed,
                          child: SvgPicture.asset(
                            isFavorite ? Assets.fav : Assets.nFav,
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomContainer(),
          ],
        ),
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
              width: 160.w,
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
