import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/date_extensions.dart';
import '../../../../core/extentions/text_extensions.dart';

/// Asosiy ekrandagi «davomat halqasi» kartasi (Figma 301:9377).
///
/// Joriy **oraliq** uchun sanagich (kelish→tushlik, tushlik→qaytish,
/// qaytish→ketish). Oraliq tashqaridan [start]–[end] sifatida beriladi:
/// - `now < end` → sanaydi: markazda `end − now` + [countingLabel], ko‘k halqa
///   ([start]..[end] ulushiga to‘ladi).
/// - `now ≥ end` (keyingi bosqich hali qilinmagan) → halqa **to‘ladi**
///   (to‘q-sariq) va [overdueLabel] yoziladi («Tushlikka chiqish vaqti» …).
/// - [done] (ishdan ketilgan) → to‘liq yashil, bugungi ishlagan vaqt
///   ([worked]) + [doneLabel].
class AttendanceRingCard extends StatefulWidget {
  const AttendanceRingCard({
    super.key,
    required this.start,
    required this.end,
    required this.countingLabel,
    required this.overdueLabel,
    required this.rangeText,
    this.done = false,
    this.worked = Duration.zero,
    this.doneLabel = '',
  });

  /// Joriy oraliq boshlanishi (haqiqiy belgilangan vaqt) — `done` da e’tiborsiz.
  final DateTime? start;

  /// Joriy oraliq tugashi (belgilangan/schedule vaqti) — `done` da e’tiborsiz.
  final DateTime? end;

  /// Sanash paytidagi izoh (masalan «tushlikka qoldi»).
  final String countingLabel;

  /// Belgilangan vaqt o‘tib ketgandagi izoh («Tushlikka chiqish vaqti»).
  final String overdueLabel;

  /// Sana ostidagi ish oralig‘i matni ("09:00–18:00").
  final String rangeText;

  /// Ishdan ketilgan (yakuniy) holat.
  final bool done;
  final Duration worked;
  final String doneLabel;

  @override
  State<AttendanceRingCard> createState() => _AttendanceRingCardState();
}

class _AttendanceRingCardState extends State<AttendanceRingCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final s = d.isNegative ? Duration.zero : d;
    return '${two(s.inHours)}:${two(s.inMinutes % 60)}:${two(s.inSeconds % 60)}';
  }

  /// Joriy holat: markaz matni, izoh, halqa rangi va ulushi.
  ({String time, String label, Color color, double progress}) _resolve(
    AppColors colors,
  ) {
    if (widget.done) {
      return (
        time: _fmt(widget.worked),
        label: widget.doneLabel,
        color: colors.successPrimary,
        progress: 1,
      );
    }

    final start = widget.start;
    final end = widget.end;
    if (start == null || end == null) {
      return (
        time: '00:00:00',
        label: widget.countingLabel,
        color: colors.accentStrong,
        progress: 0,
      );
    }

    // Belgilangan vaqt o‘tib ketdi — halqa to‘ladi, amal so‘raladi.
    if (!_now.isBefore(end)) {
      return (
        time: '00:00:00',
        label: widget.overdueLabel,
        color: AppColors.warningStrong,
        progress: 1,
      );
    }

    // Sanash: end − now, ulush = (now − start) / (end − start).
    final total = end.difference(start).inSeconds;
    final elapsed = _now.difference(start).inSeconds;
    final progress = total <= 0 ? 0.0 : (elapsed / total).clamp(0.0, 1.0);
    return (
      time: _fmt(end.difference(_now)),
      label: widget.countingLabel,
      color: colors.accentStrong,
      progress: progress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final locale = Localizations.localeOf(context);
    final r = _resolve(colors);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation2,
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
          child: Column(
            children: [
              SizedBox(
                width: 160.r,
                height: 160.r,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: r.progress,
                    trackColor: colors.foregroundPrimary,
                    progressColor: r.color,
                    strokeWidth: 14.r,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Vaqt — har doim bitta qatorda (zarur bo‘lsa kichrayadi).
                        SizedBox(
                          width: 120.r,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: r.time
                                .s(28.sp)
                                .w(600)
                                .c(colors.textStrong)
                                .h(32 / 28),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: r.label
                              .s(13.sp)
                              .w(500)
                              .c(colors.textSub)
                              .a(TextAlign.center)
                              .copyWith(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              '${AppDate.monthDay(_now, locale)} · ${widget.rangeText}'
                  .s(14.sp)
                  .w(500)
                  .c(colors.textStrong),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      final arc = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;
      // Yuqoridan (-90°) soat strelkasiga TESKARI (manfiy sweep) — Figma kabi.
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        -2 * math.pi * progress,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor ||
      old.strokeWidth != strokeWidth;
}
