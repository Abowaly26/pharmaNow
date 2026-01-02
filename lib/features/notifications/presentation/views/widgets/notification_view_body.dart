import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:pharma_now/core/services/notification_log_service.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/features/notifications/presentation/models/notification_log.dart';
import 'package:pharma_now/features/notifications/presentation/views/widgets/notification_item.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/helper_functions/show_custom_bar.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

class NotificationViewBody extends StatefulWidget {
  const NotificationViewBody({super.key});

  @override
  State<NotificationViewBody> createState() => NotificationViewBodyState();
}

class NotificationViewBodyState extends State<NotificationViewBody> {
  final NotificationLogService _logService = getIt<NotificationLogService>();
  List<NotificationLog>? _logs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _logService.getLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showCustomBar(
          context,
          'Error loading notifications: $e',
          type: MessageType.error,
        );
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (_logs == null || _logs!.every((log) => log.read)) return;
    try {
      await _logService.markAllAsRead();
      await _fetchLogs();
      if (mounted) {
        showCustomBar(
          context,
          'All notifications marked as read',
          type: MessageType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomBar(
          context,
          'Failed to mark all as read: $e',
          type: MessageType.error,
        );
      }
    }
  }

  Future<void> clearAll() async {
    if (_logs == null || _logs!.isEmpty) return;
    try {
      await _logService.clearAll();
      await _fetchLogs();
      if (mounted) {
        showCustomBar(
          context,
          'All notifications cleared',
          type: MessageType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomBar(
          context,
          'Failed to clear notifications: $e',
          type: MessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Skeletonizer(
        enabled: true,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          itemCount: 8,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16.h,
                          width: double.infinity,
                          color: Colors.black12,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 14.h,
                          width: MediaQuery.of(context).size.width * 0.6,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      backgroundColor: ColorManager.primaryColor,
      color: ColorManager.secondaryColor,
      onRefresh: _fetchLogs,
      child: _logs == null || _logs!.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: _logs!.length,
              itemBuilder: (context, index) {
                final log = _logs![index];
                return NotificationItem(
                  log: log,
                  onDelete: () async {
                    try {
                      await _logService.deleteNotification(log.id);
                      _fetchLogs();
                      if (mounted) {
                        showCustomBar(
                          context,
                          'Notification deleted',
                          type: MessageType.success,
                          duration: const Duration(seconds: 1),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        showCustomBar(context, 'Error deleting: $e');
                      }
                    }
                  },
                  onMarkAsRead: () async {
                    try {
                      await _logService.markAsRead(log.id);
                      _fetchLogs();
                    } catch (e) {
                      if (mounted) {
                        showCustomBar(context, 'Error updating: $e');
                      }
                    }
                  },
                  onOpen: () {
                    final route = log.payload['route'];
                    if (route is String && route.isNotEmpty) {
                      Navigator.of(context).pushNamed(route);
                    }
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(32.r),
                  decoration: BoxDecoration(
                    color: ColorManager.secondaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    Assets.emptyNotific,
                    width: 140.w,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'No Notifications Yet',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.blackColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'We will notify you when something important happens.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: ColorManager.greyColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
