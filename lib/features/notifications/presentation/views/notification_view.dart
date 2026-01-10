import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/notifications/presentation/views/widgets/notification_view_body.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});
  static const routeName = 'NotificationView';

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final GlobalKey<NotificationViewBodyState> _bodyKey =
      GlobalKey<NotificationViewBodyState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.sp),
        child: PharmaAppBar(
          title: 'Notifications',
          isBack: true,
          onPressed: () => Navigator.pop(context),
          action: [
            PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              offset: Offset(0, 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              color: const Color(0xFFF8F7FF),
              elevation: 4,
              icon: Icon(Icons.more_vert,
                  color: ColorManager.blackColor, size: 24.sp),
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showClearAllDialog(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear_all',
                  height: 48.h,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_sweep_rounded,
                        size: 22.sp,
                        color: const Color(0xFFEF4444),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Clear all',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F2937),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: NotificationViewBody(key: _bodyKey),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Clear all notifications?',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: ColorManager.blackColor,
              fontFamily: 'Inter',
            ),
          ),
          content: Text(
            'This will permanently remove all your notification history. This action cannot be undone.',
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorManager.greyColor,
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
          actionsPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.greyColor,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _bodyKey.currentState?.clearAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
