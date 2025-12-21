import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';

// AppBar buildAppBar({
//   required String title,
//   String? assetName,
// }) {
//   return AppBar(
//     leading: assetName != null
//         ? IconButton(
//             icon: SvgPicture.asset(assetName),
//             onPressed: () {},
//           )
//         : null,
//     title: Text(
//       title,
//       style: TextStyles.Medium18,
//     ),
//     centerTitle: true,
//     elevation: 0,
//     bottom: PreferredSize(
//       preferredSize: const Size.fromHeight(1.0),
//       child: Container(
//         color: Color(0xFFF2F4F9),
//         height: 1,
//       ),
//     ),
//   );
// }

class PharmaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PharmaAppBar(
      {super.key, required this.title, this.isBack = false, this.onPressed});
  final String title;
  final bool isBack;
  final Function()? onPressed;

  @override
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: ColorManager.primaryColor,
      surfaceTintColor: ColorManager.primaryColor,
      foregroundColor: ColorManager.primaryColor,
      automaticallyImplyLeading: isBack,
      leading: isBack
          ? IconButton(
              icon: SvgPicture.asset(
                Assets.arrowLeft,
                width: 24,
                height: 24,
                color: ColorManager.colorOfArrows,
              ),
              onPressed: onPressed,
            )
          : null,
      centerTitle: true,
      title: Text(title),
      titleTextStyle: TextStyles.appBarTitle18,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Color(0xFFF2F4F9),
          height: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
