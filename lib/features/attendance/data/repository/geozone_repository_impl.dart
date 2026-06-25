import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/geozone.dart';
import '../../domain/repository/geozone_repository.dart';
import '../data_sources/geozone_remote_data_source.dart';

class GeozoneRepositoryImpl implements GeozoneRepository {
  const GeozoneRepositoryImpl({required GeozoneRemoteDataSource remote})
      : _remote = remote;

  final GeozoneRemoteDataSource _remote;

  @override
  Future<List<Geozone>> fetchAll() async {
    try {
      final models = await _remote.list();
      return models.map((m) => m.toEntity()).toList();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
