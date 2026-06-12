import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repository/profile_repository.dart';

/// Joriy foydalanuvchi profilini olish amali.
class GetProfileUseCase implements UseCase<Profile, NoParams> {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Profile> call(NoParams params) => _repository.getProfile();
}
