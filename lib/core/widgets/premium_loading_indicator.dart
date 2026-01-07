import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'dart:math' as math;

class PremiumLoadingIndicator extends StatefulWidget {
  final double? size;
  final IconData? icon;
  final Color? color;

  const PremiumLoadingIndicator({
    super.key,
    this.size,
    this.icon,
    this.color,
  });

  @override
  State<PremiumLoadingIndicator> createState() =>
      _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicatorSize = widget.size ?? 64.h;
    final primaryColor = widget.color ?? ColorManager.secondaryColor;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glowing ring
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: Container(
                  height: indicatorSize,
                  width: indicatorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              );
            },
          ),
          // Inner pulsating icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutSine,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  widget.icon ?? Icons.auto_awesome_rounded,
                  color: primaryColor,
                  size: (indicatorSize * 0.35),
                ),
              );
            },
            onEnd:
                () {}, // This will trigger rebuild if managed correctly, but TweenAnimationBuilder handles it if we use a state
            // Actually, for continuous pulsing, a separate AnimationController or a repeating Tween would be better.
            // Let's use the main controller for a subtle pulse too.
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale =
                  0.9 + 0.2 * math.sin(_controller.value * 2 * math.pi);
              return Transform.scale(
                scale: scale,
                child: Icon(
                  widget.icon ?? Icons.auto_awesome_rounded,
                  color: primaryColor,
                  size: (indicatorSize * 0.35),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
