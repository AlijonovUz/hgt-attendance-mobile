part of 'attendance_history_bloc.dart';

sealed class AttendanceHistoryEvent extends Equatable {
  const AttendanceHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Profil yuklangach — userId + schedule beriladi va boshlang‘ich (Kunlik)
/// ma’lumot yuklanadi.
class HistoryConfigured extends AttendanceHistoryEvent {
  const HistoryConfigured({required this.userId, this.schedule});

  final String userId;
  final ScheduleInfo? schedule;

  @override
  List<Object?> get props => [userId, schedule];
}

/// Segmented filter o‘zgardi (Kunlik/Haftalik/Oylik).
class HistoryModeChanged extends AttendanceHistoryEvent {
  const HistoryModeChanged(this.mode);

  final HistoryMode mode;

  @override
  List<Object?> get props => [mode];
}

/// Kalendar orqali custom oraliq tanlandi.
class HistoryCustomRangeSelected extends AttendanceHistoryEvent {
  const HistoryCustomRangeSelected({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];
}

/// Joriy oraliqni qayta yuklash.
class HistoryRefreshed extends AttendanceHistoryEvent {
  const HistoryRefreshed();
}
