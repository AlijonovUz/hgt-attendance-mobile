part of 'change_password_bloc.dart';

sealed class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

/// Eski parol maydoni o‘zgardi (`old_password`).
class ChangePasswordOldChanged extends ChangePasswordEvent {
  const ChangePasswordOldChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Yangi parol maydoni o‘zgardi (`new_password`).
class ChangePasswordNewChanged extends ChangePasswordEvent {
  const ChangePasswordNewChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Yangi parolni takrorlash maydoni o‘zgardi (`confirm_new_password`).
class ChangePasswordConfirmChanged extends ChangePasswordEvent {
  const ChangePasswordConfirmChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Shartlar to‘liq → serverga yuborish.
class ChangePasswordSubmitted extends ChangePasswordEvent {
  const ChangePasswordSubmitted();
}
