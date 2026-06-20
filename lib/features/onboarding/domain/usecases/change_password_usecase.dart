import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/onboarding_repository.dart';

/// Onboardingda yangi parol o‘rnatish amali.
///
/// [ChangePasswordParams.accessToken] berilsa (token hali saqlanmagan bosqich),
/// manual Bearer sifatida ishlatiladi.
class ChangePasswordUseCase implements UseCase<String?, ChangePasswordParams> {
  const ChangePasswordUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<String?> call(ChangePasswordParams params) =>
      _repository.changePassword(
    oldPassword: params.oldPassword,
    newPassword: params.newPassword,
    confirmNewPassword: params.confirmNewPassword,
    accessToken: params.accessToken,
  );
}

class ChangePasswordParams extends Equatable {
  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmNewPassword,
    this.accessToken,
  });

  final String oldPassword;
  final String newPassword;
  final String confirmNewPassword;
  final String? accessToken;

  @override
  List<Object?> get props => [
    oldPassword,
    newPassword,
    confirmNewPassword,
    accessToken,
  ];
}
