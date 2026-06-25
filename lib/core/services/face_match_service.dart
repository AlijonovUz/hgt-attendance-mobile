import 'dart:io';
import 'dart:ui' show Rect;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'face_embedder_service.dart';
import 'logger_service.dart';

/// Diagnostika natijasi — ekranda ko‘rsatish uchun (debug solishtirish sahifasi).
class FaceMatchResult {
  const FaceMatchResult({
    required this.match,
    required this.similarity,
    required this.distance,
    required this.referenceFaces,
    required this.selfieFaces,
    this.error,
  });

  final bool match;

  /// Eng yaxshi cosine o‘xshashlik (variantlar bo‘yicha). Hisoblanmasa `null`.
  final double? similarity;
  final double? distance;
  final int referenceFaces;
  final int selfieFaces;
  final String? error;
}

/// Offline yuz moslik: ML Kit bilan yuz bbox’ini topib, MobileFaceNet embedding
/// orqali selfie’ni keshlangan reference (profil) rasmiga solishtiradi.
///
/// **Muhim (EXIF):** ML Kit fayldan o‘qiganda EXIF rotatsiyani qo‘llaydi, lekin
/// `img.decodeImage` qo‘llamaydi. Shu sabab ilgari bbox bilan crop mos kelmay,
/// bir xil odam ham «mismatch» bo‘lardi. Endi rasm dekod qilinib darhol
/// `bakeOrientation` qilinadi (orientatsiya pikselga «pishiriladi», EXIF teg
/// yo‘qoladi), so‘ng **aynan shu** pishirilgan piksellar vaqtinchalik faylga
/// yozilib, ML Kit shundan o‘qiydi — bbox koordinatalari crop bilan to‘liq mos.
///
/// [matches] — cosine o‘xshashlik [simThreshold]dan katta bo‘lsa `true`. Har
/// bosqich [LoggerService] orqali loglanadi.
class FaceMatchService {
  FaceMatchService(this._embedder, [LoggerService? logger])
      : _logger = logger ?? LoggerService();

  final FaceEmbedderService _embedder;
  final LoggerService _logger;

  /// Cosine o‘xshashlik chegarasi (L2-normalizatsiya qilingan MobileFaceNet
  /// embedding’lar uchun). Bir xil odam odatda > 0.5; turli odam < 0.4.
  /// Loglardagi `sim=` qiymatiga qarab kalibrlash mumkin.
  static const double simThreshold = 0.5;

  /// L2-normalizatsiya qilingan embedding’lar uchun euclid masofa chegarasi
  /// (faqat ma’lumot/log uchun — qaror cosine bo‘yicha).
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
    // Selfie + uning ko‘zgu varianti (old kamera mirror qiladi — referencega
    // nisbatan o‘xshashlikni tushiradi; ikkisidan eng kattasini olamiz).
    final selfie = await _embedFile(selfiePath, tag: 'selfie', flip: true);
    if (selfie.embeddings.isEmpty) {
      _logger.log('[FaceMatch] selfie embedding yo‘q → mismatch');
      return false;
    }

    final refEmb = await _referenceEmbedding(referencePath);
    if (refEmb == null) {
      _logger.log('[FaceMatch] reference embedding yo‘q → mismatch');
      return false;
    }

