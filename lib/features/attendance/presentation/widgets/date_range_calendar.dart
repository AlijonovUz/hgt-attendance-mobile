import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';

/// Custom sana-oraliq tanlash kalendari (Figma 811:15398) — markazda dialog,
/// 32px kataklar, oy o‘zgartirish chevronlari (fonsiz), oraliq uzluksiz och
/// tasma + uchlari to‘q kvadrat. Birinchi bosish = start, ikkinchi = end
/// (kichik–katta avtomatik) → yopiladi.
Future<(DateTime, DateTime)?> showDateRangeCalendar(
  BuildContext context, {
  DateTime? initialStart,
  DateTime? initialEnd,
}) {
  return showDialog<(DateTime, DateTime)>(
    context: context,
    barrierColor: AppColors.of(context).black.withValues(alpha: 0.5),
    builder: (_) => _DateRangeCalendarDialog(
      initialStart: initialStart,
      initialEnd: initialEnd,
    ),
  );
}

class _DateRangeCalendarDialog extends StatefulWidget {
  const _DateRangeCalendarDialog({this.initialStart, this.initialEnd});

  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<_DateRangeCalendarDialog> createState() =>
      _DateRangeCalendarDialogState();
}

class _DateRangeCalendarDialogState extends State<_DateRangeCalendarDialog> {
  late DateTime _cursor; // ko‘rsatilayotgan oy
  DateTime? _start;
  DateTime? _end;

  static const double _cell = 32; // logical (keyin .r bilan masshtablanadi)

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    final base = widget.initialStart ?? DateTime.now();
    _cursor = DateTime(base.year, base.month);
  }

  void _onTapDay(DateTime day) {
    setState(() {
      if (_start == null || _end != null) {
        _start = day;
        _end = null;
      } else if (day.isBefore(_start!)) {
        _end = _start;
        _start = day;
      } else {
        _end = day;
      }
    });
    if (_start != null && _end != null) {
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) Navigator.of(context).pop((_start!, _end!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Dialog(
      backgroundColor: colors.popover,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(colors),
            SizedBox(height: 16.h),
            _weekdayHeader(colors),
            SizedBox(height: 4.h),
            ..._buildWeeks(colors),
          ],
        ),
      ),
    );
  }

  Widget _header(AppColors colors) {
    return SizedBox(
      width: _cell.r * 7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navButton(
            colors,
            Assets.icons.icHugeiconsArrowLeftRound,
            () => setState(
              () => _cursor = DateTime(_cursor.year, _cursor.month - 1),
            ),
          ),
          Expanded(
            child: Center(
              child: '${_monthNames[_cursor.month - 1]} ${_cursor.year}'
                  .s(16.sp)
                  .w(600)
                  .c(colors.textStrong),
            ),
          ),
          _navButton(
            colors,
            Assets.icons.icHugeiconsArrowRightRound,
            () => setState(
              () => _cursor = DateTime(_cursor.year, _cursor.month + 1),
            ),
          ),
        ],
      ),
    );
  }

  /// Oq fon + `stroke-sub` ramka + `shadow-xs` (Figma 25:2970).
  Widget _navButton(AppColors colors, SvgGenImage icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _cell.r,
        height: _cell.r,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: colors.strokeSub),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                offset: Offset(0, 1.h),
                blurRadius: 2.r,
              ),
            ],
          ),
          child: Center(
            child: icon.svg(
              width: 16.r,
              height: 16.r,
              colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  Widget _weekdayHeader(AppColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final w in _weekdayLabels)
          SizedBox(
            width: _cell.r,
            child: Center(child: w.s(13.sp).w(400).c(colors.textSub)),
          ),
      ],
    );
  }

  List<Widget> _buildWeeks(AppColors colors) {
    final first = DateTime(_cursor.year, _cursor.month, 1);
    final daysInMonth = DateTime(_cursor.year, _cursor.month + 1, 0).day;
    final leading = first.weekday % 7; // Yakshanba = 0-ustun.

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(_adjacentCell(colors, first.add(Duration(days: i - leading))));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(_dayCell(colors, DateTime(_cursor.year, _cursor.month, d)));
    }
    var next = 1;
    while (cells.length % 7 != 0) {
      cells.add(
        _adjacentCell(colors, DateTime(_cursor.year, _cursor.month + 1, next)),
      );
      next++;
    }

    final weeks = <Widget>[];
    for (var i = 0; i < cells.length; i += 7) {
      weeks.add(
        Row(mainAxisSize: MainAxisSize.min, children: cells.sublist(i, i + 7)),
      );
    }
    return weeks;
  }

  Widget _adjacentCell(AppColors colors, DateTime date) {
    return SizedBox(
      width: _cell.r,
      height: 40.h,
      child: Center(
        child: '${date.day}'.s(14.sp).w(400).c(colors.textDisabled),
      ),
    );
  }

  Widget _dayCell(AppColors colors, DateTime date) {
    final isStart = _start != null && _sameDay(date, _start!);
    final isEnd = _end != null && _sameDay(date, _end!);
    final endpoint = isStart || isEnd;
    final inRange = _start != null &&
        _end != null &&
        date.isAfter(_start!) &&
        date.isBefore(_end!);
    final banded = endpoint || inRange;

    final col = date.weekday % 7; // 0..6 (Su..Sa)
    final roundLeft = isStart || col == 0;
    final roundRight = isEnd || col == 6;

    return SizedBox(
      width: _cell.r,
      height: 40.h,
      child: GestureDetector(
        onTap: () => _onTapDay(date),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Uzluksiz oraliq tasmasi (kataklar tegib turadi).
            if (banded)
              Center(
                child: Container(
                  height: _cell.r,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.backgroundElevation2,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(roundLeft ? 8.r : 0),
                      right: Radius.circular(roundRight ? 8.r : 0),
                    ),
                  ),
                ),
              ),
            // Uch nuqtalari — to‘q kvadrat.
            if (endpoint)
              SizedBox(
                width: _cell.r,
                height: _cell.r,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.textStrong,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            '${date.day}'
                .s(14.sp)
                .w(endpoint ? 600 : 400)
                .c(endpoint ? colors.backgroundBase : colors.textStrong),
          ],
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

const _weekdayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
