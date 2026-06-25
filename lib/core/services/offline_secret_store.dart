import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// `offline_secret` (HMAC imzo kaliti) uchun xavfsiz saqlash.
///
/// Manba: `mobile_offline_docs.md` — har foydalanuvchining dinamik
/// `offline_secret`i login javobida (`user.offline_secret`) va ChangePassword
/// 200 javobida keladi; offline davomat vaqtini imzolash (HMAC-SHA256) uchun
/// ishlatiladi. `flutter_secure_storage` (Keychain/Keystore) — token’lardan
/// farqli, bu kalit shifrlangan xotirada saqlanadi.
class OfflineSecretStore {
  OfflineSecretStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _key = 'offline_secret';

  Future<void> write(String secret) =>
      _storage.write(key: _key, value: secret);

  Future<String?> read() => _storage.read(key: _key);

  Future<void> clear() => _storage.delete(key: _key);
}
