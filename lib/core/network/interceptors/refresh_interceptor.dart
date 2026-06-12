import 'package:dio/dio.dart';

import '../../../app/bloc/session_bloc.dart';
import '../../constants/api_constants.dart';
import '../../services/token_service.dart';

/// 401 da access tokenni refresh token bilan yangilab, asl so‘rovni qayta
/// yuboradi. Auth endpointlari (login/refresh) chetlab o‘tiladi — aks holda
/// noto‘g‘ri parol ham refresh siklini qo‘zg‘atardi.
///
/// Refresh ham muvaffaqiyatsiz bo‘lsa — sessiya tugatiladi (login sahifaga).
/// [QueuedInterceptor] bir vaqtdagi bir nechta 401ni ketma-ket boshqaradi,
/// shu sabab token faqat bir marta yangilanadi.
class RefreshInterceptor extends QueuedInterceptor {
  RefreshInterceptor({
    required TokenService tokenService,
    required Dio refreshDio,
    required SessionBloc Function() session,
  })  : _tokenService = tokenService,
        _refreshDio = refreshDio,
        _session = session;

  final TokenService _tokenService;
  final Dio _refreshDio;
  final SessionBloc Function() _session;

  bool _isAuthPath(String path) =>
      path.contains(ApiConstants.login) ||
      path.contains(ApiConstants.refresh) ||
      // Verify-face RAM’dagi (hali saqlanmagan) token bilan ketadi — refresh
      // token diskda yo‘q, shu sabab refresh sikli ma’nosiz va SessionExpired’ni
      // noto‘g‘ri qo‘zg‘atardi.
      path.contains(ApiConstants.verifyFace);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    final skipRefresh = err.requestOptions.extra['skipRefresh'] == true;

    if (status != 401 || skipRefresh || _isAuthPath(path)) {
      return handler.next(err);
    }

    final refreshToken = _tokenService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _session().add(const SessionExpired());
      return handler.next(err);
    }

    try {
      final response = await _refreshDio.post(
        ApiConstants.refresh,
        data: {'refresh': refreshToken},
      );

      final body = (response.data as Map?)?.cast<String, dynamic>() ?? {};
      final newAccess = body['access'] as String?;
      final newRefresh = body['refresh'] as String?;
      if (newAccess == null || newAccess.isEmpty) {
        throw const FormatException('No access token in refresh response');
      }

      await _tokenService.saveToken(newAccess);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await _tokenService.saveRefreshToken(newRefresh);
      }

      // Asl so‘rovni yangi token bilan qayta yuborish.
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newAccess';
      final retried = await _refreshDio.fetch<dynamic>(options);
      return handler.resolve(retried);
    } catch (_) {
      _session().add(const SessionExpired());
      return handler.next(err);
    }
  }
}
