import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

/// Profil backend bilan to‘g‘ridan-to‘g‘ri muloqot (`/v1/users/auth/profile/`).
///
/// `AuthInterceptor` Bearer’ni avtomatik biriktiradi (saqlangan token). Xatolar
/// tegishli `Exception`larga aylantiriladi; repo ularni `Failure`ga o‘giradi.
abstract interface class ProfileRemoteDataSource {
  /// GET — joriy profil. [accessToken] berilsa manual Bearer + refresh siklini
  /// chetlab o‘tish (token hali saqlanmagan onboarding bosqichi).
  Future<ProfileModel> getProfile({String? accessToken});

  /// PATCH — faqat `face_image` faylini multipart bilan yangilaydi.
  /// [accessToken] berilsa manual Bearer + refresh siklini chetlab o‘tish
  /// (token hali saqlanmagan bosqich — yuzdan oldin).
  Future<ProfileModel> updateFaceImage(String imagePath, {String? accessToken});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<ProfileModel> getProfile({String? accessToken}) async {
    try {
      final hasManualToken = accessToken != null && accessToken.isNotEmpty;
      final response = await _client.get(
        ApiConstants.profile,
        options: hasManualToken
            ? Options(
                headers: {'Authorization': 'Bearer $accessToken'},
                extra: const {'skipRefresh': true},
              )
            : null,
      );
      final body = (response.data as Map?)?.cast<String, dynamic>() ?? {};
      if (body['success'] == false) {
        throw ServerException(_messageFromBody(body));
      }
      return ProfileModel.fromJson(body);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<ProfileModel> updateFaceImage(
    String imagePath, {
    String? accessToken,
  }) async {
    try {
      final fileName = imagePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'face_image': await MultipartFile.fromFile(
          imagePath,
          filename: fileName.isEmpty ? 'profile.jpg' : fileName,
        ),
      });
      final hasManualToken = accessToken != null && accessToken.isNotEmpty;
      final response = await _client.patch(
        ApiConstants.profile,
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: hasManualToken
              ? {'Authorization': 'Bearer $accessToken'}
              : null,
          // RAM token bosqichida refresh tokeni diskda yo‘q — refresh siklini
          // o‘tkazib yuboramiz (RefreshInterceptor `skipRefresh` flagini o‘qiydi).
          extra: hasManualToken ? const {'skipRefresh': true} : null,
        ),
      );
      final body = (response.data as Map?)?.cast<String, dynamic>() ?? {};
      if (body['success'] == false) {
        throw ServerException(_messageFromBody(body));
      }
      return ProfileModel.fromJson(body);
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

    if (status == 401) {
      return UnauthorizedException(message ?? 'Unauthorized');
    }
    if (status == 429) {
      return ThrottleException(message ?? 'Too many requests');
    }
    return ServerException(message ?? 'Server xatosi');
  }
}
