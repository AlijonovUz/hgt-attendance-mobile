import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/face_embedding_service.dart';
import '../../domain/repository/face_reference_repository.dart';
import '../data_sources/attendance_local_data_source.dart';

class FaceReferenceRepositoryImpl implements FaceReferenceRepository {
  FaceReferenceRepositoryImpl({
    required FaceEmbeddingService embedding,
    required AttendanceLocalDataSource local,
    Dio? downloader,
  })  : _embedding = embedding,
        _local = local,
        _downloader = downloader ?? Dio();

  final FaceEmbeddingService _embedding;
  final AttendanceLocalDataSource _local;
  final Dio _downloader;

  @override
  Future<void> ensureFor({
    required String profileId,
    required String? faceImageUrl,
  }) async {
    final url = faceImageUrl?.trim() ?? '';
    if (url.isEmpty) return;

    final key = '$profileId|$url';
    final cached = _local.referenceEmbedding();
    if (cached != null && cached.key == key) return; // o‘zgarmagan.

    File? tmp;
    try {
      final bytes = await _downloader.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = bytes.data;
      if (data == null || data.isEmpty) return;

      final dir = await getTemporaryDirectory();
      tmp = File('${dir.path}/ref_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tmp.writeAsBytes(data, flush: true);

      final vector = await _embedding.embed(tmp);
      if (vector == null) return; // yuz topilmadi.
      await _local.saveReferenceEmbedding(key, vector);
    } catch (_) {
      // Tarmoq/dekod xatosi — keyingi profil yangilanishida qayta uriniladi.
    } finally {
      try {
        if (tmp != null && tmp.existsSync()) await tmp.delete();
      } catch (_) {}
    }
  }

  @override
  List<double>? cachedEmbedding() => _local.referenceEmbedding()?.vector;
}
