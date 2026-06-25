import 'package:equatable/equatable.dart';

/// Kirish (access) va yangilash (refresh) tokenlari + login javobidagi profil
/// holati (onboarding oqimini boshqarish uchun).
///
/// [faceImage] login javobidagi `data.user.face_image` — `null`/bo‘sh bo‘lsa
/// onboardingda rasm yuklash bosqichi ko‘rsatiladi.
/// [isPasswordChanged] `data.user.is_password_changed` — `false` bo‘lsa
/// onboardingda yangi parol o‘rnatish bosqichi ko‘rsatiladi.
/// [fullName] `data.user.full_name` — onboarding kartasida ko‘rsatiladi.
class AuthTokens extends Equatable {
  const AuthTokens({
    required this.access,
    required this.refresh,
    this.faceImage,
    this.fullName,
    this.isPasswordChanged = true,
    this.offlineSecret,
  });

  final String access;
  final String refresh;
  final String? faceImage;
  final String? fullName;
  final bool isPasswordChanged;

  /// `data.user.offline_secret` — offline davomat vaqtini HMAC bilan imzolash
  /// kaliti. `null`/bo‘sh bo‘lsa offline rejim ishlamaydi (faqat online).
  final String? offlineSecret;

  @override
  List<Object?> get props =>
      [access, refresh, faceImage, fullName, isPasswordChanged, offlineSecret];
}
