import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Foydalanuvchining dinamik `offline_secret` kalitini xavfsiz saqlaydi.
///
/// Kalit **login** javobida (`user.offline_secret`) va **parol o‘zgartirilganda**
/// keladi. Offline davomat vaqtini imzolash (HMAC-SHA256) uchun ishlatiladi —
/// [signCreatedAt]. Token kabi maxfiy, shuning uchun `SharedPreferences` emas,
/// `flutter_secure_storage`da saqlanadi (logout/expired’da tozalanadi).
class OfflineSecretService {
  OfflineSecretService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _key = 'offline_secret';

  Future<void> save(String secret) =>
      _storage.write(key: _key, value: secret);

  Future<String?> read() => _storage.read(key: _key);

  Future<void> clear() => _storage.delete(key: _key);
}
