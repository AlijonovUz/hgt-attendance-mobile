part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Login (full_name) maydoni o‘zgardi.
class LoginFullNameChanged extends LoginEvent {
  const LoginFullNameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Parol maydoni o‘zgardi.
class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Parolni ko‘rsatish/yashirish.
class LoginObscureToggled extends LoginEvent {
  const LoginObscureToggled();
}

/// "Kirish" tugmasi bosildi.
class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

/// Blok sanagichi tiki (ichki — har soniyada).
class LoginBlockTicked extends LoginEvent {
  const LoginBlockTicked();
}
