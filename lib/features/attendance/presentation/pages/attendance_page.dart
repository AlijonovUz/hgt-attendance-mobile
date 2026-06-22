import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/widgets/home_stat_card.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/history/attendance_history_bloc.dart';
import '../widgets/attendance_day_card.dart';
import '../widgets/date_range_calendar.dart';
import '../widgets/history_filter_tabs.dart';

/// «Davomat tarixi» tab — Kunlik/Haftalik/Oylik + custom oraliq kalendar.
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AttendanceHistoryBloc>(
      create: (_) => getIt<AttendanceHistoryBloc>(),
      child: const _AttendanceHistoryView(),
    );
  }
}

class _AttendanceHistoryView extends StatefulWidget {
  const _AttendanceHistoryView();

  @override
  State<_AttendanceHistoryView> createState() => _AttendanceHistoryViewState();
}

class _AttendanceHistoryViewState extends State<_AttendanceHistoryView> {
  @override
  void initState() {
    super.initState();
    // Profil allaqachon yuklangan bo‘lsa (tab keyin ochilsa) — darhol sozlaymiz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _configure(context.read<ProfileBloc>().state);
    });
  }

  void _configure(ProfileState state) {
    final profile = state.profile;
    if (profile == null || profile.id.isEmpty) return;
    context.read<AttendanceHistoryBloc>().add(
      HistoryConfigured(userId: profile.id, schedule: profile.schedule),
    );
  }

  Future<void> _openCalendar() async {
    final bloc = context.read<AttendanceHistoryBloc>();
    final range = await showDateRangeCalendar(
      context,
      initialStart: bloc.state.rangeStart,
      initialEnd: bloc.state.rangeEnd,
    );
    if (range != null) {
      bloc.add(HistoryCustomRangeSelected(start: range.$1, end: range.$2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (p, c) =>
          p.profile?.id != c.profile?.id ||
          p.profile?.schedule != c.profile?.schedule,
      listener: (context, state) => _configure(state),
      child: Scaffold(
        backgroundColor: colors.backgroundBase,
        appBar: AppBar(
          backgroundColor: colors.backgroundBase,
          surfaceTintColor: colors.backgroundBase,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 20.w,
          automaticallyImplyLeading: false,
          title: l10n.navHistory.s(20.sp).w(700).c(colors.textStrong),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: BlocBuilder<AttendanceHistoryBloc, AttendanceHistoryState>(
                buildWhen: (p, c) => p.mode != c.mode,
                builder: (context, state) => _CalendarButton(
                  onTap: _openCalendar,
                  colors: colors,
                  active: state.mode == HistoryMode.custom,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
              child: BlocBuilder<AttendanceHistoryBloc, AttendanceHistoryState>(
                buildWhen: (p, c) => p.mode != c.mode,
                builder: (context, state) {
                  final index = switch (state.mode) {
                    HistoryMode.daily => 0,
                    HistoryMode.weekly => 1,
                    HistoryMode.monthly => 2,
                    HistoryMode.custom => -1,
                  };
                  return HistoryFilterTabs(
                    labels: [
                      l10n.historyTabDaily,
                      l10n.historyTabWeekly,
                      l10n.historyTabMonthly,
                    ],
                    selectedIndex: index,
                    onChanged: (i) => context
                        .read<AttendanceHistoryBloc>()
                        .add(HistoryModeChanged(HistoryMode.values[i])),
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<AttendanceHistoryBloc, AttendanceHistoryState>(
                builder: (context, state) => _Body(state: state, l10n: l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.l10n});

  final AttendanceHistoryState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (state.status == AttendanceHistoryStatus.loading ||
        state.status == AttendanceHistoryStatus.initial) {
      return Center(
        child: SizedBox(
          width: 28.r,
          height: 28.r,
          child: CircularProgressIndicator(
            strokeWidth: 2.5.r,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accentSub),
          ),
        ),
      );
    }

    if (state.status == AttendanceHistoryStatus.failure) {
      return _Centered(
        icon: Assets.icons.icHugeiconsClock,
        text: state.errorKind == AttendanceHistoryError.network
            ? l10n.networkError
            : l10n.historyError,
        colors: colors,
      );
    }

    if (state.days.isEmpty) {
      return _Centered(
        icon: Assets.icons.icHugeiconsClock,
        text: l10n.historyEmpty,
        colors: colors,
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      children: [
        if (state.showStats && state.stats != null) ...[
          _StatsGrid(state: state, l10n: l10n, colors: colors),
          SizedBox(height: 16.h),
        ],
        for (var i = 0; i < state.days.length; i++) ...[
          AttendanceDayCard(
            day: state.days[i],
            schedule: state.schedule,
            showHeader: state.showDayHeader,
          ),
          if (i != state.days.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.state,
    required this.l10n,
    required this.colors,
  });

  final AttendanceHistoryState state;
  final AppLocalizations l10n;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final stats = state.stats!;
    final avg = stats.avgCheckIn.trim().isEmpty ? '—' : stats.avgCheckIn;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HomeStatCard(
                label: l10n.historyStatPresent,
                value: '${stats.presentDays} ${l10n.historyUnitDays}',
                icon: Assets.icons.icHugeiconsNewJob,
                iconColor: AppColors.statOrange,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: HomeStatCard(
                label: l10n.historyStatLate,
                value: '${stats.lateDays} ${l10n.historyUnitDays}',
                icon: Assets.icons.icHugeiconsClock,
                iconColor: colors.errorStrong,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: HomeStatCard(
                label: l10n.historyStatAvgArrival,
                value: avg,
                icon: Assets.icons.icHugeiconsMedium,
                iconColor: AppColors.statPurple,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: HomeStatCard(
                label: l10n.historyStatWorked,
                value: '${stats.totalWorkedHours} ${l10n.historyUnitHours}',
                icon: Assets.icons.icHugeiconsDashboardSquare,
                iconColor: colors.accentSub,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// AppBar kalendar tugmasi (Figma 25:2879) — `shadow-xs` bilan. [active]
/// (custom filtr yoqilgan) bo‘lsa o‘ng-tepada qizil nuqta ko‘rinadi.
class _CalendarButton extends StatelessWidget {
  const _CalendarButton({
    required this.onTap,
    required this.colors,
    this.active = false,
  });

  final VoidCallback onTap;
  final AppColors colors;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36.w,
        height: 36.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.backgroundElevation2,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow,
                      offset: Offset(0, 1.h),
                      blurRadius: 2.r,
                    ),
                  ],
                ),
                child: Center(
                  child: Assets.icons.icHugeiconsCalendar.svg(
                    width: 16.w,
                    height: 16.h,
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            if (active)
              Positioned(
                top: -2.r,
                right: -2.r,
                child: Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: colors.errorStrong,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.backgroundBase, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({
    required this.icon,
    required this.text,
    required this.colors,
  });

  final SvgGenImage icon;
  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.svg(
            width: 48.r,
            height: 48.r,
            colorFilter: ColorFilter.mode(colors.iconSoft, BlendMode.srcIn),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: text
                .s(14.sp)
                .w(400)
                .c(colors.textSub)
                .a(TextAlign.center)
                .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
