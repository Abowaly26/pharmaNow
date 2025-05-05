import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/text_style.dart';

import '../../../../../core/utils/color_manger.dart';
import '../../../../offers/presentation/views/offers_view.dart';

class SectionWidget extends StatelessWidget {
  const SectionWidget({super.key, required this.sectionTitle, this.onTap});
  final String sectionTitle;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitle,
                style: TextStyles.sectionTitle,
              ),
              SvgPicture.asset(Assets.underline)
            ],
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              'See All',
              style: TextStyles.buttonLabel
                  .copyWith(color: ColorManager.secondaryColor),
            ),
          )
        ],
      ),
    );
  }
}
