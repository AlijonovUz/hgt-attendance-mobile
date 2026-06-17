import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Yuz tasdig‘i doirasining pastki burchagidagi kichik referens rasm (login’dan
/// kelgan yoki yuklangan) — `CustomPainter` bilan: doira ichida cover-fit rasm
/// + oq halqa. Rasm yuklanmaguncha placeholder fon chiziladi.
class FaceInsetPainter extends CustomPainter {
  const FaceInsetPainter({
    required this.image,
    required this.ringColor,
    required this.placeholderColor,
    this.ringWidth = 3,
  });

  final ui.Image? image;
  final Color ringColor;
  final Color placeholderColor;
  final double ringWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final circle = Rect.fromCircle(center: center, radius: radius);
    final clipPath = Path()..addOval(circle.deflate(ringWidth));

    if (image == null) {
      canvas.drawCircle(
        center,
        radius - ringWidth,
        Paint()..color = placeholderColor,
      );
    } else {
      canvas.save();
      canvas.clipPath(clipPath);
      final img = image!;
      final src = Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
      // Cover-fit: rasmni doira maydonini to‘liq qoplaydigan qilib joylaymiz.
      final scale = (size.width / img.width) > (size.height / img.height)
          ? size.width / img.width
          : size.height / img.height;
      final dstW = img.width * scale;
      final dstH = img.height * scale;
      final dst = Rect.fromCenter(center: center, width: dstW, height: dstH);
      canvas.drawImageRect(
        img,
        src,
        dst,
        Paint()..filterQuality = FilterQuality.medium,
      );
      canvas.restore();
    }

    // Oq halqa.
    canvas.drawCircle(
      center,
      radius - ringWidth / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..color = ringColor,
    );
  }

  @override
  bool shouldRepaint(FaceInsetPainter old) =>
      old.image != image ||
      old.ringColor != ringColor ||
      old.placeholderColor != placeholderColor;
}
