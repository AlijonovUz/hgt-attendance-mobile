part of 'attendance_check_bloc.dart';

/// Davomat yuz-tekshiruvi bosqichlari (doira ramkasi rangini belgilaydi).
enum AttendanceCheckStatus {
  initializing,
  scanning,
  detecting,
  verifying,
  success,
  failure,
  permissionDenied,
  cameraError,
}

/// Xato sababi — lokalizatsiya widget qatlamida.
enum AttendanceFailureKind { none, noFace, verifyFailed, network, location }

class AttendanceCheckState extends Equatable {
  const AttendanceCheckState({
    this.status = AttendanceCheckStatus.initializing,
    this.failureKind = AttendanceFailureKind.none,
  });

  final AttendanceCheckStatus status;
  final AttendanceFailureKind failureKind;

  bool get isCameraLive =>
      status == AttendanceCheckStatus.scanning ||
      status == AttendanceCheckStatus.detecting ||
      status == AttendanceCheckStatus.verifying;

  AttendanceCheckState copyWith({
    AttendanceCheckStatus? status,
    AttendanceFailureKind? failureKind,
  }) {
    return AttendanceCheckState(
      status: status ?? this.status,
      failureKind: failureKind ?? this.failureKind,
    );
  }

  @override
  List<Object?> get props => [status, failureKind];
}
