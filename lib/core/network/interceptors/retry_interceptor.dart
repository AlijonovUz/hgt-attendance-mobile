import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.maxRetries = 1});

  final int maxRetries;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: Add robust exponential backoff retry strategy.
    handler.next(err);
  }
}
