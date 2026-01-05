import 'dart:math';
import 'package:flutter/material.dart';

class HeartBurstPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  HeartBurstPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue == 0) return;

    final paint = Paint()
      ..color = color.withOpacity((1 - animationValue).clamp(0, 1))
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Drawing 8 particles exploding outwards
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * pi / 180;
      final distance = radius * 1.5 * animationValue;
      final particleCenter = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      final particleSize = 4.0 * (1 - animationValue);
      canvas.drawCircle(particleCenter, particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartBurstPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
