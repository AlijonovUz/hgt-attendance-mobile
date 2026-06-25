import '../../../../core/services/geozone_cache_store.dart';
import '../entities/geozone.dart';
import '../repository/geozone_repository.dart';

/// Geozonalarni online oladi, foydalanuvchi `branchId`siga mosini topib lokal
/// keshga yozadi (offline geofence uchun). Mos zona topilmasa kesh
/// o‘zgartirilmaydi (eski kesh saqlanadi). Muvaffaqiyatda mos zona qaytadi.
///
/// `Failure` (tarmoq/server) yuqoriga `throw` qilinadi — chaqiruvchi (online
/// sync trigger) ushlab, offline keshga tayanadi.
class SyncUserGeozoneUseCase {
  const SyncUserGeozoneUseCase(this._repository, this._cache);

  final GeozoneRepository _repository;
  final GeozoneCacheStore _cache;

  Future<Geozone?> call(String branchId) async {
    if (branchId.isEmpty) return _cache.read();
    final zones = await _repository.fetchAll();
    Geozone? match;
    for (final z in zones) {
      if (z.branch == branchId) {
        match = z;
        break;
      }
    }
    if (match != null) {
      await _cache.write(match);
    }
    return match ?? _cache.read();
  }
}
