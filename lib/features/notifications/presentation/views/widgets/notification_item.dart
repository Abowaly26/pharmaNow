import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pharma_now/features/notifications/presentation/models/notification_log.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationItem extends StatefulWidget {
  final NotificationLog log;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsRead;
  final VoidCallback? onOpen;
  final double animationValue;

  const NotificationItem({
    super.key,
    required this.log,
    required this.onDelete,
    required this.onMarkAsRead,
    this.onOpen,
    this.animationValue = 1.0,
  });

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
  }

  void _onTapCancel() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.log.payload;
    final String title = payload['title'] ?? 'Notification';
    final String body = payload['body'] ?? '';
    final String? imageUrl = payload['image'];
    final String type = payload['type'] ?? 'system';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          if (!widget.log.read) widget.onMarkAsRead();
          if (widget.onOpen != null) widget.onOpen!();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dismissible(
            key: Key(widget.log.id),
            direction: DismissDirection.endToStart,
            background: _buildDismissBackground(),
            onDismissed: (_) => widget.onDelete(),
            child: Container(
              decoration: BoxDecoration(
                color:
                    Colors.white.withValues(alpha: 0.9 * widget.animationValue),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.black
                      .withValues(alpha: 0.05 * widget.animationValue),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.03 * widget.animationValue),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Stack(
                  children: [
                    // Glowing Unread Indicator
                    if (!widget.log.read)
                      Positioned(
                        left: 0,
                        top: 12.h,
                        bottom: 12.h,
                        width: 4.w,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorManager.secondaryColor
                                .withValues(alpha: widget.animationValue),
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(8.r)),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 16.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTypeIcon(type, imageUrl),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: widget.log.read
                                              ? FontWeight.w600
                                              : FontWeight.w700,
                                          color: ColorManager.blackColor
                                              .withValues(
                                                  alpha: widget.animationValue),
                                          fontFamily: 'Inter',
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      _getFormattedTime(
                                          widget.log.timestamp.toDate()),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: ColorManager.greyColor
                                            .withValues(
                                                alpha: 0.6 *
                                                    widget.animationValue),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  body,
                                  style: TextStyle(
                                    color: ColorManager.greyColor.withValues(
                                        alpha: 0.9 * widget.animationValue),
                                    fontSize: 13.sp,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (!widget.log.read) ...[
                                  SizedBox(height: 10.h),
                                  _buildNewTag(),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
          SizedBox(height: 4.h),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return DateFormat('MMM d').format(date);
  }

  Widget _buildTypeIcon(String type, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: 0.08 * widget.animationValue),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 24.r,
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(imageUrl),
        ),
      );
    }

    IconData iconData;
    Color color;

    switch (type.toLowerCase()) {
      case 'order':
        iconData = Icons.shopping_bag_outlined;
        color = const Color(0xFFF59E0B);
        break;
      case 'offer':
        iconData = Icons.local_offer_rounded;
        color = const Color(0xFF10B981);
        break;
      case 'security':
        iconData = Icons.verified_user_rounded;
        color = ColorManager.secondaryColor;
        break;
      default:
        iconData = Icons.notifications_active_rounded;
        color = ColorManager.secondaryColor;
    }

    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1 * widget.animationValue),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(iconData,
          color: color.withValues(alpha: 0.9 * widget.animationValue),
          size: 22.sp),
    );
  }

  Widget _buildNewTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: ColorManager.secondaryColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter',
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
