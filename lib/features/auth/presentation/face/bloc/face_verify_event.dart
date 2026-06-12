part of 'face_verify_bloc.dart';

sealed class FaceVerifyEvent extends Equatable {
  const FaceVerifyEvent();

  @override
  List<Object?> get props => [];
}

/// Ekran ochildi — ruxsat, kamera va detektor ishga tushadi. Tokenni RAM’dan
/// olib keladi (`SessionBloc.pendingAccessToken`).
class FaceStarted extends FaceVerifyEvent {
  const FaceStarted({required this.accessToken, required this.fullName});

  final String accessToken;
  final String fullName;

  @override
  List<Object?> get props => [accessToken, fullName];
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
