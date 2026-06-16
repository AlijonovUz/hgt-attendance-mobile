/// Onboarding bosqichlari uchun domen interfeysi.
abstract interface class OnboardingRepository {
  /// Yangi parol o‘rnatadi. [accessToken] berilsa (token hali saqlanmagan
  /// onboarding bosqichi) manual Bearer sifatida ishlatiladi.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
    String? accessToken,
  });
}
