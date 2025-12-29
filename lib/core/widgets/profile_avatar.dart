import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

/// A reusable profile avatar widget that displays:
/// - User's profile image if available (with caching)
/// - User's initial letter as fallback
/// - Optional camera overlay for edit mode
class ProfileAvatar extends StatelessWidget {
  /// The URL of the profile image (nullable)
  final String? imageUrl;

  /// The user's name to extract initial letter from
  final String? userName;

  /// Radius of the avatar
  final double radius;

  /// Whether to show the camera edit overlay
  final bool showEditOverlay;

  /// Callback when the edit overlay is tapped
  final VoidCallback? onEditTap;

  /// Whether the avatar is in loading state
  final bool isLoading;

  /// Background color for the initial avatar
  final Color? backgroundColor;

  /// Color for the arc painter (decorative arc around avatar)
  final bool showArc;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.userName,
    this.radius = 50,
    this.showEditOverlay = false,
    this.onEditTap,
    this.isLoading = false,
    this.backgroundColor,
    this.showArc = false,
  });

  @override
  Widget build(BuildContext context) {
    final String initialLetter = _getInitialLetter();
    final Color bgColor = backgroundColor ?? ColorManager.secondaryColor;

    Widget avatar;

    // If we are loading and have no data, show skeleton
    // If we are loading and HAVE data, we'll show the avatar with an overlay
    final bool isInitialLoading = isLoading &&
        imageUrl == null &&
        (userName == null || userName!.isEmpty);

    if (isInitialLoading) {
      // Return a simple circle that Skeletonizer will treat as a bone
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = _buildImageAvatar();
    } else {
      avatar = _buildInitialAvatar(initialLetter, bgColor);
    }

    // Add loading overlay if we are loading but already have data (e.g. uploading/updating)
    if (isLoading && !isInitialLoading) {
      avatar = Stack(
        alignment: Alignment.center,
        children: [
          avatar,
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: radius * 0.4,
                height: radius * 0.4,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Wrap with arc if needed
    // Hide arc when loading for a cleaner skeleton look
    if (showArc && !isLoading) {
      avatar = Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: radius * 2.2,
            height: radius * 2.2,
            child: CustomPaint(painter: _ArcPainter()),
          ),
          avatar,
        ],
      );
    }

    // Add edit overlay if needed
    // Hide overlay when loading for a cleaner look
    if (showEditOverlay && !isLoading) {
      return Stack(
        children: [
          avatar,
          Positioned(
            right: showArc ? radius * 0.1 : 0,
            bottom: showArc ? radius * 0.1 : 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: radius * 0.35,
                  color: ColorManager.secondaryColor,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return avatar;
  }

  String _getInitialLetter() {
    if (userName != null && userName!.trim().isNotEmpty) {
      final List<String> names = userName!.trim().split(' ');
      if (names.length > 1) {
        // Get first letter of first two words
        return (names[0][0] + names[1][0]).toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    return ''; // Return empty string instead of '?' to allow skeletonizer to show better placeholder
  }

  Widget _buildImageAvatar() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: ColorManager.secondaryColor.withOpacity(0.1),
        child: SizedBox(
          width: radius * 0.5,
          height: radius * 0.5,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
                AlwaysStoppedAnimation<Color>(ColorManager.secondaryColor),
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildInitialAvatar(
        _getInitialLetter(),
        backgroundColor ?? ColorManager.secondaryColor,
      ),
    );
  }

  Widget _buildInitialAvatar(String letter, Color bgColor) {
    // Dynamic font size based on number of initials
    final double fontSize = letter.length > 1 ? radius * 0.5 : radius * 0.8;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Custom painter for the decorative arc around the avatar
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 5.0;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = ColorManager.secondaryColor
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
