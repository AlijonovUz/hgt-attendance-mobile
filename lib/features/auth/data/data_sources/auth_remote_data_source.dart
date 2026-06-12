import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_tokens_model.dart';

/// Auth backend bilan to‘g‘ridan-to‘g‘ri muloqot (api/v1/users/auth).
///
/// Xatolar tegishli `Exception`larga aylantiriladi: 401 → [UnauthorizedException],
/// 429 → [ThrottleException], ulanish → [NetworkException], qolgani →
/// [ServerException]. Repo ularni `Failure`ga, bloc esa lokalizatsiyaga o‘giradi.
abstract interface class AuthRemoteDataSource {
  /// `full_name` + `password` bilan login → token juftligi.
  Future<AuthTokensModel> login({
    required String fullName,
    required String password,
  });

  /// Selfie faylini `image` maydonida FormData bilan yuboradi. Bearer sifatida
  /// [accessToken] (hali saqlanmagan, RAM’dagi) ishlatiladi. 2xx → tasdiqlandi.
  Future<void> verifyFace({
    required String imagePath,
    required String accessToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<AuthTokensModel> login({
    required String fullName,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.login,
        data: {'full_name': fullName, 'password': password},
      );

      final body = (response.data as Map?)?.cast<String, dynamic>() ?? {};
      // Konvert (success=false) — tipik xatoni (`errorId` bo‘yicha) o‘qiymiz.
      if (body['success'] == false) {
        throw _exceptionFromBody(body);
      }
      final model = AuthTokensModel.fromJson(body);
      if (model.access.isEmpty) {
        throw ServerException(_messageFromBody(body));
      }
      return model;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> verifyFace({
    required String imagePath,
    required String accessToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath, filename: 'selfie.jpg'),
      });
      final response = await _client.post(
        ApiConstants.verifyFace,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          contentType: Headers.multipartFormDataContentType,
        ),
      );
      // 200 — bo‘sh tana (swagger). Konvert success=false bo‘lsa — xato.
      final body = (response.data as Map?)?.cast<String, dynamic>();
      if (body != null && body['success'] == false) {
        throw _exceptionFromBody(body);
      }
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Konvertdagi `error.errorMsg` yoki DRF `detail`ni ajratib oladi.
  String _messageFromBody(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map && error['errorMsg'] is String) {
      return error['errorMsg'] as String;
    }
    if (body['detail'] is String) return body['detail'] as String;
    return 'Server xatosi';
  }

  /// Konvertdagi `error.details` xaritasi (`attempts_left`, `retry_after_seconds`).
  Map<String, dynamic> _detailsFromBody(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map && error['details'] is Map) {
      return (error['details'] as Map).cast<String, dynamic>();
    }
    return const {};
  }

  int? _asInt(Object? v) => switch (v) {
        int() => v,
        num() => v.toInt(),
        String() => int.tryParse(v),
        _ => null,
      };

  /// Konvert tanasidan (`{ error: { errorId, errorMsg, details } }`) tipik
  /// `Exception` quradi. [httpStatus] — `errorId` yo‘q bo‘lsa zaxira sifatida.
  Exception _exceptionFromBody(Map<String, dynamic> body, {int? httpStatus}) {
    final error = body['error'];
    final errorId = error is Map ? _asInt(error['errorId']) : null;
    final status = errorId ?? httpStatus;
    final message = _messageFromBody(body);
    final details = _detailsFromBody(body);
    final attemptsLeft = _asInt(details['attempts_left']);
    final retryAfter = _asInt(details['retry_after_seconds']);

    if (status == 401) return UnauthorizedException(message, attemptsLeft);
    if (status == 429) {
      return ThrottleException(message, retryAfter, attemptsLeft);
    }
    return ServerException(message);
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
    if (body != null) return _exceptionFromBody(body, httpStatus: status);

    if (status == 401) return const UnauthorizedException();
    if (status == 429) return const ThrottleException();
    return const ServerException();
  }
}
