import 'package:flutter/material.dart';
import 'package:pharma_now/core/widgets/premium_loading_indicator.dart';

class CustomProgressHUD extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color color;
  final double opacity;

  const CustomProgressHUD({
    super.key,
    required this.isLoading,
    required this.child,
    this.color = Colors.black,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetList = <Widget>[];
    widgetList.add(child);

    if (isLoading) {
      widgetList.add(
        Positioned.fill(
          child: Container(
            color: color.withOpacity(opacity),
            child: const Center(
              child: PremiumLoadingIndicator(),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: widgetList,
    );
  }
}
