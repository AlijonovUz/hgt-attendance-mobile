part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Profilni yuklash / qayta yuklash.
class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

/// Qurilmadan rasm tanlash so‘rovi (galereya yoki kamera).
class ProfilePhotoPickRequested extends ProfileEvent {
  const ProfilePhotoPickRequested(this.source);

  final ImageSourceKind source;

  @override
  List<Object?> get props => [source];
}

/// Yuklash uchun manual access token (yuzdan oldingi bosqich — token hali
/// saqlanmagan). Berilmasa `AuthInterceptor` saqlangan tokenni biriktiradi.
class ProfileUploadAuthProvided extends ProfileEvent {
  const ProfileUploadAuthProvided(this.accessToken);

  final String accessToken;

  @override
  List<Object?> get props => [accessToken];
}

/// Tanlangan (yuklanmagan) rasmni bekor qilish.
class ProfilePhotoCleared extends ProfileEvent {
  const ProfilePhotoCleared();
}

/// Tanlangan rasmni serverga (`face_image`) yuklash.
class ProfilePhotoSubmitted extends ProfileEvent {
  const ProfilePhotoSubmitted();
}
