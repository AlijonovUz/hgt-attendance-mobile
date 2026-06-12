import '../entities/auth_tokens.dart';

/// Auth domeni shartnomasi. Implementatsiya data qatlamida.
///
/// Xatolarda `Failure` (core/error/failures.dart) `throw` qiladi. Tokenlarni
/// repo SAQLAMAYDI — saqlash yuz tasdig‘idan keyin `SessionBloc`da bo‘ladi.
abstract interface class AuthRepository {
  /// `full_name` + `password` bilan kirish → token juftligi (saqlanmaydi).
  Future<AuthTokens> login({
    required String fullName,
    required String password,
  });

  /// Selfie bilan yuzni tasdiqlash. Muvaffaqiyatda hech narsa qaytmaydi;
  /// xatoda `Failure` tashlanadi.
  Future<void> verifyFace({
    required String imagePath,
    required String accessToken,
  });

  /// Joriy sessiyani tugatish — lokal tokenlarni tozalash.
  Future<void> logout();
}
