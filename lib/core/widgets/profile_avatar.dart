import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

/// A reusable profile avatar widget that displays:
/// - User's profile image if available (with caching)
/// - User's initial letter as fallback
/// - Optional camera overlay for edit mode
class ProfileAvatar extends StatefulWidget {
  /// Local file image to display (Optimistic UI)
  final File? imageFile;

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
    this.imageFile,
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
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isNetworkImageLoading = false;

  @override
  void didUpdateWidget(ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If image URL changed, we reset the internal loading state
    if (widget.imageUrl != oldWidget.imageUrl) {
      _isNetworkImageLoading =
          widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initialLetter = _getInitialLetter();
    final Color bgColor = widget.backgroundColor ?? ColorManager.secondaryColor;

    // We consider it loading if either the prop is true or we are internally waiting for network image
    final bool effectiveLoading = widget.isLoading || _isNetworkImageLoading;

    Widget avatar;

    final bool isInitialLoading = effectiveLoading &&
        widget.imageFile == null &&
        widget.imageUrl == null &&
        (widget.userName == null || widget.userName!.isEmpty);

    if (isInitialLoading) {
      avatar = CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.grey[200],
      );
    } else if (widget.imageFile != null) {
      avatar = CircleAvatar(
        radius: widget.radius,
        backgroundImage: FileImage(widget.imageFile!),
        backgroundColor: Colors.transparent,
      );
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      avatar = _buildImageAvatar();
    } else {
      avatar = _buildInitialAvatar(initialLetter, bgColor);
    }

    // Add loading overlay if we are loading but already have data
    if (effectiveLoading && !isInitialLoading) {
      avatar = _buildLoadingOverlay(avatar);
    }

    // Wrap with arc if needed
    if (widget.showArc) {
      avatar = Stack(
        alignment: Alignment.center,
        children: [
          if (!isInitialLoading)
            SizedBox(
              width: widget.radius * 2.2,
              height: widget.radius * 2.2,
              child: CustomPaint(painter: _ArcPainter()),
            ),
          avatar,
        ],
      );
    }

    // Add edit overlay if needed
    if (widget.showEditOverlay) {
      return Stack(
        children: [
          avatar,
          // Hide camera button during any loading state to prevent distraction
          if (!effectiveLoading)
            Positioned(
              right: widget.showArc ? widget.radius * 0.1 : 0,
              bottom: widget.showArc ? widget.radius * 0.1 : 0,
              child: GestureDetector(
                onTap: widget.onEditTap,
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
                    size: widget.radius * 0.35,
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
    if (widget.userName != null && widget.userName!.trim().isNotEmpty) {
      final List<String> names = widget.userName!.trim().split(' ');
      if (names.length > 1) {
        return (names[0][0] + names[1][0]).toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    return '';
  }

  Widget _buildImageAvatar() {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      imageBuilder: (context, imageProvider) {
        if (_isNetworkImageLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isNetworkImageLoading = false);
          });
        }
        return CircleAvatar(
          radius: widget.radius,
          backgroundImage: imageProvider,
        );
      },
      placeholder: (context, url) {
        // Placeholder should just be a clean background with the spinner overlay
        return _buildLoadingOverlay(
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey[200],
          ),
        );
      },
      errorWidget: (context, url, error) {
        if (_isNetworkImageLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isNetworkImageLoading = false);
          });
        }
        return _buildInitialAvatar(
          _getInitialLetter(),
          widget.backgroundColor ?? ColorManager.secondaryColor,
        );
      },
    );
  }

  Widget _buildLoadingOverlay(Widget background) {
    return Stack(
      alignment: Alignment.center,
      children: [
        background,
        ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Container(
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: widget.radius * 0.45,
                  height: widget.radius * 0.45,
                  child: const CircularProgressIndicator(
                    color: ColorManager.secondaryColor,
                    strokeWidth: 1.9,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialAvatar(String letter, Color bgColor) {
    final double fontSize =
        letter.length > 1 ? widget.radius * 0.45 : widget.radius * 0.6;

    return CircleAvatar(
      radius: widget.radius,
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
