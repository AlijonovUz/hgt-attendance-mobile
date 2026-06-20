import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/attendance_event_type.dart';
import '../models/attendance_event_model.dart';

/// `/v1/attendance/attendance/` bilan ishlaydi (POST belgilash + GET bugungilar).
abstract interface class AttendanceRemoteDataSource {
  /// Davomat belgilash. Offline sinxronda [createdAtIso] (lokal vaqt, +offset)
  /// va [signature] (HMAC) ham yuboriladi; online belgilashda ular `null`.
  Future<void> mark({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    required String imagePath,
    String? createdAtIso,
    String? signature,
  });

  /// Bugungi yozuvlar (joriy foydalanuvchi, sana oralig‘i bilan filtrlangan).
  Future<List<AttendanceEventModel>> getTodayEvents({required String userId});
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  const AttendanceRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<void> mark({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    required String imagePath,
    String? createdAtIso,
    String? signature,
  }) async {
    try {
      final fileName = imagePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'event_type': eventType.apiValue,
        'gps_latitude': latitude.toString(),
        'gps_longitude': longitude.toString(),
        // Offline sinxron: imzolangan vaqt + imzo (mavjud bo‘lsa).
        'created_at': ?createdAtIso,
        'signature': ?signature,
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: fileName.isEmpty ? 'attendance.jpg' : fileName,
        ),
      });
      // Saqlangan token AuthInterceptor orqali avtomatik biriktiriladi;
      // 401 da RefreshInterceptor ishlaydi (skipRefresh kerak emas).
      final response = await _client.post(
        ApiConstants.attendance,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
      final body = (response.data as Map?)?.cast<String, dynamic>();
      if (body != null && body['success'] == false) {
        throw ServerException(_messageFromBody(body));
      }
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<AttendanceEventModel>> getTodayEvents({
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      final response = await _client.get(
        ApiConstants.attendance,
        queryParameters: {
          'user': userId,
          'date_from': start.toUtc().toIso8601String(),
          'date_to': end.toUtc().toIso8601String(),
          'ordering': 'created_at',
        },
      );

      // Konvert envelope: {data: {count, results:[...]}, success} yoki
      // to‘g‘ridan-to‘g‘ri {results:[...]} / ro‘yxat.
      final raw = response.data;
      final body = raw is Map
          ? raw.cast<String, dynamic>()
          : const <String, dynamic>{};
      final inner = body['data'] is Map
          ? (body['data'] as Map).cast<String, dynamic>()
          : body;
      final List list = inner['results'] is List
          ? inner['results'] as List
          : (raw is List ? raw : const []);

      return list
          .whereType<Map>()
          .map((e) => AttendanceEventModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// `error.details`dagi maydon xatolari (`non_field_errors`, …) aniqroq sabab
  /// beradi (masalan «Siz ish joyida emassiz.») — umumiy `errorMsg`dan ustun.
  String _messageFromBody(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map) {
      final detailMsg = _detailErrors(error['details']);
      if (detailMsg != null) return detailMsg;
      if (error['errorMsg'] is String) return error['errorMsg'] as String;
    }
    if (body['detail'] is String) return body['detail'] as String;
    return 'Server xatosi';
  }

  /// `error.details` ichidagi matn/ro‘yxat xatolarini yig‘adi (`non_field_errors`
  /// birinchi). Throttle hisoblagichlari chetlab o‘tiladi.
  String? _detailErrors(Object? details) {
    if (details is! Map) return null;
    final messages = <String>[];
    void collect(Object? v) {
      if (v is String) {
        if (v.trim().isNotEmpty) messages.add(v.trim());
      } else if (v is List) {
        for (final e in v) {
          collect(e);
        }
      }
    }

    collect(details['non_field_errors']);
    details.forEach((key, value) {
      if (key == 'non_field_errors' ||
          key == 'attempts_left' ||
          key == 'retry_after_seconds') {
        return;
      }
      collect(value);
    });
    return messages.isEmpty ? null : messages.join('\n');
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
    // 4xx (mas. 400 — imzo mos emas / vaqt eskirgan) — mijoz xatosi, retry foydasiz.
    if (status != null && status >= 400 && status < 500) {
      return ValidationException(message ?? 'Validation error');
    }
    return ServerException(message ?? 'Server xatosi');
  }
}
