import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';

class VerificationRingPainter extends CustomPainter {
  final double progress;

  const VerificationRingPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const strokeWidth = 16.0;
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: (math.pi * 2) - (math.pi / 2),
        colors: [
          orange,
          yellow,
          Colors.white,
        ],
        stops: [
          0.0,
          0.72,
          1.0,
        ],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweepAngle = (math.pi * 2) * progress;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    final indicatorAngle = (-math.pi / 2) + sweepAngle;
    final indicatorOffset = Offset(
      center.dx + math.cos(indicatorAngle) * radius,
      center.dy + math.sin(indicatorAngle) * radius,
    );

    canvas.drawCircle(
      indicatorOffset,
      12,
      Paint()
        ..color = orange.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawCircle(
      indicatorOffset,
      7,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant VerificationRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
