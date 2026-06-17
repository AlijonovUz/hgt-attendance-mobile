import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repository/profile_repository.dart';

/// Joriy foydalanuvchi profilini olish amali.
///
/// [GetProfileParams.accessToken] berilsa (token hali saqlanmagan onboarding
/// bosqichi) manual Bearer sifatida ishlatiladi; aks holda `AuthInterceptor`
/// saqlangan tokenni biriktiradi (home bosqichi).
class GetProfileUseCase implements UseCase<Profile, GetProfileParams> {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Profile> call(GetProfileParams params) =>
      _repository.getProfile(accessToken: params.accessToken);
}

class GetProfileParams extends Equatable {
  const GetProfileParams({this.accessToken});

  final String? accessToken;

  @override
  List<Object?> get props => [accessToken];
}
