import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repository/profile_repository.dart';
import '../data_sources/profile_remote_data_source.dart';

/// [ProfileRepository] implementatsiyasi — data source `Exception`larini
/// domen `Failure`lariga aylantiradi.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required ProfileRemoteDataSource remote})
      : _remote = remote;

  final ProfileRemoteDataSource _remote;

  @override
  Future<Profile> getProfile() => _guard(() async {
        final model = await _remote.getProfile();
        return model.toEntity();
      });

  @override
  Future<Profile> updateFaceImage(String imagePath, {String? accessToken}) =>
      _guard(() async {
        final model = await _remote.updateFaceImage(
          imagePath,
          accessToken: accessToken,
        );
        return model.toEntity();
      });

  Future<Profile> _guard(Future<Profile> Function() body) async {
    try {
      return await body();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
