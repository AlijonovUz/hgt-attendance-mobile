part of 'session_bloc.dart';

/// Navigatsiya guardini boshqaruvchi yuqori-darajali auth holati.
///
/// [unknown] — storage o‘qilgunga qadar bootstrap fazasi (splash).
/// [unauthenticated] — token yo‘q → login.
/// [faceVerificationRequired] — login muvaffaqiyatli, ammo tokenlar HALI
/// saqlanmagan (RAM’da); yuz tasdiqlanishi shart → face ekrani.
/// [authenticated] — yuz tasdiqlandi, tokenlar saqlandi → home.
enum SessionStatus {
  unknown,
  unauthenticated,
  faceVerificationRequired,
  authenticated,
}

class SessionState extends Equatable {
  const SessionState(this.status);

  const SessionState.unknown() : this(SessionStatus.unknown);
  const SessionState.unauthenticated() : this(SessionStatus.unauthenticated);
  const SessionState.faceVerificationRequired()
      : this(SessionStatus.faceVerificationRequired);
  const SessionState.authenticated() : this(SessionStatus.authenticated);

  final SessionStatus status;

  bool get isAuthenticated => status == SessionStatus.authenticated;
  bool get isUnauthenticated => status == SessionStatus.unauthenticated;
  bool get isFaceVerificationRequired =>
      status == SessionStatus.faceVerificationRequired;
  bool get isResolved => status != SessionStatus.unknown;

  @override
  List<Object?> get props => [status];
}
