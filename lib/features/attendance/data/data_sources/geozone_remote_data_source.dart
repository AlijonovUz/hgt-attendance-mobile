import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/geozone_model.dart';

/// `GET /v1/attendance/geozones/` — barcha ish hududlari.
abstract interface class GeozoneRemoteDataSource {
  Future<List<GeozoneModel>> getGeozones();
}

class GeozoneRemoteDataSourceImpl implements GeozoneRemoteDataSource {
  const GeozoneRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<GeozoneModel>> getGeozones() async {
    try {
      final response = await _client.get(ApiConstants.geozones);
      return GeozoneModel.listFromResponse(response.data);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw const NetworkException();
        default:
          final status = e.response?.statusCode;
          if (status == 401) throw const UnauthorizedException();
          throw const ServerException();
      }
    }
  }
}
