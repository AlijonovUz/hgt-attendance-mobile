import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/swipe_action_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_step.dart';
import '../widgets/attendance_ring_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_stat_card.dart';
import '../widgets/today_schedule_card.dart';

/// «Asosiy» tab — kunlik davomat boshqaruvi (Figma 57:2055).
///
/// Profil schedule’i bosqichlarni va halqa/jadval vaqtlarini, `current_month_kpi`
/// esa statistikani belgilaydi. Surishda yuz-tekshiruvi ([AttendanceFacePage])
/// ochiladi → muvaffaqiyatda bosqich (swipe lahzasi) yoziladi va profil qayta
/// GET qilinadi.
class AsosiyPage extends StatelessWidget {
  const AsosiyPage({super.key, this.onAvatarNeedsPhoto, this.onLogout});

  final VoidCallback? onAvatarNeedsPhoto;
  final VoidCallback? onLogout;

  /// Bildirishnomalar ekraniga o‘tadi; qaytgach o‘qilmaganlar sonini yangilaydi
  /// (ekranda o‘qilgan bo‘lishi mumkin).
  Future<void> _openNotifications(BuildContext context) async {
    final bloc = context.read<NotificationBloc>();
    await context.pushNamed(Routes.notifications.name);
    if (context.mounted) bloc.add(const NotificationCountRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      // Profil yuklanganda faol bosqichlarni sozlab, bugungi yozuvlarni olamiz.
      child: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (p, c) => p.profile?.id != c.profile?.id || p.profile?.schedule != c.profile?.schedule,
        listener: (context, state) {
          final profile = state.profile;
          if (profile == null || profile.id.isEmpty) return;
          context.read<AttendanceBloc>().add(AttendanceConfigured(activeStepsFromSchedule(profile.schedule), profile.id));
        },
        child: Column(
          children: [
            // Qotirilgan sarlavha — scroll bo‘lmaydi (app-bar kabi).
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) =>
                    BlocBuilder<NotificationBloc, NotificationState>(
                  buildWhen: (p, c) => p.unreadCount != c.unreadCount,
                  builder: (context, notifState) => HomeHeader(
                    profile: state.profile,
                    usernameFallback: l10n.profileUsernameFallback,
                    onAvatarTap: state.needsPhoto ? onAvatarNeedsPhoto : null,
                    onAvatarLongPress: onLogout,
                    unreadCount: notifState.unreadCount,
                    onNotificationsTap: () => _openNotifications(context),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
                children: [
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, profileState) {
                      final schedule = profileState.profile?.schedule;
                      return BlocBuilder<AttendanceBloc, AttendanceState>(
                        builder: (context, state) {
                          final phase = _ringPhase(state, schedule, l10n);
                          return Column(
                            spacing: 20,
                            children: [
                              AttendanceRingCard(
                                start: phase.start,
                                end: phase.end,
                                countingLabel: phase.countingLabel,
                                overdueLabel: phase.overdueLabel,
                                rangeText: phase.rangeText,
                                idle: phase.idle,
                                idleLabel: phase.idleLabel,
                                done: phase.done,
                                worked: phase.worked,
                                doneLabel: phase.doneLabel,
                              ),
                              Visibility(
                                visible: !state.isComplete,
                                child: _SwipeSection(state: state, colors: colors, l10n: l10n),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  const TodayScheduleCard(),
                  SizedBox(height: 16.h),
                  _StatRow(colors: colors, l10n: l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// KPI + oylik davomat kartalari (profil `current_month_kpi` dan).
class _StatRow extends StatelessWidget {
  const _StatRow({required this.colors, required this.l10n});

  final AppColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final kpi = state.profile?.kpi;
        final kpiValue = kpi == null ? '—' : '${kpi.monthlyKpi.toStringAsFixed(0)}%';
        final attendance = kpi?.monthlyAttendance ?? '—';

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: HomeStatCard(
                  label: l10n.homeKpi,
                  value: kpiValue,
                  icon: Assets.icons.icHugeiconsMoneyReceiveFlow,
                  iconColor: colors.successPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: HomeStatCard(
                  label: l10n.homeMonthlyAttendance,
                  value: attendance,
                  icon: Assets.icons.icHugeiconsDataTime,
                  iconColor: colors.accentStrong,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Surish tugmasi + ostidagi maslahat (yoki barchasi tugagach — yakun holati).
class _SwipeSection extends StatelessWidget {
  const _SwipeSection({required this.state, required this.colors, required this.l10n});

  final AttendanceState state;
  final AppColors colors;
  final AppLocalizations l10n;

  /// Swipe → yuz-tekshiruvi → muvaffaqiyatda backenddan qayta yuklash + profil
  /// re-GET (KPI/davomat yangilanadi). Vaqtlar backend `created_at` dan keladi.
  Future<void> _onCompleted(BuildContext context) async {
    final ok = await context.pushNamed<bool>(Routes.attendanceFace.name, extra: state.current.eventType);
    if (ok == true && context.mounted) {
      context.read<AttendanceBloc>().add(const AttendanceRefreshed());
      context.read<ProfileBloc>().add(const ProfileRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state.isComplete) {
      return SizedBox.shrink() /*Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Assets.icons.icHugeiconsCheckmarkBadge.svg(
              width: 20.r,
              height: 20.r,
              colorFilter: ColorFilter.mode(
                colors.successPrimary,
                BlendMode.srcIn,
              ),
            ),
            l10n.homeAllDone.s(14.sp).w(600).c(colors.textStrong),
          ],
        ),
      )*/;
    }

    final cfg = _swipeConfig(state.current, l10n);
    return Column(
      children: [
        SwipeActionButton(
          key: ValueKey(state.current),
          label: cfg.label,
          fillGradient: cfg.gradient,
          trackColor: cfg.track,
          // Yuz sahifasiga o‘tilganda dasta avtomatik boshiga qaytadi —
          // bekor/xato bo‘lganda ham (bosqich o‘zgarmaganda) to‘g‘ri ko‘rinadi.
          resetAfterComplete: true,
          onCompleted: () => _onCompleted(context),
        ),
        SizedBox(height: 8.h),
        Center(child: l10n.homeSwipeHint.s(14.sp).w(400).c(colors.textSub).a(TextAlign.center)),
      ],
    );
  }
}

/// Halqa joriy oralig‘ini hisoblaydi (kelish→tushlik→qaytish→ketish).
///
/// Oraliq boshlanishi — haqiqiy belgilangan vaqt (backend `created_at`); tugashi
/// — schedule’dagi keyingi belgilangan vaqt. Ish tugab ketilsa — ishlagan vaqt.
({DateTime? start, DateTime? end, String countingLabel, String overdueLabel, String rangeText, bool idle, String idleLabel, bool done, Duration worked, String doneLabel})
_ringPhase(AttendanceState state, ScheduleInfo? sch, AppLocalizations l10n) {
  final now = DateTime.now();

  DateTime at(String? hms, int fh, int fm) {
    final p = (hms ?? '').split(':');
    final h = (p.isNotEmpty && p[0].isNotEmpty) ? (int.tryParse(p[0]) ?? fh) : fh;
    final m = p.length > 1 ? (int.tryParse(p[1]) ?? fm) : fm;
    return DateTime(now.year, now.month, now.day, h, m);
  }

  String hhmm(String? hms, int fh) {
    final d = at(hms, fh, 0);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}';
  }

  final we = at(sch?.workEndTime, 18, 0);
  final hasLunch = (sch?.lunchStartTime ?? '').isNotEmpty && (sch?.lunchEndTime ?? '').isNotEmpty;
  final ls = hasLunch ? at(sch!.lunchStartTime, 13, 0) : null;
  final le = hasLunch ? at(sch!.lunchEndTime, 14, 0) : null;
  final rangeText = '${hhmm(sch?.workStartTime, 9)}–${hhmm(sch?.workEndTime, 18)}';

  // Ishdan ketilgan / yakuniy — bugungi ishlagan vaqt.
  if (state.departureAt != null || state.current == AttendanceStep.done) {
    final a = state.arrivalAt;
    var worked = Duration.zero;
    if (a != null) {
      final end = state.departureAt ?? we;
      var d = end.difference(a);
      final lo = state.lunchOutAt, li = state.lunchInAt;
      if (lo != null && li != null && li.isAfter(lo)) d -= li.difference(lo);
      worked = d.isNegative ? Duration.zero : d;
    }
    return (
      start: null,
      end: null,
      countingLabel: '',
      overdueLabel: '',
      rangeText: rangeText,
      idle: false,
      idleLabel: '',
      done: true,
      worked: worked,
      doneLabel: l10n.homeWorkDayDone,
    );
  }

  return switch (state.current) {
    // Hali kelmagan — sanamaydi, bo‘sh halqa «Ishni boshlash» (Figma 301:9387).
    AttendanceStep.arrive => (
      start: null,
      end: null,
      countingLabel: '',
      overdueLabel: '',
      rangeText: rangeText,
      idle: true,
      idleLabel: l10n.homeNotStarted,
      done: false,
      worked: Duration.zero,
      doneLabel: '',
    ),
    // Kelishdan tushlikka chiqishgacha — haqiqiy kelish vaqtidan sanaladi.
    AttendanceStep.lunchOut => (
      start: state.arrivalAt,
      end: ls ?? we,
      countingLabel: l10n.homeUntilLunch,
      overdueLabel: l10n.homeTimeToLunchOut,
      rangeText: rangeText,
      idle: false,
      idleLabel: '',
      done: false,
      worked: Duration.zero,
      doneLabel: '',
    ),
    // Tushlikka chiqishdan qaytishgacha — haqiqiy chiqish vaqtidan sanaladi.
    AttendanceStep.lunchIn => (
      start: state.lunchOutAt,
      end: le ?? we,
      countingLabel: l10n.homeUntilLunchEnd,
      overdueLabel: l10n.homeTimeToLunchIn,
      rangeText: rangeText,
      idle: false,
      idleLabel: '',
      done: false,
      worked: Duration.zero,
      doneLabel: '',
    ),
    // Tushlikdan qaytishdan ish tugashigacha — haqiqiy qaytish vaqtidan sanaladi.
    AttendanceStep.leave => (
      start: state.lunchInAt ?? state.arrivalAt,
      end: we,
      countingLabel: l10n.homeWorkEndsIn,
      overdueLabel: l10n.homeTimeToLeave,
      rangeText: rangeText,
      idle: false,
      idleLabel: '',
      done: false,
      worked: Duration.zero,
      doneLabel: '',
    ),
    AttendanceStep.done => (
      start: null,
      end: null,
      countingLabel: '',
      overdueLabel: '',
      rangeText: rangeText,
      idle: false,
      idleLabel: '',
      done: true,
      worked: Duration.zero,
      doneLabel: l10n.homeWorkDayDone,
    ),
  };
}

/// Bosqichga mos yozuv + gradient + yo‘lak rangi.
({String label, Gradient gradient, Color track}) _swipeConfig(AttendanceStep step, AppLocalizations l10n) => switch (step) {
  AttendanceStep.arrive => (label: l10n.homeScheduleArrive, gradient: AppColors.swipeArriveGradient, track: AppColors.swipeTrackBlue),
  AttendanceStep.lunchOut => (label: l10n.homeScheduleLunchOut, gradient: AppColors.swipeLunchGradient, track: AppColors.swipeTrackOrange),
  AttendanceStep.lunchIn => (label: l10n.homeScheduleLunchIn, gradient: AppColors.swipeLunchGradient, track: AppColors.swipeTrackOrange),
  AttendanceStep.leave => (label: l10n.homeScheduleLeave, gradient: AppColors.swipeLeaveGradient, track: AppColors.swipeTrackGreen),
  AttendanceStep.done => (label: l10n.homeScheduleLeave, gradient: AppColors.swipeLeaveGradient, track: AppColors.swipeTrackGreen),
};
