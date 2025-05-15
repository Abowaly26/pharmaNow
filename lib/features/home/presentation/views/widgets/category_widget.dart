import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_styles.dart';
import '../../ui_model/categories_response.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 12.w),
      child: Container(
        alignment: Alignment.bottomLeft,
        width: 127,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(Assets.item)),
            borderRadius: BorderRadius.circular(16),
            color: ColorManager.primaryColor,
            border: Border.all(color: ColorManager.greyColorC6)),
        child: Container(
          alignment: Alignment.center,
          height: 27.h,
          decoration: BoxDecoration(
              color: ColorManager.lightPurpleColorF5,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r))),
          child: Text(
            '22',
            textAlign: TextAlign.center,
            style: TextStyles.inputLabel,
          ),
        ),
      ),
    );
  }
}
