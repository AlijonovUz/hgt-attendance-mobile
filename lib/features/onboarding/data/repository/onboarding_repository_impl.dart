import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repository/onboarding_repository.dart';
import '../data_sources/onboarding_remote_data_source.dart';

/// [OnboardingRepository] implementatsiyasi — data source `Exception`larini
/// domen `Failure`lariga aylantiradi.
class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl({required OnboardingRemoteDataSource remote})
      : _remote = remote;

  final OnboardingRemoteDataSource _remote;

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
    String? accessToken,
  }) async {
    try {
      await _remote.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
        accessToken: accessToken,
      );
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
