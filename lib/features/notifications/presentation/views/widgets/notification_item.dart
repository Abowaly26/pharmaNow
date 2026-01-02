import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharma_now/features/notifications/presentation/models/notification_log.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationItem extends StatelessWidget {
  final NotificationLog log;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsRead;
  final VoidCallback? onOpen;

  const NotificationItem({
    super.key,
    required this.log,
    required this.onDelete,
    required this.onMarkAsRead,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final payload = log.payload;
    final String title = payload['title'] ?? 'Notification';
    final String body = payload['body'] ?? '';
    final String? imageUrl = payload['image'];
    final String type = payload['type'] ?? 'system';

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: ColorManager.redColor.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28.sp),
            SizedBox(height: 4.h),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: () {
          if (!log.read) onMarkAsRead();
          if (onOpen != null) onOpen!();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: log.read
                ? Colors.transparent
                : ColorManager.secondaryColor.withOpacity(0.04),
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeIcon(type, imageUrl),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight:
                                  log.read ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 15.sp,
                              color: ColorManager.blackColor,
                            ),
                          ),
                        ),
                        Text(
                          _getFormattedTime(log.timestamp.toDate()),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: ColorManager.greyColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      body,
                      style: TextStyle(
                        color: ColorManager.greyColor.withOpacity(0.9),
                        fontSize: 13.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!log.read)
                Container(
                  width: 8.sp,
                  height: 8.sp,
                  margin: EdgeInsets.only(top: 6.h, left: 8.w),
                  decoration: const BoxDecoration(
                    color: ColorManager.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  Widget _buildTypeIcon(String type, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: ColorManager.secondaryColor.withOpacity(0.1)),
        ),
        child: CircleAvatar(
          radius: 22.r,
          backgroundImage: NetworkImage(imageUrl),
          backgroundColor: Colors.grey[100],
        ),
      );
    }

    IconData iconData;
    Color color;

    switch (type.toLowerCase()) {
      case 'order':
        iconData = Icons.shopping_cart_outlined;
        color = const Color(0xFFF59E0B);
        break;
      case 'offer':
        iconData = Icons.local_offer_outlined;
        color = const Color(0xFF10B981);
        break;
      case 'security':
        iconData = Icons.shield_outlined;
        color = ColorManager.secondaryColor;
        break;
      default:
        iconData = Icons.notifications_none_rounded;
        color = ColorManager.greyColor;
    }

    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 22.sp),
    );
  }
}
