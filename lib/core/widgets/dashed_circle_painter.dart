import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Uzuq-uzuq aylana ramka chizadi (radius-full placeholder doirasi uchun).
///
/// Rasm tanlash doiralarida ishlatiladi (onboarding «rasm yuklash», profil
/// rasm modali). `CustomPaint` ning `painter` yoki `foregroundPainter`siga
/// uzatiladi — fon to‘ldirilgan doira ustiga chizish kerak bo‘lsa `foregroundPainter`.
class DashedCirclePainter extends CustomPainter {
  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashLength = 6,
    this.gapLength = 6,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * math.pi * radius;
    final step = dashLength + gapLength;
    final dashCount = (circumference / step).floor();
    if (dashCount <= 0) return;
    final dashAngle = dashLength / radius;
    final gapAngle = (2 * math.pi - dashCount * dashAngle) / dashCount;

    var angle = -math.pi / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, angle, dashAngle, false, paint);
      angle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}
