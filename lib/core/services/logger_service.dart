import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

typedef LogSink = void Function(String message);

class LoggerService {
  LoggerService({LogSink? logSink}) : _logSink = logSink ?? _defaultLogSink;

  final LogSink _logSink;

  void log(String message) {
    _logSink(message);
  }

  static void _defaultLogSink(String message) {
    developer.log(message, name: 'Davomat');
    if (kDebugMode) {
      debugPrint('[HGT Davomat] $message');
    }
  }
}
