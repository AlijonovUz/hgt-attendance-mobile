abstract final class StorageKeys {
  static const authToken = 'auth_token';
  static const refreshToken = 'refresh_token';
  static const cachedUser = 'cached_user';
  static const languageCode = 'language_code';
  static const onboardingCompleted = 'onboarding_completed';
  static const pendingAuthRoute = 'pending_auth_route';

  static const all = <String>{
    authToken,
    refreshToken,
    cachedUser,
    languageCode,
    onboardingCompleted,
    pendingAuthRoute,
  };
}
