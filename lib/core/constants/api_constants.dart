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

  /// GET — geozonalar ro‘yxati (filial geofence markazi + radiusi). Javob:
  /// `{ data: { results: [ { id, name, latitude, longitude, radius, branch } ] } }`.
  /// Online holatda olib, foydalanuvchi `branch`iga mosi lokalga keshlanadi
  /// (offline geofence tekshiruvi uchun).
  static const geozones = '/v1/attendance/geozones/';

  // ── Bildirishnomalar (api/v1/notifications) ───────────────────────────
  /// GET — sahifalangan ro‘yxat (`page`, `is_read` query). Javob:
  /// `{ count, next, previous, results: [ { id, title_*, message_*,
  /// extra_data, is_read, created_at } ] }`.
  static const notifications = '/v1/notifications/';

  /// GET — o‘qilmagan bildirishnomalar soni (bell badge uchun).
  static const notificationsCount = '/v1/notifications/count/';

  /// POST — barchasini o‘qilgan deb belgilash (tana yo‘q).
  static const notificationsReadAll = '/v1/notifications/read-all/';

  /// PATCH — bitta bildirishnomani o‘qilgan deb belgilash. `{id}` o‘rniga
  /// bildirishnoma UUID’i qo‘yiladi.
  static String notificationRead(String id) => '/v1/notifications/$id/read/';

  /// POST — FCM qurilma tokenini ro‘yxatdan o‘tkazish. Tana:
  /// `{ user (UUID), fcm_token, device_type (ios/android/web), device_id }`.
  /// `user` — JWT `user_id` claimi (profil `id`ga teng), backend majburiy.
  static const notificationsDeviceRegister =
      '/v1/notifications/devices/register/';

  /// POST — WebSocket ulanish uchun bir martalik ticket (60s). Javob:
  /// `{ ticket, expires_in }`. Bearer (AuthInterceptor) bilan.
  static const notificationsTicket = '/v1/notifications/tickets/';

  /// Real-time bildirishnoma WebSocket yo‘li (`/api` siz, host root’ida).
  /// To‘liq URL ticket bilan: `wss://<host>/ws/notifications/?ticket=...`.
  static const notificationsWsPath = '/ws/notifications/';
}
