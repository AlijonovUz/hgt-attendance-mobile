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
