import 'dart:convert';

import '../constants/storage_keys.dart';
import 'storage_service.dart';

class TokenService {
  TokenService(this._storageService);

  final StorageService _storageService;

  /// Saqlangan access tokendan `user_id` (UUID) claimni ajratadi.
  ///
  /// JWT payload’i (ikkinchi segment) base64url-dekod qilinadi. Token yo‘q
  /// yoki noto‘g‘ri bo‘lsa `null`. Bu qiymat profil `id`ga teng — qurilma
  /// ro‘yxatida (`user`) ishlatiladi.
  String? getUserId() {
    final token = getToken();
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      payload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
      final decoded = utf8.decode(base64.decode(payload));
      final map = jsonDecode(decoded);
      if (map is Map && map['user_id'] != null) {
        return map['user_id'].toString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> saveToken(String token) {
    return _storageService.setString(StorageKeys.authToken, token);
  }

  String? getToken() {
    return _storageService.getString(StorageKeys.authToken);
  }

  Future<void> clearToken() {
    return _storageService.remove(StorageKeys.authToken);
  }

  // ── Refresh token ───────────────────────────────────────────────────
  Future<void> saveRefreshToken(String token) {
    return _storageService.setString(StorageKeys.refreshToken, token);
  }

  String? getRefreshToken() {
    return _storageService.getString(StorageKeys.refreshToken);
  }

  Future<void> clearRefreshToken() {
    return _storageService.remove(StorageKeys.refreshToken);
  }

  /// Barcha token ma'lumotlarini tozalash (chiqish / sessiya tugashi).
  Future<void> clearAll() async {
    await clearToken();
    await clearRefreshToken();
  }
}
