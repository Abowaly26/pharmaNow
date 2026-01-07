import 'package:flutter/material.dart';
// google_fonts removed for stability
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
import 'package:permission_handler/permission_handler.dart';

class NotificationViewBody extends StatefulWidget {
  const NotificationViewBody({super.key});

  @override
  State<NotificationViewBody> createState() => NotificationViewBodyState();
}

class NotificationViewBodyState extends State<NotificationViewBody>
    with WidgetsBindingObserver {
  final NotificationLogService _logService = getIt<NotificationLogService>();
  List<NotificationLog>? _logs;
  bool _isLoading = true;
  bool _isPermissionAllowed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndFetch();
    }
  }

  Future<void> _initData() async {
    await _checkPermissionAndFetch();
  }

  Future<void> _checkPermissionAndFetch() async {
    final status = await Permission.notification.status;
    setState(() {
      _isPermissionAllowed = status.isGranted;
    });
    if (_isPermissionAllowed) {
      _fetchLogs();
    } else {
      setState(() => _isLoading = false);
    }
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

    if (!_isPermissionAllowed) {
      return _buildPermissionRequiredState();
    }

    return RefreshIndicator(
      backgroundColor: ColorManager.primaryColor,
      color: ColorManager.secondaryColor,
      onRefresh: _fetchLogs,
      child: _logs == null || _logs!.isEmpty
          ? _buildEmptyState()
          : _buildGroupedListView(),
    );
  }

  Widget _buildGroupedListView() {
    final Map<String, List<NotificationLog>> groupedLogs = _groupLogs(_logs!);
    final sections = ['Today', 'Yesterday', 'Earlier'];
    int totalIndex = 0;

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final logs = groupedLogs[section];

        if (logs == null || logs.isEmpty) return const SizedBox.shrink();

        final unreadCount = logs.where((l) => !l.read).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    unreadCount > 0 ? '$section ($unreadCount)' : section,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: ColorManager.blackColor.withOpacity(0.55),
                      fontFamily: 'Inter',
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (unreadCount > 0)
                    TextButton(
                      onPressed: () => _markSectionAsRead(logs),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        minimumSize: Size(0, 30.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Mark as read',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ColorManager.secondaryColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ...logs.map((log) {
              final itemIndex = totalIndex++;
              // Professional staggered delay: Cap the delay to index % 10 to ensure
              // that even with 100+ notifications, the bottom ones appear quickly.
              final staggeredDelay = (itemIndex % 10) * 40;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + staggeredDelay),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 40 * (1 - value)),
                    child: NotificationItem(
                      animationValue: value,
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
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _markSectionAsRead(List<NotificationLog> logs) async {
    try {
      final unreadLogs = logs.where((l) => !l.read).toList();
      await Future.wait(unreadLogs.map((l) => _logService.markAsRead(l.id)));
      _fetchLogs();
    } catch (e) {
      if (mounted) {
        showCustomBar(context, 'Error marking as read: $e');
      }
    }
  }

  Map<String, List<NotificationLog>> _groupLogs(List<NotificationLog> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<NotificationLog>> groups = {
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (var log in logs) {
      final date = log.timestamp.toDate();
      final logDay = DateTime(date.year, date.month, date.day);

      if (logDay == today) {
        groups['Today']!.add(log);
      } else if (logDay == yesterday) {
        groups['Yesterday']!.add(log);
      } else {
        groups['Earlier']!.add(log);
      }
    }
    return groups;
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
                SvgPicture.asset(
                  Assets.emptyNotific,
                  width: 260.w,
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

  Widget _buildPermissionRequiredState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(32.r),
                  decoration: BoxDecoration(
                    color: ColorManager.redColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_off_outlined,
                    size: 80.r,
                    color: ColorManager.redColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Notifications are Disabled',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.blackColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'To see your notification history and receive real-time updates, please enable notifications in your device settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: ColorManager.greyColor,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: openAppSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.secondaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Open Settings',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
