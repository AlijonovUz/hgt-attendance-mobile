import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/geozone.dart';
import '../../domain/repository/geozone_repository.dart';
import '../data_sources/attendance_local_data_source.dart';
import '../data_sources/geozone_remote_data_source.dart';

class GeozoneRepositoryImpl implements GeozoneRepository {
  const GeozoneRepositoryImpl({
    required GeozoneRemoteDataSource remote,
    required AttendanceLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final GeozoneRemoteDataSource _remote;
  final AttendanceLocalDataSource _local;

  @override
  Future<void> refreshForBranch(String branchId) async {
    try {
      final all = await _remote.getGeozones();
      final match = all.where((g) => g.branchId == branchId);
      if (match.isEmpty) return; // mos filial yo‘q — cache o‘zgarmaydi.
      await _local.cacheGeozone(match.first);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Geozone? cachedGeozone() => _local.cachedGeozone();
}
