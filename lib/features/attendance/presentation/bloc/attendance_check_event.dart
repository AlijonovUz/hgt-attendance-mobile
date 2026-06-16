part of 'attendance_check_bloc.dart';

sealed class AttendanceCheckEvent extends Equatable {
  const AttendanceCheckEvent();

  @override
  List<Object?> get props => [];
}

/// Ekran ochilganda — GPS + kamera + skan boshlanadi.
class AttendanceCheckStarted extends AttendanceCheckEvent {
  const AttendanceCheckStarted(this.eventType);
  final AttendanceEventType eventType;

  @override
  List<Object?> get props => [eventType];
}

/// ML Kit kadri natijasi (yuz bor/yo‘q).
class AttendanceFaceDetectionUpdated extends AttendanceCheckEvent {
  const AttendanceFaceDetectionUpdated({required this.facePresent});
  final bool facePresent;

  @override
  List<Object?> get props => [facePresent];
}

/// Selfie olib, davomatni yuborish (avtomatik yoki qo‘lda).
class AttendanceCaptureRequested extends AttendanceCheckEvent {
  const AttendanceCaptureRequested();
}

/// Xatodan keyin qayta urinish.
class AttendanceRetryRequested extends AttendanceCheckEvent {
  const AttendanceRetryRequested();
}
