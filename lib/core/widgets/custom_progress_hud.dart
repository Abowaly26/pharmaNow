import 'package:flutter/material.dart';

class CustomProgressHUD extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color color;
  final double opacity;

  const CustomProgressHUD({
    Key? key,
    required this.isLoading,
    required this.child,
    this.color = Colors.black,
    this.opacity = 0.3,
  }) : super(key: key);

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
              child: CircularProgressIndicator(),
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
