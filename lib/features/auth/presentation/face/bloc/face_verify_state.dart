part of 'face_verify_bloc.dart';

/// Yuz tasdig‘i bosqichlari. Doira ramkasi rangi shu holatdan kelib chiqadi:
/// ko‘k (skan), yashil (tasdiq), qizil (xato).
enum FaceStatus {
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
enum FaceFailureKind { none, noFace, verifyFailed, network }

class FaceVerifyState extends Equatable {
  const FaceVerifyState({
    this.status = FaceStatus.initializing,
    this.failureKind = FaceFailureKind.none,
    this.fullName = '',
  });

  final FaceStatus status;
  final FaceFailureKind failureKind;

  /// Karta sarlavhasi uchun login’da kiritilgan ism.
  final String fullName;

  bool get isCameraLive =>
      status == FaceStatus.scanning ||
      status == FaceStatus.detecting ||
      status == FaceStatus.verifying;

  bool get isBusy => status == FaceStatus.verifying;

  FaceVerifyState copyWith({
    FaceStatus? status,
    FaceFailureKind? failureKind,
    String? fullName,
  }) {
    return FaceVerifyState(
      status: status ?? this.status,
      failureKind: failureKind ?? this.failureKind,
      fullName: fullName ?? this.fullName,
    );
  }

  @override
  List<Object?> get props => [status, failureKind, fullName];
}
