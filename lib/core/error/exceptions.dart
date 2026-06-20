class ServerException implements Exception {
  const ServerException([this.message = 'Server exception']);

  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache exception']);

  final String message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Unauthorized', this.attemptsLeft]);

  final String message;

  /// Backend `error.details.attempts_left` — qolgan urinishlar (mavjud bo‘lsa).
  final int? attemptsLeft;
}

/// So‘rovlar soni cheklangan (HTTP 429).
class ThrottleException implements Exception {
  const ThrottleException([
    this.message = 'Too many requests',
    this.retryAfterSeconds,
    this.attemptsLeft,
  ]);

  final String message;

  /// Backend `error.details.retry_after_seconds` — blok tugashigacha soniya.
  final int? retryAfterSeconds;

  /// Backend `error.details.attempts_left` (odatda 0).
  final int? attemptsLeft;
}

/// Internet/ulanish xatosi.
class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);

  final String message;
}

/// Mijoz so‘rovi yaroqsiz (HTTP 400) — masalan offline imzo mos kelmadi yoki
/// vaqt eskirgan. Qayta urinish foydasiz: navbatdan o‘chiriladi.
class ValidationException implements Exception {
  const ValidationException([this.message = 'Validation error']);

  final String message;
}
