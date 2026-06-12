abstract final class ApiConstants {
  static const baseUrl = 'https://hkk-backend.raqamlinazorat.uz/api';

  // ── Auth (api/v1/users/auth) ──────────────────────────────────────────
  static const login = '/v1/users/auth/login/';
  static const refresh = '/v1/users/auth/refresh/';

  /// Login’dan keyin majburiy yuz tasdiqlash — `image` faylini FormData bilan
  /// yuboradi, Bearer (hali saqlanmagan, RAM’dagi) access token bilan.
  static const verifyFace = '/v1/users/auth/verify-face/';

  /// Joriy foydalanuvchi profili (F.I.Sh, rasm, rol, ...).
  static const profile = '/v1/users/auth/profile/';
}
