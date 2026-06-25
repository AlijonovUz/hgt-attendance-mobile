import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/profile_cache_store.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repository/profile_repository.dart';
import '../data_sources/profile_remote_data_source.dart';

/// [ProfileRepository] implementatsiyasi — data source `Exception`larini
/// domen `Failure`lariga aylantiradi va profilni offline kesh bilan ta’minlaydi.
///
/// Cache-aside: online GET muvaffaqiyatida profil keshga yoziladi; internet
/// yo‘qligida ([NetworkException]) keshdagi profil qaytariladi (bo‘lsa).
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required ProfileCacheStore cache,
  })  : _remote = remote,
        _cache = cache;

  final ProfileRemoteDataSource _remote;
  final ProfileCacheStore _cache;

  @override
  Future<Profile> getProfile({String? accessToken}) async {
    try {
      final entity =
          (await _remote.getProfile(accessToken: accessToken)).toEntity();
      await _cache.write(entity);
      return entity;
    } on NetworkException catch (e) {
      final cached = _cache.read();
      if (cached != null) return cached; // offline — keshdan ko‘rsatamiz
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<Profile> updateFaceImage(String imagePath, {String? accessToken}) =>
      _guard(() async {
        final entity = (await _remote.updateFaceImage(
          imagePath,
          accessToken: accessToken,
        )).toEntity();
        await _cache.write(entity);
        return entity;
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
