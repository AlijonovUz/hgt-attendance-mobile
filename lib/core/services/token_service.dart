import '../constants/storage_keys.dart';
import 'storage_service.dart';

class TokenService {
  TokenService(this._storageService);

  final StorageService _storageService;

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
