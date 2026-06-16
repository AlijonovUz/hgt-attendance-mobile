import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_step.dart';

/// «Bugungi tartib» kartasi (Figma 301:9685) — kun davomidagi belgilash
/// nuqtalari: ikonka + nomi + vaqt + holat ikonkasi.
///
/// Bosqichlar profil schedule’iga mos (null vaqtli — masalan tushlik yo‘q —
/// ko‘rinmaydi). Belgilangan bosqich haqiqiy vaqt (swipe lahzasi) + yashil
/// tasdiq; qolgani belgilangan (schedule) vaqt + sariq belgi.
class TodayScheduleCard extends StatelessWidget {
  const TodayScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation2,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            final schedule = profileState.profile?.schedule;
            return BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    l10n.homeTodaySchedule.s(14.sp).w(500).c(colors.textSub),
                    Column(
                      spacing: 12,
                      children: [
                        for (final step in state.steps)
                          _ScheduleRow(
                            step: step,
                            time:
                                state.recordedTime(step) ??
                                (step.scheduleTime(schedule) ?? '--:--:--'),
                            done: state.isDone(step),
                            colors: colors,
                            l10n: l10n,
                          ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

SvgGenImage _stepIcon(AttendanceStep step) => switch (step) {
  AttendanceStep.arrive => Assets.icons.icHugeiconsLogin,
  AttendanceStep.lunchOut => Assets.icons.icHugeiconsPizza,
  AttendanceStep.lunchIn => Assets.icons.icHugeiconsPizza,
  AttendanceStep.leave => Assets.icons.icHugeiconsLogout,
  AttendanceStep.done => Assets.icons.icHugeiconsLogout,
};

String _stepLabel(AttendanceStep step, AppLocalizations l10n) => switch (step) {
  AttendanceStep.arrive => l10n.homeScheduleArrive,
  AttendanceStep.lunchOut => l10n.homeScheduleLunchOut,
  AttendanceStep.lunchIn => l10n.homeScheduleLunchIn,
  AttendanceStep.leave => l10n.homeScheduleLeave,
  AttendanceStep.done => l10n.homeScheduleLeave,
};

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.step,
    required this.time,
    required this.done,
    required this.colors,
    required this.l10n,
  });

  final AttendanceStep step;
  final String time;
  final bool done;
  final AppColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 8,
          children: [
            SizedBox(
              width: 40.r,
              height: 40.r,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colors.backgroundElevation1,
                ),
                child: Center(
                  child: _stepIcon(step).svg(
                    width: 24.r,
                    height: 24.r,
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            _stepLabel(step, l10n)
                .s(16.sp)
                .w(500)
                .c(colors.textStrong)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        _TimePill(time: time, done: done, colors: colors),
      ],
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.time,
    required this.done,
    required this.colors,
  });

  final String time;
  final bool done;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            time.s(13.sp).w(500).c(colors.textStrong),
            if (done)
              Assets.icons.icHugeiconsCheckmarkBadge.svg(
                width: 16.r,
                height: 16.r,
                colorFilter: ColorFilter.mode(
                  colors.successPrimary,
                  BlendMode.srcIn,
                ),
              )
            else
              Assets.icons.icHugeiconsLoading.svg(
                width: 16.r,
                height: 16.r,
                colorFilter: ColorFilter.mode(
                  AppColors.warningStrong,
                  BlendMode.srcIn,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
