part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

/// Xato turi — lokalizatsiya widget qatlamida mapping qilinadi.
enum LoginErrorKind { none, invalid, network, blocked, server }

class LoginState extends Equatable {
  const LoginState({
    this.fullName = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = LoginStatus.initial,
    this.errorKind = LoginErrorKind.none,
    this.errorText,
    this.blockedSeconds = 0,
    this.blockedTotalSeconds = 0,
    this.attemptsLeft = maxAttempts,
    this.accessToken,
    this.refreshToken,
    this.faceImage,
  });

  /// Blokgacha ruxsat etilgan urinishlar soni (mobil tomonda sanaladi).
  static const int maxAttempts = 5;

  final String fullName;
  final String password;
  final bool obscurePassword;
  final LoginStatus status;
  final LoginErrorKind errorKind;

  /// Backend’ning «friendly» xabari (mavjud bo‘lsa) — invalid/blocked/server uchun.
  final String? errorText;

  /// 429 blok holatida qolgan soniya (0 → bloklanmagan).
  final int blockedSeconds;

  /// Blokning to‘liq davomiyligi (soniya) — «N daqiqaga bloklandi» matni uchun.
  final int blockedTotalSeconds;

  /// Qolgan urinishlar (backend `attempts_left`). Boshlanishi — `maxAttempts`.
  final int attemptsLeft;

  final String? accessToken;
  final String? refreshToken;

  /// Qolgan urinishlar (5 → 0). «Yana N marta urinish mumkin» uchun.
  int get remainingAttempts => attemptsLeft.clamp(0, maxAttempts);

  /// Blok davomiyligi daqiqada (yuqoriga yaxlitlangan, kamida 1).
  int get blockedMinutes =>
      blockedTotalSeconds <= 0 ? 0 : ((blockedTotalSeconds + 59) ~/ 60);

  /// Login javobidagi `data.user.face_image` — `null` → yuzdan oldin rasm so‘raladi.
  final String? faceImage;

  bool get isLoading => status == LoginStatus.loading;
  bool get isBlocked =>
      errorKind == LoginErrorKind.blocked && blockedSeconds > 0;
  bool get hasError =>
      status == LoginStatus.failure && errorKind != LoginErrorKind.none;

  bool get canSubmit =>
      fullName.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      status != LoginStatus.loading &&
      !isBlocked;

  /// MM:SS ko‘rinishidagi qolgan blok vaqti.
  String get blockedClock {
    final m = (blockedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (blockedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  LoginState copyWith({
    String? fullName,
    String? password,
    bool? obscurePassword,
    LoginStatus? status,
    LoginErrorKind? errorKind,
    String? errorText,
    bool clearError = false,
    int? blockedSeconds,
    int? blockedTotalSeconds,
    int? attemptsLeft,
    String? accessToken,
    String? refreshToken,
    String? faceImage,
  }) {
    return LoginState(
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorKind: errorKind ?? this.errorKind,
      errorText: clearError ? null : (errorText ?? this.errorText),
      blockedSeconds: blockedSeconds ?? this.blockedSeconds,
      blockedTotalSeconds: blockedTotalSeconds ?? this.blockedTotalSeconds,
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      faceImage: faceImage ?? this.faceImage,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        password,
        obscurePassword,
        status,
        errorKind,
        errorText,
        blockedSeconds,
        blockedTotalSeconds,
        attemptsLeft,
        accessToken,
        refreshToken,
        faceImage,
      ];
}
