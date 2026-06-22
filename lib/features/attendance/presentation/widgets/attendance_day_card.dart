import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/bloc/attendance_step.dart';
import '../../../profile/domain/entities/profile.dart';
import '../bloc/history/attendance_history_bloc.dart';
import 'history_date_label.dart';

/// Bir kunlik davomat kartasi (Figma 782:15858): ixtiyoriy sarlavha
/// (sana + ishlagan vaqt) + bosqich qatorlari. Belgilangan & kechikkan → qizil,
/// belgilangan & vaqtida → to‘q, belgilanmagan → kulrang (rejadagi vaqt).
class AttendanceDayCard extends StatelessWidget {
  const AttendanceDayCard({
    super.key,
    required this.day,
    required this.schedule,
    required this.showHeader,
  });

  final AttendanceDay day;
  final ScheduleInfo? schedule;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final steps = activeStepsFromSchedule(schedule);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation2,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                child: _header(context, l10n, colors),
              ),
            for (var i = 0; i < steps.length; i++) ...[
              _EventRow(
                step: steps[i],
                day: day,
                schedule: schedule,
                l10n: l10n,
                colors: colors,
              ),
              if (i != steps.length - 1)
                Divider(height: 1, color: colors.strokeSub),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    AppLocalizations l10n,
    AppColors colors,
  ) {
    final label = historyDayLabel(context, day.date, l10n);
    final worked = day.worked;
    final text = worked == null
        ? label
        : '$label - ${worked.inHours}${' '}${l10n.historyUnitHours}'
            ' ${worked.inMinutes % 60} ${l10n.historyUnitMinutes}';
    return text
        .s(15.sp)
        .w(600)
        .c(colors.textStrong)
        .h(20 / 15)
        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.step,
    required this.day,
    required this.schedule,
    required this.l10n,
    required this.colors,
  });

  final AttendanceStep step;
  final AttendanceDay day;
  final ScheduleInfo? schedule;
  final AppLocalizations l10n;
  final AppColors colors;

  String _label() => switch (step) {
    AttendanceStep.arrive => l10n.historyEventArrived,
    AttendanceStep.lunchOut => l10n.historyEventLunchOut,
    AttendanceStep.lunchIn => l10n.historyEventLunchIn,
    AttendanceStep.leave => l10n.historyEventLeft,
    AttendanceStep.done => '',
  };

  /// "HH:mm" — belgilangan haqiqiy vaqt yoki rejadagi (schedule) vaqt.
  String _time() {
    final actual = day.times[step];
    if (actual != null) {
      return '${_two(actual.hour)}:${_two(actual.minute)}';
    }
    final sched = step.scheduleTime(schedule);
    if (sched != null && sched.length >= 5) return sched.substring(0, 5);
    return '—';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final recorded = day.times.containsKey(step);
    final late = day.lateSteps.contains(step);
    final color = !recorded
        ? colors.textSub
        : (late ? colors.errorStrong : colors.textStrong);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: _label()
                .s(14.sp)
                .w(400)
                .c(color)
                .h(20 / 14)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 12.w),
          _time().s(14.sp).w(600).c(color).h(20 / 14),
        ],
      ),
    );
  }
}
