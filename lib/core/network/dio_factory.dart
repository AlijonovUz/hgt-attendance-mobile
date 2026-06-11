import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

abstract final class DioFactory {
  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          seconds: AppConstants.requestTimeoutSeconds,
        ),
        receiveTimeout: const Duration(
          seconds: AppConstants.requestTimeoutSeconds,
        ),
        sendTimeout: const Duration(
          seconds: AppConstants.requestTimeoutSeconds,
        ),
        headers: const {'Content-Type': 'application/json'},
      ),
    );
  }
}
