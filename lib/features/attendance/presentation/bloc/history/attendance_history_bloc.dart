import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../home/presentation/bloc/attendance_step.dart';
import '../../../../profile/domain/entities/profile.dart';
import '../../../domain/entities/attendance_event.dart';
import '../../../domain/entities/attendance_stats.dart';
import '../../../domain/usecases/get_attendance_history_usecase.dart';
import '../../../domain/usecases/get_personal_stats_usecase.dart';

part 'attendance_history_event.dart';
part 'attendance_history_state.dart';

/// «Davomat tarixi» holatini boshqaradi (Kunlik/Haftalik/Oylik/Custom).
///
/// Rejim yoki sana o‘zgarsa: oraliq yozuvlarini (`rangeEvents`) oladi, lokal
/// sana bo‘yicha [AttendanceDay] larga guruhlaydi, kechikishni profil schedule
/// bilan belgilaydi; Kunlikdan boshqa rejimlarda statistikani ham (`personalStats`)
/// yuklaydi. Bloc context-free: xato enumini emit qiladi, lokalizatsiya widgetda.
class AttendanceHistoryBloc
    extends Bloc<AttendanceHistoryEvent, AttendanceHistoryState> {
  AttendanceHistoryBloc({
    required GetAttendanceHistoryUseCase getHistory,
    required GetPersonalStatsUseCase getStats,
  })  : _getHistory = getHistory,
        _getStats = getStats,
        super(const AttendanceHistoryState()) {
    on<HistoryConfigured>(_onConfigured);
    on<HistoryModeChanged>(_onModeChanged);
    on<HistoryCustomRangeSelected>(_onCustomRange);
    on<HistoryRefreshed>(_onRefreshed);
  }

  final GetAttendanceHistoryUseCase _getHistory;
  final GetPersonalStatsUseCase _getStats;

  Future<void> _onConfigured(
    HistoryConfigured event,
    Emitter<AttendanceHistoryState> emit,
  ) async {
    final firstConfig = state.userId == null;
    emit(state.copyWith(userId: event.userId, schedule: event.schedule));
    // Faqat birinchi konfiguratsiyada (yoki bo‘sh bo‘lsa) yuklab olamiz.
    if (firstConfig || state.status != AttendanceHistoryStatus.loaded) {
      await _loadFor(state.mode, emit);
    }
  }

  Future<void> _onModeChanged(
    HistoryModeChanged event,
    Emitter<AttendanceHistoryState> emit,
  ) async {
    if (event.mode == state.mode && event.mode != HistoryMode.custom) return;
    await _loadFor(event.mode, emit);
  }

  Future<void> _onCustomRange(
    HistoryCustomRangeSelected event,
    Emitter<AttendanceHistoryState> emit,
  ) async {
    final start = _dayStart(event.start);
    final end = _dayStart(event.end);
    await _loadFor(
      HistoryMode.custom,
      emit,
      customStart: start.isBefore(end) ? start : end,
      customEnd: start.isBefore(end) ? end : start,
    );
  }

  Future<void> _onRefreshed(
    HistoryRefreshed event,
    Emitter<AttendanceHistoryState> emit,
  ) async {
    await _loadFor(
      state.mode,
      emit,
      customStart: state.rangeStart,
      customEnd: state.rangeEnd,
    );
  }

  Future<void> _loadFor(
    HistoryMode mode,
    Emitter<AttendanceHistoryState> emit, {
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    final userId = state.userId;
    if (userId == null || userId.isEmpty) return;

    final (start, end) = switch (mode) {
      HistoryMode.daily => _dailyRange(),
      HistoryMode.weekly => _weeklyRange(),
      HistoryMode.monthly => _monthlyRange(),
      HistoryMode.custom => (
          customStart ?? state.rangeStart ?? _dayStart(DateTime.now()),
          customEnd ?? state.rangeEnd ?? _dayStart(DateTime.now()),
        ),
    };

    emit(state.copyWith(
      mode: mode,
      rangeStart: start,
      rangeEnd: end,
      status: AttendanceHistoryStatus.loading,
      errorKind: AttendanceHistoryError.none,
    ));

    try {
      final events = await _getHistory(
        GetAttendanceHistoryParams(userId: userId, start: start, end: end),
      );
      final days = _groupDays(events, state.schedule);

      AttendanceStats? stats;
      if (mode != HistoryMode.daily) {
        try {
          stats = await _getStats(
            GetPersonalStatsParams(start: start, end: end),
          );
        } on Failure {
          stats = null; // statistika bo‘lmasa — kartalarsiz ko‘rsatamiz.
        }
      }

      emit(state.copyWith(
        status: AttendanceHistoryStatus.loaded,
        days: days,
        stats: stats,
        clearStats: stats == null,
      ));
    } on Failure catch (failure) {
      emit(state.copyWith(
        status: AttendanceHistoryStatus.failure,
        errorKind: failure is NetworkFailure
            ? AttendanceHistoryError.network
            : AttendanceHistoryError.server,
      ));
    }
  }

  // ── Sana oraliqlari ─────────────────────────────────────────────────────
  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  (DateTime, DateTime) _dailyRange() {
    final today = _dayStart(DateTime.now());
    return (today, today);
  }

  (DateTime, DateTime) _weeklyRange() {
    final today = _dayStart(DateTime.now());
    // Dushanba = 1 … Yakshanba = 7.
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return (monday, sunday);
  }

  (DateTime, DateTime) _monthlyRange() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final last = DateTime(now.year, now.month + 1, 0);
    return (first, last);
  }

  // ── Guruhlash + kechikish ────────────────────────────────────────────────
  List<AttendanceDay> _groupDays(
    List<AttendanceEvent> events,
    ScheduleInfo? schedule,
  ) {
    // Kun (lokal) → bosqich → eng erta vaqt.
    final byDay = <DateTime, Map<AttendanceStep, DateTime>>{};
    for (final ev in events) {
      final step = stepForEventType(ev.eventType);
      if (step == null) continue;
      final local = ev.createdAt.toLocal();
      final day = _dayStart(local);
      final map = byDay.putIfAbsent(day, () => {});
      final existing = map[step];
      if (existing == null || local.isBefore(existing)) {
        map[step] = local;
      }
    }

    final days = byDay.entries.map((e) {
      final times = e.value;
      return AttendanceDay(
        date: e.key,
        times: times,
        worked: _workedDuration(times),
        lateSteps: _lateSteps(times, schedule),
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // eng yangisi birinchi

    return days;
  }

  Duration? _workedDuration(Map<AttendanceStep, DateTime> t) {
    final inT = t[AttendanceStep.arrive];
    final outT = t[AttendanceStep.leave];
    if (inT == null || outT == null || !outT.isAfter(inT)) return null;
    var worked = outT.difference(inT);
    final lOut = t[AttendanceStep.lunchOut];
    final lIn = t[AttendanceStep.lunchIn];
    if (lOut != null && lIn != null && lIn.isAfter(lOut)) {
      worked -= lIn.difference(lOut);
    }
    return worked.isNegative ? null : worked;
  }

  Set<AttendanceStep> _lateSteps(
    Map<AttendanceStep, DateTime> t,
    ScheduleInfo? schedule,
  ) {
    if (schedule == null) return const {};
    final late = <AttendanceStep>{};

    int? mins(String? hms) {
      if (hms == null || hms.isEmpty) return null;
      final parts = hms.split(':');
      if (parts.length < 2) return null;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) return null;
      return h * 60 + m;
    }

    int tod(DateTime d) => d.hour * 60 + d.minute;

    void checkLater(AttendanceStep step, String? sched) {
      final actual = t[step];
      final s = mins(sched);
      if (actual != null && s != null && tod(actual) > s) late.add(step);
    }

    void checkEarlier(AttendanceStep step, String? sched) {
      final actual = t[step];
      final s = mins(sched);
      if (actual != null && s != null && tod(actual) < s) late.add(step);
    }

    checkLater(AttendanceStep.arrive, schedule.workStartTime);
    checkLater(AttendanceStep.lunchIn, schedule.lunchEndTime);
    checkEarlier(AttendanceStep.leave, schedule.workEndTime);
    return late;
  }
}
