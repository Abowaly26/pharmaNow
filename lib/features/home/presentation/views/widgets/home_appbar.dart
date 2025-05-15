import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../../core/helper_functions/get_user.dart';
import '../../../../notifications/presentation/views/notification_view.dart';
import '../../../../profile/presentation/providers/profile_provider.dart';
import '../../ui_model/action_item.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/text_styles.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/app_images.dart';

class HomeAppbar extends StatelessWidget {
  HomeAppbar({super.key});

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
      callback: (BuildContext ctx) {
        Navigator.of(ctx).pushReplacement(
          MaterialPageRoute(
            builder: (context) => NotificationView(),
          ),
        );
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.secondaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(35.r),
            bottomLeft: Radius.circular(35.r)),
      ),
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(top: 20.h, left: 24.w, bottom: 16.h),
      child: AppBar(
          backgroundColor: Colors.transparent,
          leadingWidth: 45.w,
          leading: Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                return CircleAvatar(
                  radius: 20.r,
                  backgroundImage: provider.profileImageUrl != null
                      ? NetworkImage(provider.profileImageUrl!)
                      : null,
                  backgroundColor: Colors.purple,
                  child: provider.profileImageUrl == null
                      ? Text(
                          provider.currentUser != null &&
                                  provider.currentUser!.name.isNotEmpty
                              ? provider.currentUser!.name[0].toUpperCase()
                              : getUser().name.isNotEmpty
                                  ? getUser().name[0].toUpperCase()
                                  : '?',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          titleSpacing: 8.w, // Remove spacing between leading and title
          title: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              final userName = provider.currentUser != null &&
                      provider.currentUser!.name.isNotEmpty
                  ? provider.currentUser!.name
                  : getUser().name;

              final displayName = userName.length > 10
                  ? '${userName.substring(0, 8)}...'
                  : userName;

              return Text(
                'Hello $displayName 👋',
                style: TextStyles.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          actions: [
            SizedBox(
                width: 100.w,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: actions
                        .map((e) => InkWell(
                              onTap: () => e.callback(context),
                              child: e.icon,
                            ))
                        .toList()))
          ]),
    );
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 5.0;
    final rect = Offset.zero & size;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      1.45,
      5.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
