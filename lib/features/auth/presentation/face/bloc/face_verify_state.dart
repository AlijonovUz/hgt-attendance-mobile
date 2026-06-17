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

/// Xato sababi — lokalizatsiya widget qatlamida. [location] faqat davomat
/// rejimida (GPS olinmasa) uchraydi.
enum FaceFailureKind { none, noFace, verifyFailed, network, location }

class FaceVerifyState extends Equatable {
  const FaceVerifyState({
    this.status = FaceStatus.initializing,
    this.failureKind = FaceFailureKind.none,
    this.fullName = '',
    this.failureMessage,
  });

  final FaceStatus status;
  final FaceFailureKind failureKind;

  /// Karta sarlavhasi uchun login’da kiritilgan ism.
  final String fullName;

  /// Backend `errorMsg`i (mavjud bo‘lsa) — to‘g‘ridan-to‘g‘ri ko‘rsatiladi.
  final String? failureMessage;

  bool get isCameraLive =>
      status == FaceStatus.scanning ||
      status == FaceStatus.detecting ||
      status == FaceStatus.verifying;

  bool get isBusy => status == FaceStatus.verifying;

  FaceVerifyState copyWith({
    FaceStatus? status,
    FaceFailureKind? failureKind,
    String? fullName,
    String? failureMessage,
    bool clearFailureMessage = false,
  }) {
    return FaceVerifyState(
      status: status ?? this.status,
      failureKind: failureKind ?? this.failureKind,
      fullName: fullName ?? this.fullName,
      failureMessage: clearFailureMessage
          ? null
          : (failureMessage ?? this.failureMessage),
    );
  }

  @override
  List<Object?> get props => [status, failureKind, fullName, failureMessage];
}
