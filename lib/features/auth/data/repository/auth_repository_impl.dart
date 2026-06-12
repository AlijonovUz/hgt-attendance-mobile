import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/token_service.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

/// [AuthRepository] implementatsiyasi.
///
/// Data source `Exception`larini domen `Failure`lariga aylantiradi. Tokenlar
/// bu yerda SAQLANMAYDI — login natijasi RAM’da (`SessionBloc`) turadi va yuz
/// tasdiqlangach saqlanadi.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenService tokenService,
  })  : _remote = remote,
        _tokenService = tokenService;

  final AuthRemoteDataSource _remote;
  final TokenService _tokenService;

  @override
  Future<AuthTokens> login({
    required String fullName,
    required String password,
  }) async {
    try {
      final model = await _remote.login(fullName: fullName, password: password);
      return model.toEntity();
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

  @override
  Future<void> verifyFace({
    required String imagePath,
    required String accessToken,
  }) async {
    try {
      await _remote.verifyFace(imagePath: imagePath, accessToken: accessToken);
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

  @override
  Future<void> logout() async {
    await _tokenService.clearAll();
  }
}
