import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/auth_tokens.dart';
import '../repository/auth_repository.dart';

/// Login amal — bitta vazifa: `full_name` + `password` bilan token olish.
class LoginUseCase implements UseCase<AuthTokens, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthTokens> call(LoginParams params) {
    return _repository.login(
      fullName: params.fullName,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.fullName, required this.password});

  final String fullName;
  final String password;

  @override
  List<Object?> get props => [fullName, password];
}
