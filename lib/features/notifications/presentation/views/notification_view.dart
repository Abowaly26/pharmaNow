import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/notifications/presentation/views/widgets/notification_view_body.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import '../../../home/presentation/views/main_view.dart';

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
          onPressed: () {
            Navigator.pushReplacementNamed(context, MainView.routeName);
          },
          action: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: ColorManager.blackColor),
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  _bodyKey.currentState?.markAllAsRead();
                } else if (value == 'clear_all') {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Clear all notifications?'),
                        content: const Text(
                            'This will permanently remove all notifications.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _bodyKey.currentState?.clearAll();
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all,
                          size: 20.sp, color: ColorManager.greyColor),
                      SizedBox(width: 8.w),
                      const Text('Mark all as read'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep_outlined,
                          size: 20.sp, color: ColorManager.redColor),
                      SizedBox(width: 8.w),
                      const Text('Clear all'),
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
}
