import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/color_manger.dart';
import 'shimmer_loading_placeholder.dart';

/// A wrapper around CachedNetworkImage that properly handles image loading errors
/// without throwing exceptions to Flutter's global error handler.
///
/// This widget silently handles 400/404 errors from Supabase storage and displays
/// a placeholder icon instead of throwing an exception.
class SafeCachedNetworkImage extends StatelessWidget {
  const SafeCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholderIconSize,
    this.borderRadius,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? placeholderIconSize;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    // If the URL is null or empty, show placeholder immediately
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildLoadingAnimation(),
      errorWidget: (context, url, error) => _buildPlaceholder(),
      // Use a custom image builder to wrap with ClipRRect if needed
      imageBuilder: borderRadius != null
          ? (context, imageProvider) => ClipRRect(
                borderRadius: borderRadius!,
                child: Image(
                  image: imageProvider,
                  width: width,
                  height: height,
                  fit: fit,
                ),
              )
          : null,
      // Suppress errors from being thrown to the Flutter framework
      errorListener: (exception) {
        // Silently handle the error - the errorWidget will be shown
        // This prevents the exception from bubbling up to the console
        debugPrint(
            '[SafeCachedNetworkImage] Image load failed: ${exception.toString().split('\n').first}');
      },
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: placeholderIconSize ?? 55.sp,
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return ShimmerLoadingPlaceholder(
      width: width ?? 80.w,
      height: height ?? 80.h,
      baseColor: Colors.white.withOpacity(0.2),
      highlightColor: ColorManager.secondaryColor.withOpacity(0.4),
    );
  }
}
