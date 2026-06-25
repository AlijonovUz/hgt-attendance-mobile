import 'dart:io';
import 'dart:ui' show Rect;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'face_embedder_service.dart';

/// Offline yuz moslik: ML Kit bilan yuz bbox’ini topib, MobileFaceNet embedding
/// orqali selfie’ni keshlangan reference (profil) rasmiga solishtiradi.
///
/// [matches] — masofa [matchThreshold]dan kichik bo‘lsa `true` (bir xil odam).
/// Reference embedding bir marta hisoblanib RAM’da keshlanadi (har davomatda
/// qayta hisoblamaslik uchun).
class FaceMatchService {
  FaceMatchService(this._embedder);

  final FaceEmbedderService _embedder;

  /// L2-normalizatsiya qilingan embedding’lar uchun euclid masofa chegarasi.
  /// MobileFaceNet/FaceRecognitionAuth amaliyotiga asoslangan boshlang‘ich
  /// qiymat — real selfie’lar bilan kalibrlash mumkin.
  static const double matchThreshold = 1.0;

  late final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.15,
    ),
  );

  // Reference (path → embedding) RAM keshi.
  String? _refPath;
  List<double>? _refEmbedding;

  /// Selfie va reference bir odammi. Yuz topilmasa yoki embedding chiqmasa
  /// `false` (xavfsiz default — bloklash). [referencePath] bir xil bo‘lsa
  /// embedding keshdan olinadi.
  Future<bool> matches({
    required String selfiePath,
    required String referencePath,
  }) async {
    final distance = await distanceBetween(
      selfiePath: selfiePath,
      referencePath: referencePath,
    );
    // ignore: avoid_print
    print(
      '[FaceMatch] selfie=$selfiePath ref=$referencePath '
      'distance=$distance threshold=$matchThreshold '
      'match=${distance != null && distance <= matchThreshold}',
    );
    if (distance == null) return false;
    return distance <= matchThreshold;
  }

  /// Ikki rasmdagi yuzlar orasidagi masofa (taqqoslab bo‘lmasa `null`).
  Future<double?> distanceBetween({
    required String selfiePath,
    required String referencePath,
  }) async {
    final selfieEmb = await _embedFile(selfiePath);
    if (selfieEmb == null) return null;

    final refEmb = await _referenceEmbedding(referencePath);
    if (refEmb == null) return null;

    return FaceEmbedderService.euclideanDistance(selfieEmb, refEmb);
  }

  Future<List<double>?> _referenceEmbedding(String path) async {
    if (_refPath == path && _refEmbedding != null) return _refEmbedding;
    final emb = await _embedFile(path);
    if (emb != null) {
      _refPath = path;
      _refEmbedding = emb;
    }
    return emb;
  }

  /// Faylni o‘qiydi → ML Kit yuz bbox → crop → embedding. Yuz yo‘q/o‘qilmasa
  /// `null`.
  Future<List<double>?> _embedFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      // ignore: avoid_print
      print('[FaceMatch] file yo\'q: $path');
      return null;
    }

    final faces = await _detector.processImage(InputImage.fromFilePath(path));
    if (faces.isEmpty) {
      // ignore: avoid_print
      print('[FaceMatch] yuz topilmadi: $path');
      return null;
    }

    final bytes = await file.readAsBytes();
    final decoded = decodeImageBytes(bytes);
    if (decoded == null) {
      // ignore: avoid_print
      print('[FaceMatch] decode bo\'lmadi: $path');
      return null;
    }

    final crop = _cropFace(decoded, faces.first.boundingBox);
    return _embedder.embed(crop);
  }

  /// ML Kit bbox’ini rasm chegaralariga moslab kesadi (chetlardan biroz
  /// kengaytirib, salbiy/oshib ketishdan himoyalanadi).
  img.Image _cropFace(img.Image image, Rect box) {
    final pad = box.width * 0.1;
    var left = (box.left - pad).round();
    var top = (box.top - pad).round();
    var right = (box.right + pad).round();
    var bottom = (box.bottom + pad).round();

    left = left.clamp(0, image.width - 1);
    top = top.clamp(0, image.height - 1);
    right = right.clamp(left + 1, image.width);
    bottom = bottom.clamp(top + 1, image.height);

    return img.copyCrop(
      image,
      x: left,
      y: top,
      width: right - left,
      height: bottom - top,
    );
  }

  void dispose() {
    _detector.close();
    _embedder.close();
  }
}
