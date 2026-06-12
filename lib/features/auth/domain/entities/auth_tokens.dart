import 'package:equatable/equatable.dart';

/// Kirish (access) va yangilash (refresh) tokenlari + profil rasm holati.
///
/// [faceImage] login javobidagi `data.user.face_image` — `null` bo‘lsa yuz
/// tasdig‘idan oldin foydalanuvchidan profil rasmi so‘raladi.
class AuthTokens extends Equatable {
  const AuthTokens({
    required this.access,
    required this.refresh,
    this.faceImage,
  });

  final String access;
  final String refresh;
  final String? faceImage;

  @override
  List<Object?> get props => [access, refresh, faceImage];
}
