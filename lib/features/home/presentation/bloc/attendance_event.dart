part of 'attendance_bloc.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Profil schedule’i bo‘yicha faol bosqichlarni o‘rnatadi + bugungilarni yuklaydi.
class AttendanceConfigured extends AttendanceEvent {
  const AttendanceConfigured(this.steps, this.userId);
  final List<AttendanceStep> steps;
  final String userId;

  @override
  List<Object?> get props => [steps, userId];
}

/// Bugungi yozuvlarni qayta yuklash (yuz-tekshiruvdan keyin).
class AttendanceRefreshed extends AttendanceEvent {
  const AttendanceRefreshed();
}
