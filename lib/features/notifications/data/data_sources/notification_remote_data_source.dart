import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

/// Bildirishnoma backend bilan to‘g‘ridan-to‘g‘ri muloqot
/// (`/v1/notifications/`). `AuthInterceptor` Bearer’ni avtomatik biriktiradi.
/// Xatolar tegishli `Exception`larga aylantiriladi; repo ularni `Failure`ga.
abstract interface class NotificationRemoteDataSource {
  Future<NotificationPageModel> getNotifications({int page, bool? isRead});
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<int> unreadCount();
  Future<void> registerDevice({
    required String userId,
    required String fcmToken,
    required String deviceType,
    required String deviceId,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<NotificationPageModel> getNotifications({
    int page = 1,
    bool? isRead,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.notifications,
        queryParameters: {
          'page': page,
          'is_read': ?isRead,
        },
      );
      final body = (response.data as Map?)?.cast<String, dynamic>() ?? {};
      if (body['success'] == false) {
        throw ServerException(_messageFromBody(body));
      }
      return NotificationPageModel.fromJson(body);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> markRead(String id) async {
    try {
      await _client.patch(ApiConstants.notificationRead(id));
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _client.post(ApiConstants.notificationsReadAll);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<int> unreadCount() async {
    try {
      final response = await _client.get(ApiConstants.notificationsCount);
      return _parseCount(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> registerDevice({
    required String userId,
    required String fcmToken,
    required String deviceType,
    required String deviceId,
  }) async {
    try {
      await _client.post(
        ApiConstants.notificationsDeviceRegister,
        data: {
          'user': userId,
          'fcm_token': fcmToken,
          'device_type': deviceType,
          'device_id': deviceId,
        },
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Count endpointi turli ko‘rinishda qaytishi mumkin: xom son, yoki
  /// `{ count }` / `{ unread } / { unread_count }`, yoki konvert ichida.
  int _parseCount(Object? data) {
    if (data is num) return data.toInt();
    if (data is Map) {
      final m = data.cast<String, dynamic>();
      final src = m['data'] is Map ? (m['data'] as Map).cast<String, dynamic>() : m;
      for (final key in ['unread_count', 'unread', 'count']) {
        final v = src[key];
        if (v is num) return v.toInt();
        final parsed = int.tryParse(v?.toString() ?? '');
        if (parsed != null) return parsed;
      }
    }
    final parsed = int.tryParse(data?.toString() ?? '');
    return parsed ?? 0;
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

    if (status == 401) {
      return UnauthorizedException(message ?? 'Unauthorized');
    }
    if (status == 429) {
      return ThrottleException(message ?? 'Too many requests');
    }
    return ServerException(message ?? 'Server xatosi');
  }
}
