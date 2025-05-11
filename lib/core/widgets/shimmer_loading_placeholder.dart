import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/color_manger.dart';

class ShimmerLoadingPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? baseColor;
  final Color? highlightColor;
  final bool isPill;
  final Widget? icon;

  const ShimmerLoadingPlaceholder({
    super.key,
    this.width,
    this.height,
    this.baseColor,
    this.highlightColor,
    this.isPill = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 80.w,
      height: height ?? 80.h,
      decoration: BoxDecoration(
        color: baseColor ?? ColorManager.lightBlueColorF5C.withOpacity(0.2),
        borderRadius:
            isPill ? BorderRadius.circular(50.r) : BorderRadius.circular(8.r),
      ),
      child: ShimmerEffect(
        baseColor: baseColor ?? ColorManager.lightBlueColorF5C.withOpacity(0.2),
        highlightColor: highlightColor ?? Colors.white.withOpacity(0.5),
        child: Center(
          child: icon ?? _buildDefaultLoadingIcon(),
        ),
      ),
    );
  }

  Widget _buildDefaultLoadingIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 24.w,
          height: 24.h,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: ColorManager.lightBlueColorF5C,
            backgroundColor: Colors.white.withOpacity(0.3),
          ),
        ),
        SizedBox(height: 8.h),
        _buildPulsingDots(),
      ],
    );
  }

  Widget _buildPulsingDots() {
    return const PulsingDots();
  }
}

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: const Alignment(-1.0, -0.5),
              end: const Alignment(1.0, 0.5),
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
        bounds.width * (slidePercent - 0.5), 0.0, 0.0);
  }
}

class PulsingDots extends StatefulWidget {
  final int dotsCount;
  final Color? dotColor;
  final double dotSize;
  final double spacing;

  const PulsingDots({
    super.key,
    this.dotsCount = 3,
    this.dotColor,
    this.dotSize = 6.0,
    this.spacing = 4.0,
  });

  @override
  State<PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<PulsingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.dotsCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = List.generate(
      widget.dotsCount,
      (index) => Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeInOut,
        ),
      ),
    );

    // Start animations with staggered delays
    for (int i = 0; i < widget.dotsCount; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.dotsCount,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing),
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _animations[index].value,
                child: Container(
                  width: widget.dotSize.w,
                  height: widget.dotSize.h,
                  decoration: BoxDecoration(
                    color: widget.dotColor ?? ColorManager.lightBlueColorF5C,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
