import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// On-device yuz moslik (offline) — MobileFaceNet `tflite` modeli.
///
/// FaceRecognitionAuth (MCarlomagno) yondashuvi: rasmdan eng katta yuz aniqlanib
/// 112×112 ga kesiladi/o‘lchanadi, `(piksel-128)/128` normallashtiriladi va
/// model 192-o‘lchamli embedding qaytaradi. Ikki embedding orasidagi **euclidean**
/// masofa [threshold]dan kichik bo‘lsa — bir xil odam.
///
/// Online’da `profile.face_image`dan reference embedding hisoblanadi; offline’da
/// jonli selfie embeddingi shu bilan solishtiriladi (sinxronda backend qayta
/// tekshiradi — bu faqat UX darvozasi).
class FaceEmbeddingService {
  FaceEmbeddingService();

  static const _modelAsset = 'assets/models/mobilefacenet.tflite';
  static const _inputSize = 112;
  static const _embeddingSize = 192;

  /// Moslik chegarasi (euclidean). Kichikroq = qattiqroq. MobileFaceNet uchun
  /// ~1.0–1.4 oralig‘i; ehtiyotkor standart.
  static const double matchThreshold = 1.0;

  Interpreter? _interpreter;
  FaceDetector? _detector;

  Future<void> init() async {
    _interpreter ??= await Interpreter.fromAsset(_modelAsset);
    _detector ??= FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );
  }

  /// Fayldagi rasmdan yuz embeddingini hisoblaydi. Yuz topilmasa yoki rasm
  /// yaroqsiz bo‘lsa `null`.
  Future<List<double>?> embed(File file) async {
    await init();

    final faces = await _detector!.processImage(
      InputImage.fromFilePath(file.path),
    );
    final decoded = img.decodeImage(await file.readAsBytes());
    if (decoded == null) return null;

    final img.Image crop;
    if (faces.isNotEmpty) {
      // Eng katta yuzni tanlaymiz.
      faces.sort((a, b) =>
          (b.boundingBox.width * b.boundingBox.height)
              .compareTo(a.boundingBox.width * a.boundingBox.height));
      crop = _cropFace(decoded, faces.first.boundingBox);
    } else {
      // Yuz aniqlanmasa — markazdan kvadrat (zaxira; odatda match fail bo‘ladi).
      final side = math.min(decoded.width, decoded.height);
      crop = img.copyCrop(
        decoded,
        x: (decoded.width - side) ~/ 2,
        y: (decoded.height - side) ~/ 2,
        width: side,
        height: side,
      );
    }

    final resized =
        img.copyResize(crop, width: _inputSize, height: _inputSize);
    return _run(resized);
  }

  /// Ikki embedding orasidagi euclidean masofa.
  double distance(List<double> a, List<double> b) {
    var sum = 0.0;
    final n = math.min(a.length, b.length);
    for (var i = 0; i < n; i++) {
      final d = a[i] - b[i];
      sum += d * d;
    }
    return math.sqrt(sum);
  }

  /// Ikki embedding bir xil odamga tegishlimi (masofa [threshold]dan kichik).
  bool matches(List<double> a, List<double> b, {double? threshold}) =>
      distance(a, b) < (threshold ?? matchThreshold);

  img.Image _cropFace(img.Image src, Rect box) {
    // Yuz atrofiga 20% marj; rasm chegarasidan chiqib ketmasin.
    final marginX = box.width * 0.2;
    final marginY = box.height * 0.2;
    final left = (box.left - marginX).clamp(0, src.width - 1).toInt();
    final top = (box.top - marginY).clamp(0, src.height - 1).toInt();
    final right = (box.right + marginX).clamp(0, src.width.toDouble()).toInt();
    final bottom =
        (box.bottom + marginY).clamp(0, src.height.toDouble()).toInt();
    return img.copyCrop(
      src,
      x: left,
      y: top,
      width: math.max(1, right - left),
      height: math.max(1, bottom - top),
    );
  }

  List<double> _run(img.Image image) {
    // [1, 112, 112, 3] float32, (piksel-128)/128.
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          final p = image.getPixel(x, y);
          return [
            (p.r - 128) / 128.0,
            (p.g - 128) / 128.0,
            (p.b - 128) / 128.0,
          ];
        }),
      ),
    );

    final output =
        List.filled(_embeddingSize, 0.0).reshape([1, _embeddingSize]);
    _interpreter!.run(input, output);
    return List<double>.from(output[0] as List);
  }

  Future<void> close() async {
    _interpreter?.close();
    _interpreter = null;
    await _detector?.close();
    _detector = null;
  }
}
