part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

/// Ilova ishga tushganda saqlangan sessiyani aniqlash (bootstrap).
class SessionStarted extends SessionEvent {
  const SessionStarted();
}

/// Login API muvaffaqiyatli tugadi. Tokenlar HALI saqlanmaydi — yuz tasdiqigacha
/// RAM’da turadi (yuz so‘rovi shu access token bilan Bearer qiladi).
class SessionLoginSucceeded extends SessionEvent {
  const SessionLoginSucceeded({
    required this.accessToken,
    required this.refreshToken,
    required this.fullName,
    this.loginPassword = '',
    this.faceImage,
    this.isPasswordChanged = true,
    this.offlineSecret,
  });

  final String accessToken;
  final String refreshToken;

  /// Login javobidagi `offline_secret` — yuz tasdiqlanganda secure storage’ga
  /// saqlanadi (offline davomat imzosi uchun).
  final String? offlineSecret;

  /// Login’da kiritilgan ism — face ekranidagi karta uchun (profil kelguncha).
  final String fullName;

  /// Login’da kiritilgan parol — onboarding parol bosqichidagi «eski parol».
  final String loginPassword;

  /// Login javobidagi profil rasmi (`data.user.face_image`) — `null` bo‘lsa
  /// yuz tasdig‘idan oldin rasm so‘rovi ko‘rsatiladi.
  final String? faceImage;

  /// Login javobidagi `is_password_changed` — `false` bo‘lsa onboardingda
  /// yangi parol o‘rnatish bosqichi ko‘rsatiladi.
  final bool isPasswordChanged;

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        fullName,
        loginPassword,
        faceImage,
        isPasswordChanged,
        offlineSecret,
      ];
}

/// Yuz muvaffaqiyatli tasdiqlandi → RAM’dagi tokenlar diskka saqlanadi.
class SessionFaceVerified extends SessionEvent {
  const SessionFaceVerified();
}

/// Sessiya majburan tugadi (401 interceptor, refresh muvaffaqiyatsiz) → login.
class SessionExpired extends SessionEvent {
  const SessionExpired();
}

/// Foydalanuvchi o‘zi chiqdi — hamma narsa tozalanadi.
class SessionLogoutRequested extends SessionEvent {
  const SessionLogoutRequested();
}
