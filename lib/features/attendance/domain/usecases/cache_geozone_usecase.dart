import '../repository/geozone_repository.dart';

/// Filialga mos geozone’ni serverdan olib lokalga cache qiladi (online, app
/// kirib profil yuklangach). Offline geofence shu cache’dan foydalanadi.
class CacheGeozoneForBranchUseCase {
  const CacheGeozoneForBranchUseCase(this._repository);

  final GeozoneRepository _repository;

  Future<void> call(String branchId) =>
      _repository.refreshForBranch(branchId);
}