    final bestSim = _bestSimilarity(selfie.embeddings, refEmb);
    final match = bestSim >= simThreshold;
    _logger.log(
      '[FaceMatch] sim=${bestSim.toStringAsFixed(4)} '
      '(chegara=$simThreshold, variant=${selfie.embeddings.length}) '
      '→ match=$match',
    );
    return match;
  }

  /// Debug solishtirish: ikkita rasmni to‘liq quvur orqali o‘tkazib, ekranda
  /// ko‘rsatish uchun boy natija qaytaradi (yuz soni, sim, dist, xato). Kamera
  /// shart emas — galereyadan tanlangan ikki fayl bilan kalibrlash uchun.
  Future<FaceMatchResult> diagnose({
    required String referencePath,
    required String selfiePath,
  }) async {
    final ref = await _embedFile(referencePath, tag: 'reference');
    final selfie = await _embedFile(selfiePath, tag: 'selfie', flip: true);

    final error = ref.error ?? selfie.error;
    if (ref.embeddings.isEmpty || selfie.embeddings.isEmpty) {
      return FaceMatchResult(
        match: false,
        similarity: null,
        distance: null,
        referenceFaces: ref.faceCount,
        selfieFaces: selfie.faceCount,
        error: error ??
            (ref.embeddings.isEmpty
                ? 'Reference rasmda yuz/embedding topilmadi'
                : 'Selfie rasmda yuz/embedding topilmadi'),
      );
    }

    final refEmb = ref.embeddings.first;
    final bestSim = _bestSimilarity(selfie.embeddings, refEmb);
    final dist =
        FaceEmbedderService.euclideanDistance(selfie.embeddings.first, refEmb);
    final match = bestSim >= simThreshold;
    _logger.log(
      '[FaceMatch][diagnose] sim=${bestSim.toStringAsFixed(4)} '
      'dist=${dist.toStringAsFixed(4)} match=$match',
    );
    return FaceMatchResult(
      match: match,
      similarity: bestSim,
      distance: dist,
      referenceFaces: ref.faceCount,
      selfieFaces: selfie.faceCount,
      error: error,
    );
  }

  /// Ikki rasmdagi yuzlar orasidagi euclid masofa (taqqoslab bo‘lmasa `null`).
  /// Test/kalibrlash uchun saqlangan.
  Future<double?> distanceBetween({
    required String selfiePath,
    required String referencePath,
  }) async {
    final selfie = await _embedFile(selfiePath, tag: 'selfie');
    if (selfie.embeddings.isEmpty) return null;
    final refEmb = await _referenceEmbedding(referencePath);
    if (refEmb == null) return null;
    return FaceEmbedderService.euclideanDistance(
      selfie.embeddings.first,
      refEmb,
    );
  }

  double _bestSimilarity(List<List<double>> embeddings, List<double> ref) {
    var best = -1.0;
    for (final emb in embeddings) {
      final sim = FaceEmbedderService.cosineSimilarity(emb, ref);
      if (sim > best) best = sim;
    }
    return best;
  }

  Future<List<double>?> _referenceEmbedding(String path) async {
    if (_refPath == path && _refEmbedding != null) return _refEmbedding;
    final ref = await _embedFile(path, tag: 'reference');
    if (ref.embeddings.isNotEmpty) {
      _refPath = path;
      _refEmbedding = ref.embeddings.first;
      return ref.embeddings.first;
    }
    return null;
  }

  /// Faylni o‘qiydi → EXIF pishiriladi → ML Kit yuz bbox → eng katta yuz crop →
  /// embedding(lar). [flip] true bo‘lsa qo‘shimcha ko‘zgu (mirror) varianti ham
  /// qaytariladi. Har qanday xatoda loglab bo‘sh natija (istisno yutilmaydi).
  Future<_EmbedOutcome> _embedFile(
    String path, {
    required String tag,
    bool flip = false,
  }) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        _logger.log('[FaceMatch] $tag fayl yo‘q: $path');
        return _EmbedOutcome(error: '$tag fayl yo‘q');
      }

      final bytes = await file.readAsBytes();
      final decoded = decodeImageBytes(bytes);
      if (decoded == null) {
        _logger.log('[FaceMatch] $tag decode bo‘lmadi: $path');
        return _EmbedOutcome(error: '$tag rasm dekod bo‘lmadi');
      }

      // EXIF orientatsiyani pikselga pishiramiz — ML Kit (fayldan) va crop bir
      // koordinata fazosida bo‘lishi uchun.
      final baked = img.bakeOrientation(decoded);
      _logger.log(
        '[FaceMatch] $tag dekod: ${decoded.width}x${decoded.height} '
        '→ baked: ${baked.width}x${baked.height}',
      );

      // Aynan pishirilgan piksellardan ML Kit detect qiladi (EXIF tegsiz JPG).
      final detectPath = await _writeTempJpg(baked, tag);
      final faces =
          await _detector.processImage(InputImage.fromFilePath(detectPath));
      await _deleteQuietly(detectPath);
      _logger.log('[FaceMatch] $tag yuzlar soni: ${faces.length}');
      if (faces.isEmpty) {
        return _EmbedOutcome(faceCount: 0, error: '$tag rasmda yuz topilmadi');
      }

      // Eng katta yuzni tanlaymiz (eng yaqin/aniq).
      faces.sort(
        (a, b) => _area(b.boundingBox).compareTo(_area(a.boundingBox)),
      );
      final crop = _cropFace(baked, faces.first.boundingBox);

      final result = <List<double>>[];
      final emb = await _embedder.embed(crop);
      if (emb != null) result.add(emb);
      if (flip) {
        final flipped = img.flipHorizontal(crop);
        final embFlip = await _embedder.embed(flipped);
        if (embFlip != null) result.add(embFlip);
      }
      return _EmbedOutcome(
        embeddings: result,
        faceCount: faces.length,
        error: result.isEmpty ? '$tag embedding chiqmadi (model xatosi?)' : null,
      );
    } catch (e, st) {
      _logger.log('[FaceMatch] XATO _embedFile($tag): $e\n$st');
      return _EmbedOutcome(error: '$tag xato: $e');
    }
  }

  double _area(Rect r) => r.width * r.height;

  /// Pishirilgan rasmni vaqtinchalik JPG faylga yozadi (ML Kit fromFilePath uchun).
  Future<String> _writeTempJpg(img.Image image, String tag) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}${Platform.pathSeparator}'
        'facematch_${tag}_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(img.encodeJpg(image, quality: 95), flush: true);
    return path;
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
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

/// `_embedFile` ichki natijasi — embedding(lar) + yuz soni + xato sababi.
class _EmbedOutcome {
  _EmbedOutcome({
    this.embeddings = const [],
    this.faceCount = 0,
    this.error,
  });

  final List<List<double>> embeddings;
  final int faceCount;
  final String? error;
}
