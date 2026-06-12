import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

/// Yuzni tasdiqlash amali — selfie + (saqlanmagan) access token bilan.
class VerifyFaceUseCase implements UseCase<void, VerifyFaceParams> {
  const VerifyFaceUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(VerifyFaceParams params) {
    return _repository.verifyFace(
      imagePath: params.imagePath,
      accessToken: params.accessToken,
    );
  }
}

class VerifyFaceParams extends Equatable {
  const VerifyFaceParams({required this.imagePath, required this.accessToken});

  final String imagePath;
  final String accessToken;

  @override
  List<Object?> get props => [imagePath, accessToken];
}
