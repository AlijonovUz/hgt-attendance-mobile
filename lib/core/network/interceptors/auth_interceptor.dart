import 'package:dio/dio.dart';

import '../../services/token_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenService);

  final TokenService _tokenService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
