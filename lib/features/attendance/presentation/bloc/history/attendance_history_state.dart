part of 'attendance_history_bloc.dart';

/// Filter rejimi.
enum HistoryMode { daily, weekly, monthly, custom }

enum AttendanceHistoryStatus { initial, loading, loaded, failure }

enum AttendanceHistoryError { none, network, server }

/// Bir kunlik guruhlangan davomat (tarix kartasi uchun).
class AttendanceDay extends Equatable {
  const AttendanceDay({
    required this.date,
    required this.times,
    this.worked,
    this.lateSteps = const {},
  });

  /// Kun (lokal, 00:00).
  final DateTime date;

  /// Bosqich → belgilangan haqiqiy vaqt (lokal).
  final Map<AttendanceStep, DateTime> times;

  /// Shu kunda ishlagan vaqt (kelish→ketish minus tushlik), agar hisoblansa.
  final Duration? worked;

  /// Kechikkan / erta ketgan bosqichlar (qizil ko‘rsatiladi).
  final Set<AttendanceStep> lateSteps;

  @override
  List<Object?> get props => [date, times, worked, lateSteps];
}

class AttendanceHistoryState extends Equatable {
  const AttendanceHistoryState({
    this.mode = HistoryMode.daily,
    this.status = AttendanceHistoryStatus.initial,
    this.errorKind = AttendanceHistoryError.none,
    this.days = const [],
    this.stats,
    this.rangeStart,
    this.rangeEnd,
    this.schedule,
    this.userId,
  });

  final HistoryMode mode;
  final AttendanceHistoryStatus status;
  final AttendanceHistoryError errorKind;
  final List<AttendanceDay> days;
  final AttendanceStats? stats;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ScheduleInfo? schedule;
  final String? userId;

  /// Statistika kartalari faqat Kunlikdan boshqa rejimlarda ko‘rsatiladi.
  bool get showStats => mode != HistoryMode.daily;

  /// Kunlik kartada sarlavha (sana + ishlagan vaqt) yashiriladi.
  bool get showDayHeader => mode != HistoryMode.daily;

  AttendanceHistoryState copyWith({
    HistoryMode? mode,
    AttendanceHistoryStatus? status,
    AttendanceHistoryError? errorKind,
    List<AttendanceDay>? days,
    AttendanceStats? stats,
    bool clearStats = false,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    ScheduleInfo? schedule,
    String? userId,
  }) {
    return AttendanceHistoryState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      errorKind: errorKind ?? this.errorKind,
      days: days ?? this.days,
      stats: clearStats ? null : (stats ?? this.stats),
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      schedule: schedule ?? this.schedule,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    status,
    errorKind,
    days,
    stats,
    rangeStart,
    rangeEnd,
    schedule,
    userId,
  ];
}
