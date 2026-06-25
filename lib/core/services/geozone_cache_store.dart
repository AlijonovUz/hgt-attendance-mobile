import 'dart:convert';

import '../../features/attendance/data/models/geozone_model.dart';
import '../../features/attendance/domain/entities/geozone.dart';
import '../constants/storage_keys.dart';
import 'storage_service.dart';

/// Foydalanuvchi filialiga mos keshlangan geozonani saqlaydi/o‘qiydi
/// (`StorageKeys.cachedGeozone`, JSON). Offline geofence tekshiruvi shu yerdan
/// o‘qiydi; online holatda profil yuklangach yangilanadi.
class GeozoneCacheStore {
  GeozoneCacheStore(this._storage);

  final StorageService _storage;

  Future<void> write(Geozone zone) async {
    final json = jsonEncode(GeozoneModel.fromEntity(zone).toJson());
    await _storage.setString(StorageKeys.cachedGeozone, json);
  }

  /// Keshlangan zona (yo‘q/buzuq bo‘lsa `null`).
  Geozone? read() {
    final raw = _storage.getString(StorageKeys.cachedGeozone);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return GeozoneModel.fromJson(map).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => _storage.remove(StorageKeys.cachedGeozone);
}
