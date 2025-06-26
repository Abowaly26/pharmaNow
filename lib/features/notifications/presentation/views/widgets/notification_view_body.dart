import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/utils/app_images.dart';

class NotificationViewBody extends StatelessWidget {
  const NotificationViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SvgPicture.asset(Assets.emptyNotific),
        SizedBox(height: 30.h),
        Center(
          child: Text(
            'No Notification Yet!',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            'You have no notifications at this time',
            style: TextStyle(
              fontSize: 17.sp,
              color: const Color(0xff6A7280),
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }
}
