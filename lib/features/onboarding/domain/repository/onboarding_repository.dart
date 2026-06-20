/// Onboarding bosqichlari uchun domen interfeysi.
abstract interface class OnboardingRepository {
  /// Yangi parol o‘rnatadi. [accessToken] berilsa (token hali saqlanmagan
  /// onboarding bosqichi) manual Bearer sifatida ishlatiladi. Yangi
  /// `offline_secret` qaytsa qaytaradi (aks holda `null`).
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
    String? accessToken,
  });
}
