import '../entities/geozone.dart';

/// Ish hududi (geozone) — online yangilash + lokal cache.
abstract interface class GeozoneRepository {
  /// Geozonalarni serverdan olib, [branchId]ga mosini lokalga saqlaydi.
  /// Mos topilmasa cache o‘zgarmaydi. Xatoda `Failure` otadi.
  Future<void> refreshForBranch(String branchId);

  /// Lokalga cache qilingan geozone (yo‘q bo‘lsa `null`).
  Geozone? cachedGeozone();
}
