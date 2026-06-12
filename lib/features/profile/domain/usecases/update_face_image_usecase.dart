import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repository/profile_repository.dart';

/// Profil rasmini (`face_image`) yangilash amali — qurilmadan tanlangan fayl.
///
/// [UpdateFaceImageParams.accessToken] berilsa (yuz tasdig‘idan oldingi bosqich,
/// token hali saqlanmagan), manual Bearer sifatida ishlatiladi; aks holda
/// `AuthInterceptor` saqlangan tokenni biriktiradi (home bosqichi).
class UpdateFaceImageUseCase
    implements UseCase<Profile, UpdateFaceImageParams> {
  const UpdateFaceImageUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Profile> call(UpdateFaceImageParams params) =>
      _repository.updateFaceImage(
        params.imagePath,
        accessToken: params.accessToken,
      );
}

class UpdateFaceImageParams extends Equatable {
  const UpdateFaceImageParams({required this.imagePath, this.accessToken});

  final String imagePath;
  final String? accessToken;

  @override
  List<Object?> get props => [imagePath, accessToken];
}
