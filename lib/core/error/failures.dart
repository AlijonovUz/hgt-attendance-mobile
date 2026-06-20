import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server failure']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Mijoz so‘rovi yaroqsiz (HTTP 400). Offline sinxronda → yozuv navbatdan
/// o‘chiriladi (retry foydasiz).
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized', this.attemptsLeft]);

  /// Qolgan urinishlar soni (backend `attempts_left`).
  final int? attemptsLeft;

  @override
  List<Object?> get props => [message, attemptsLeft];
}

class ThrottleFailure extends Failure {
  const ThrottleFailure([
    super.message = 'Too many requests',
    this.retryAfterSeconds,
    this.attemptsLeft,
  ]);

  /// Blok tugashigacha qolgan soniya (backend `retry_after_seconds`).
  final int? retryAfterSeconds;

  /// Qolgan urinishlar (odatda 0).
  final int? attemptsLeft;

  @override
  List<Object?> get props => [message, retryAfterSeconds, attemptsLeft];
}
