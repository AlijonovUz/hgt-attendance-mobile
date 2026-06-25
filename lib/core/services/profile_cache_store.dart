import 'dart:convert';

import '../../features/profile/data/models/profile_model.dart';
import '../../features/profile/domain/entities/profile.dart';
import '../constants/storage_keys.dart';
import 'storage_service.dart';

/// Profilni offline ko‘rsatish uchun keshlaydi (`StorageKeys.cachedProfile`,
/// JSON). Online profil GET muvaffaqiyatida yoziladi; internet yo‘qligida
/// repository shu yerdan o‘qiydi.
///
/// [GeozoneCacheStore] bilan bir xil naqsh: model orqali JSON round-trip.
/// E’tibor: yuz rasmi alohida [FaceImageCacheService] (fayl) bilan keshlanadi —
/// bu yerda faqat matn maydonlari (ism, jadval, KPI, filial) saqlanadi.
class ProfileCacheStore {
  ProfileCacheStore(this._storage);

  final StorageService _storage;

  Future<void> write(Profile profile) async {
    final json = jsonEncode(ProfileModel.fromEntity(profile).toJson());
    await _storage.setString(StorageKeys.cachedProfile, json);
  }

  /// Keshlangan profil (yo‘q/buzuq bo‘lsa `null`).
  Profile? read() {
    final raw = _storage.getString(StorageKeys.cachedProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ProfileModel.fromJson(map).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => _storage.remove(StorageKeys.cachedProfile);
}
