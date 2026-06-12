class ServerException implements Exception {
  const ServerException([this.message = 'Server exception']);

  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache exception']);

  final String message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Unauthorized']);

  final String message;
}

/// So‘rovlar soni cheklangan (HTTP 429).
class ThrottleException implements Exception {
  const ThrottleException([this.message = 'Too many requests']);

  final String message;
}

/// Internet/ulanish xatosi.
class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);

  final String message;
}
