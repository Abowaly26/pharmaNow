import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/text_style.dart';

import '../../../../../core/utils/color_manger.dart';

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
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../../core/utils/text_style.dart'; // قد تحتاج لتعديل هذا المسار حسب مشروعك

// class SectionWidget extends StatelessWidget {
//   final String sectionTitle;
//   final VoidCallback onTap;
//   final bool showSeeAll; // إضافة خاصية للتحكم في ظهور زر "See All"

//   const SectionWidget({
//     Key? key,
//     required this.sectionTitle,
//     required this.onTap,
//     this.showSeeAll = true, // افتراضيًا يظهر زر "See All"
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             sectionTitle,
//             style: TextStyles.bold24Black, // استخدم نمط النص المناسب من مشروعك
//           ),
//           if (showSeeAll) // عرض "See all" فقط إذا كانت showSeeAll = true
//             GestureDetector(
//               onTap: onTap,
//               child: Text(
//                 'See all',
//                 style: TextStyles.textClickable, // استخدم نمط النص المناسب من مشروعك
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
