part of 'change_password_bloc.dart';

/// Yuborishdagi xato turi — lokalizatsiya widget qatlamida.
enum ChangePasswordErrorKind { none, network, server }

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.oldPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.submitting = false,
    this.success = false,
    this.error = ChangePasswordErrorKind.none,
  });

  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  final bool submitting;
  final bool success;
  final ChangePasswordErrorKind error;

  /// Yangi parolda qondirilgan shartlar (jonli ko‘rsatkich).
  Set<PasswordRule> get satisfiedRules => PasswordRule.values
      .where((rule) => rule.isSatisfiedBy(newPassword))
      .toSet();

  /// Yangi parol barcha shartlarni qondiradimi.
  bool get isNewPasswordStrong =>
      PasswordRule.values.every((rule) => rule.isSatisfiedBy(newPassword));

  /// Tasdiqlash maydoni bo‘sh emas va yangisi bilan teng.
  bool get passwordsMatch =>
      confirmPassword.isNotEmpty && newPassword == confirmPassword;

  /// Yuborish mumkinmi: eski kiritilgan, yangisi kuchli, tasdiq mos.
  bool get canSubmit =>
      oldPassword.isNotEmpty &&
      isNewPasswordStrong &&
      passwordsMatch &&
      !submitting;

  ChangePasswordState copyWith({
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
    bool? submitting,
    bool? success,
    ChangePasswordErrorKind? error,
  }) {
    return ChangePasswordState(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    oldPassword,
    newPassword,
    confirmPassword,
    submitting,
    success,
    error,
  ];
}
