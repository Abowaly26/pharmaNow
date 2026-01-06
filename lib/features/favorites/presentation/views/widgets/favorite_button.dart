import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/features/favorites/presentation/providers/favorites_provider.dart';

import 'package:pharma_now/features/favorites/presentation/views/widgets/heart_burst_painter.dart';
import 'package:pharma_now/core/services/notification_service.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';

class FavoriteButton extends StatefulWidget {
  final String itemId;
  final Map<String, dynamic> itemData;
  final double size;

  const FavoriteButton({
    super.key,
    required this.itemId,
    required this.itemData,
    this.size = 24,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _burstAnimation;
  bool _isSnackBarVisible = false;
  // Local state to prevent rapid clicks before provider updates
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _burstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(FavoritesProvider provider, bool isFavorite) {
    if (_isSnackBarVisible || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();
    if (!isFavorite) {
      _controller.forward(from: 0.0);
    } else {
      _controller.reverse(from: 1.0);
    }
    _toggleFavorite(context, provider);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        final isFavorite = provider.isFavorite(widget.itemId);
        final isLoading = provider.isItemLoading(widget.itemId);

        return GestureDetector(
          onTap: (isLoading || _isSnackBarVisible || _isProcessing)
              ? null
              : () => _handleTap(provider, isFavorite),
          child: SizedBox(
            width: widget.size.w,
            height: widget.size.h,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Localized Progress Ring (Subtle Sync Indicator)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isLoading ? 1.0 : 0.0,
                  child: SizedBox(
                    width: (widget.size + 12).w,
                    height: (widget.size + 12).h,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF3638DA).withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                // Burst effect behind the icon
                CustomPaint(
                  size: Size(widget.size.w * 2, widget.size.h * 2),
                  painter: HeartBurstPainter(
                    animationValue: _burstAnimation.value,
                    color: Colors.red,
                  ),
                ),
                // The animated heart icon
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: SvgPicture.asset(
                        isFavorite ? Assets.fav : Assets.nFav,
                        width: widget.size.w,
                        height: widget.size.h,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleFavorite(BuildContext context, FavoritesProvider provider) {
    provider
        .toggleFavorite(
      itemId: widget.itemId,
      itemData: widget.itemData,
    )
        .then((isNowFavorite) {
      if (context.mounted) {
        setState(() {
          _isSnackBarVisible = true;
          _isProcessing = false;
        });
        showCustomBar(
          context,
          isNowFavorite ? 'added to favorites' : 'removed from favorites',
          duration: const Duration(seconds: 1),
          type: MessageType.success,
        );

        // Reset the flag after the duration (approximate since showCustomBar handles animation)
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() => _isSnackBarVisible = false);
          }
        });

        if (isNowFavorite) {
          final String itemName = widget.itemData['name'] ?? 'Item';
          NotificationService.instance.showSystemNotification(
            title: 'Added to Favorites ❤️',
            body: '$itemName has been added to your favorites list.',
            type: 'system',
          );
        }
      }
    }).catchError((e) {
      if (context.mounted) {
        setState(() {
          _isProcessing = false;
        });
        showCustomBar(
          context,
          'Error occurred: ${e.toString().replaceAll('Exception: ', '')}',
          type: MessageType.error,
          duration: const Duration(seconds: 2),
        );
      } else {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    });
  }
}
