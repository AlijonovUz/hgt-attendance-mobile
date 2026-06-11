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
}
