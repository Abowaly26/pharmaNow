import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

import '../../../../../core/helper_functions/get_user.dart';
import '../../../../../core/utils/text_style.dart';
import '../../../../notifications/presentation/views/notification_view.dart';
import '../../../../offers/presentation/views/offers_view.dart';
import '../../../../search/presentation/views/search_view.dart';
import '../../../../shopping by category/presentation/views/categories_view.dart';
import '../../ui_model/action_item.dart';

class HomeAppbar extends StatelessWidget {
  HomeAppbar({super.key});

  // Define actions list without using context
  late final List<ActionItem> actions = [
    ActionItem(
      icon: Badge(
          backgroundColor: ColorManager.greenColor,
          label: Text('5'),
          textColor: ColorManager.primaryColor,
          child: SvgPicture.asset(
            Assets.notificationsIcon,
            width: 24,
            height: 24,
          )),
      // Changed to accept BuildContext in the callback
      callback: (BuildContext ctx) {
        Navigator.of(ctx).pushReplacement(
          MaterialPageRoute(
            builder: (context) => NotificationView(),
          ),
        );
      },
    ),
    ActionItem(
      icon: Badge(
          backgroundColor: ColorManager.greenColor,
          label: Text('2'),
          textColor: ColorManager.primaryColor,
          child: SvgPicture.asset(
            Assets.shoppingCartIcon,
            width: 24,
            height: 24,
          )),
      callback: (BuildContext ctx) {
        // Your second action callback
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.secondaryColor,
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(35.r),
            bottomLeft: Radius.circular(35.r)),
      ),
      alignment: Alignment.bottomCenter,
      padding:
          EdgeInsets.only(top: 44.h, left: 24.w, right: 24.w, bottom: 16.h),
      child: AppBar(
          backgroundColor: Colors.transparent,
          leading: CircleAvatar(
            radius: 24.r,
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
          elevation: 0,
          title: Text(
            'Hello ${getUser().name} 👋',
            style: TextStyles.description,
          ),
          actions: [
            SizedBox(
                width: 100.w,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: actions
                        .map((e) => InkWell(
                              onTap: () =>
                                  e.callback(context), // Pass the context here
                              child: e.icon,
                            ))
                        .toList()))
          ]),
    );
  }
}
