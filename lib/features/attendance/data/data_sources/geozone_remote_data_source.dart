import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/geozone_model.dart';

/// `/v1/attendance/geozones/` bilan ishlaydi (GET ro‘yxat).
abstract interface class GeozoneRemoteDataSource {
  Future<List<GeozoneModel>> list();
}

class GeozoneRemoteDataSourceImpl implements GeozoneRemoteDataSource {
  const GeozoneRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<GeozoneModel>> list() async {
    try {
      final response = await _client.get(ApiConstants.geozones);
      // Konvert envelope (`{data:{results:[...]}}`) yoki to‘g‘ridan-to‘g‘ri
      // `{results:[...]}` / ro‘yxat — uchalasini ham qo‘llaymiz.
      final raw = response.data;
      final body =
          raw is Map ? raw.cast<String, dynamic>() : const <String, dynamic>{};
      final inner = body['data'] is Map
          ? (body['data'] as Map).cast<String, dynamic>()
          : body;
      final List list = inner['results'] is List
          ? inner['results'] as List
          : (raw is List ? raw : const []);
      return list
          .whereType<Map>()
          .map((e) => GeozoneModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
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
    if (status == 401) return const UnauthorizedException('Unauthorized');
    return const ServerException('Server xatosi');
  }
}
