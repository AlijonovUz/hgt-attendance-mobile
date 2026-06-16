import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';

/// Onboarding backend muloqoti.
abstract interface class OnboardingRemoteDataSource {
  /// `change-password` endpointiga `old_password` / `new_password` /
  /// `confirm_new_password` bilan POST. [accessToken] berilsa manual Bearer +
  /// `skipRefresh` (token hali saqlanmagan onboarding bosqichi).
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
    String? accessToken,
  });
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  const OnboardingRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
    String? accessToken,
  }) async {
    try {
      final hasManualToken = accessToken != null && accessToken.isNotEmpty;
      final response = await _client.put(
        ApiConstants.setPassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_new_password': confirmNewPassword,
        },
        options: Options(
          headers: hasManualToken
              ? {'Authorization': 'Bearer $accessToken'}
              : null,
          // RAM token bosqichida refresh tokeni diskda yo‘q — refresh siklini
          // o‘tkazib yuboramiz (RefreshInterceptor `skipRefresh`ni o‘qiydi).
          extra: hasManualToken ? const {'skipRefresh': true} : null,
        ),
      );
      final body = (response.data as Map?)?.cast<String, dynamic>();
      if (body != null && body['success'] == false) {
        throw ServerException(_messageFromBody(body));
      }
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  String _messageFromBody(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map && error['errorMsg'] is String) {
      return error['errorMsg'] as String;
    }
    if (body['detail'] is String) return body['detail'] as String;
    return 'Server xatosi';
  }

  Exception _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException();
      default:
        break;
    }

    final status = e.response?.statusCode;
    final body = (e.response?.data as Map?)?.cast<String, dynamic>();
    final message = body == null ? null : _messageFromBody(body);

    if (status == 401) return UnauthorizedException(message ?? 'Unauthorized');
    if (status == 429) return ThrottleException(message ?? 'Too many requests');
    return ServerException(message ?? 'Server xatosi');
  }
}
