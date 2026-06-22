import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/attendance_event_type.dart';
import '../models/attendance_event_model.dart';
import '../models/personal_stats_model.dart';

/// `/v1/attendance/attendance/` bilan ishlaydi (POST belgilash + GET bugungilar).
abstract interface class AttendanceRemoteDataSource {
  Future<void> mark({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    required String imagePath,
  });

  /// Bugungi yozuvlar (joriy foydalanuvchi, sana oralig‘i bilan filtrlangan).
  Future<List<AttendanceEventModel>> getTodayEvents({required String userId});

  /// Sana oralig‘idagi yozuvlar (tarix — Kunlik/Haftalik/Oylik/Custom).
  /// `start_date`/`end_date` = `dd.MM.yyyy`.
  Future<List<AttendanceEventModel>> getEvents({
    required String userId,
    required DateTime start,
    required DateTime end,
  });

  /// Sana oralig‘i bo‘yicha shaxsiy statistika. `start_date`/`end_date` =
  /// `yyyy-MM-dd` (swagger personal-stats kontrakti).
  Future<PersonalStatsModel> getPersonalStats({
    required DateTime start,
    required DateTime end,
  });
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
  }) async {
    try {
      final fileName = imagePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'event_type': eventType.apiValue,
        'gps_latitude': latitude.toString(),
        'gps_longitude': longitude.toString(),
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
      // final end = start
      //     .add(const Duration(days: 1))
      //     .subtract(const Duration(seconds: 1));

      final response = await _client.get(
        ApiConstants.attendance,
        queryParameters: {
          'user': userId,
          'start_date': DateFormat('dd.MM.yyyy').format(start),
          // 'end_date': end.toUtc().toIso8601String(),
          // 'ordering': 'created_at',
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

  @override
  Future<List<AttendanceEventModel>> getEvents({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final fmt = DateFormat('dd.MM.yyyy');
      final response = await _client.get(
        ApiConstants.attendance,
        queryParameters: {
          'user': userId,
          'start_date': fmt.format(start),
          'end_date': fmt.format(end),
        },
      );
      return _eventsFromResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<PersonalStatsModel> getPersonalStats({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final response = await _client.get(
        ApiConstants.attendancePersonalStats,
        queryParameters: {
          'start_date': fmt.format(start),
          'end_date': fmt.format(end),
        },
      );
      final body = (response.data as Map?)?.cast<String, dynamic>() ?? {};
      if (body['success'] == false) {
        throw ServerException(_messageFromBody(body));
      }
      return PersonalStatsModel.fromJson(body);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Konvert envelope (`{data:{results:[...]}}`) yoki to‘g‘ridan-to‘g‘ri
  /// `{results:[...]}` / ro‘yxatdan yozuvlarni ajratadi.
  List<AttendanceEventModel> _eventsFromResponse(dynamic raw) {
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
    return ServerException(message ?? 'Server xatosi');
  }
}
