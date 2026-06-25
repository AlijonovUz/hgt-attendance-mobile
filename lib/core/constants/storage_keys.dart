abstract final class StorageKeys {
  static const authToken = 'auth_token';
  static const refreshToken = 'refresh_token';
  static const cachedUser = 'cached_user';
  static const languageCode = 'language_code';
  static const onboardingCompleted = 'onboarding_completed';
  static const pendingAuthRoute = 'pending_auth_route';
  static const sessionExpiresAt = 'session_expires_at';
  static const attendanceDate = 'attendance_date';

  /// Boshlang‘ich loginda kiritilgan login identifikatori — PIN oqimida
  /// keshlangan username sifatida ishlatiladi.
  static const loginUsername = 'login_username';

  /// Tanlangan aktiv rol.
  static const activeRole = 'active_role';

  /// Boshlang‘ich loginda kiritilgan parol uzunligi — PIN ko‘rsatkichi
  /// shu uzunlikni dinamik o‘qiydi (qattiq kodlanmaydi).
  static const pinLength = 'pin_length';

  /// Ilova oxirgi marta faol bo‘lgan (fonga o‘tgan) vaqt — PIN qulfining
  /// 3 daqiqalik fon timeout’ini hisoblash uchun.
  static const lastActiveAt = 'last_active_at';

  /// Tanlangan tema rejimi (`system` / `light` / `dark`) — login’dagi
  /// Yorug‘/Qorong‘i toggle’i shu yerga yozadi va bootstrap’da o‘qiladi.
  static const themeMode = 'theme_mode';

  /// Barqaror qurilma identifikatori (FCM `device_id`) — bir marta yaratiladi
  /// va saqlanadi, har bir token ro‘yxatida shu ishlatiladi.
  static const deviceId = 'device_id';

  /// Foydalanuvchi filialiga mos keshlangan geozona (JSON) — offline geofence
  /// tekshiruvi shu yerdan o‘qiydi. Online holatda profil yuklangach yangilanadi.
  static const cachedGeozone = 'cached_geozone';

  static const all = <String>{
    authToken,
    refreshToken,
    cachedUser,
    languageCode,
    onboardingCompleted,
    pendingAuthRoute,
    sessionExpiresAt,
    attendanceDate,
    loginUsername,
    activeRole,
    pinLength,
    lastActiveAt,
    themeMode,
    deviceId,
    cachedGeozone,
  };
}
