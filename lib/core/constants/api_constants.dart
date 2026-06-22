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

  /// Onboardingda yangi parol o‘rnatish — `old_password` / `new_password` /
  /// `confirm_new_password` bilan POST yuboriladi (RAM token + `skipRefresh`).
  static const setPassword = '/v1/users/auth/change-password/';

  // ── Attendance (api/v1/attendance) ────────────────────────────────────
  /// Davomat belgilash — `event_type` (check_in/lunch_start/lunch_end/
  /// check_out) + `gps_latitude`/`gps_longitude` + `image` selfie FormData.
  /// Saqlangan token bilan (AuthInterceptor), 401 da refresh ishlaydi.
  static const attendance = '/v1/attendance/attendance/';

  /// Shaxsiy davomat statistikasi (sana oralig‘i bo‘yicha) — `start_date` /
  /// `end_date` (`yyyy-MM-dd`). Javob: `present_days`, `late_days`,
  /// `avg_check_in`, `total_worked_hours`.
  static const attendancePersonalStats =
      '/v1/attendance/attendance/personal-stats/';
}
