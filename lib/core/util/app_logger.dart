import '../services/logger_service.dart';

abstract final class AppLogger {
  static final LoggerService _logger = LoggerService();

  static void log(String message) => _logger.log(message);
}
