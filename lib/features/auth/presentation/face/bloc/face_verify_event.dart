part of 'face_verify_bloc.dart';

sealed class FaceVerifyEvent extends Equatable {
  const FaceVerifyEvent();

  @override
  List<Object?> get props => [];
}

/// Ekran ochildi — ruxsat, (davomatda) GPS, kamera va detektor ishga tushadi.
/// Rejim [FaceFlowMode] orqali beriladi: login (verify-face, RAM token) yoki
/// davomat (attendance, GPS + event_type).
class FaceStarted extends FaceVerifyEvent {
  const FaceStarted(this.mode);

  final FaceFlowMode mode;

  @override
  List<Object?> get props => [mode];
}

/// Stream kadrida yuz aniqlanish natijasi (ichki).
class FaceDetectionUpdated extends FaceVerifyEvent {
  const FaceDetectionUpdated({required this.facePresent});

  final bool facePresent;

  @override
  List<Object?> get props => [facePresent];
}

/// Yuz barqaror aniqlandi — selfie olinadi va yuboriladi (ichki).
class FaceCaptureRequested extends FaceVerifyEvent {
  const FaceCaptureRequested();
}

/// Foydalanuvchi «Qayta urinish» bosdi.
class FaceRetryRequested extends FaceVerifyEvent {
  const FaceRetryRequested();
}

/// GPS o‘chiq dialogidan «Yoqish» bosildi — qurilma joylashuv sozlamasi ochiladi.
class FaceLocationSettingsRequested extends FaceVerifyEvent {
  const FaceLocationSettingsRequested();
}
