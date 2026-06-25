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
/// rejimida (joylashuv aniqlanmasa) uchraydi; [locationServiceOff] — GPS
/// xizmati o‘chiq (UI yoqish dialogini ko‘rsatadi). Offline davomat
/// bloklovchilari: [outsideGeofence] (ish joyidan tashqarida), [faceMismatch]
/// (yuz mos kelmadi), [offlineNoGeozone] (geozona keshlanmagan),
/// [offlineNoSecret] (offline kalit yo‘q).
enum FaceFailureKind {
  none,
  noFace,
  verifyFailed,
  network,
  location,
  locationServiceOff,
  outsideGeofence,
  faceMismatch,
  offlineNoGeozone,
  offlineNoSecret,
}

class FaceVerifyState extends Equatable {
  const FaceVerifyState({
    this.status = FaceStatus.initializing,
    this.failureKind = FaceFailureKind.none,
    this.fullName = '',
    this.failureMessage,
    this.offlineQueued = false,
  });

  final FaceStatus status;
  final FaceFailureKind failureKind;

  /// Karta sarlavhasi uchun login’da kiritilgan ism.
  final String fullName;

  /// Backend `errorMsg`i (mavjud bo‘lsa) — to‘g‘ridan-to‘g‘ri ko‘rsatiladi.
  final String? failureMessage;

  /// Muvaffaqiyat offline navbatga saqlash orqali bo‘ldimi — UI «internet yo‘q,
  /// ulanishda yuboriladi» xabarini ko‘rsatadi.
  final bool offlineQueued;

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
    bool? offlineQueued,
  }) {
    return FaceVerifyState(
      status: status ?? this.status,
      failureKind: failureKind ?? this.failureKind,
      fullName: fullName ?? this.fullName,
      failureMessage: clearFailureMessage
          ? null
          : (failureMessage ?? this.failureMessage),
      offlineQueued: offlineQueued ?? this.offlineQueued,
    );
  }

  @override
  List<Object?> get props =>
      [status, failureKind, fullName, failureMessage, offlineQueued];
}
