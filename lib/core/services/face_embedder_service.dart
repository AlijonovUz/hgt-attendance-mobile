import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// MobileFaceNet (`assets/models/mobilefacenet.tflite`) embedding generatori.
///
/// Kirish: 112×112×3 RGB, `[-1, 1]` ga normalizatsiya (`(p - 127.5) / 128`).
/// Chiqish: yuz embedding vektori (model 128/192 o‘lchamli bo‘lishi mumkin —
/// interpreter tensoridan dinamik o‘qiladi). Vektor L2-normalizatsiya qilinadi,
/// shunda euclid masofa to‘g‘ridan-to‘g‘ri taqqoslanadi.
///
/// Interpreter bir marta (lazy) yuklanadi va qayta ishlatiladi — og‘ir resurs.
class FaceEmbedderService {
  FaceEmbedderService();

  Interpreter? _interpreter;
  int _inputSize = 112;
  int _embeddingSize = 192;

  static const _assetPath = 'assets/models/mobilefacenet.tflite';

  Future<void> _ensureLoaded() async {
    if (_interpreter != null) return;
    final interpreter = await Interpreter.fromAsset(_assetPath);
    final inShape = interpreter.getInputTensor(0).shape; // [1, H, W, 3]
    final outShape = interpreter.getOutputTensor(0).shape; // [1, N]
    if (inShape.length == 4) _inputSize = inShape[1];
    if (outShape.length == 2) _embeddingSize = outShape[1];
    _interpreter = interpreter;
  }

  /// Berilgan yuz tasviridan (allaqachon kesilgan/yaxshilangan) L2-normalizatsiya
  /// qilingan embedding qaytaradi.
  Future<List<double>> embed(img.Image faceCrop) async {
    await _ensureLoaded();
    final resized = img.copyResize(
      faceCrop,
      width: _inputSize,
      height: _inputSize,
    );
    final input = _toInputTensor(resized);
    final output = List.generate(
      1,
      (_) => List<double>.filled(_embeddingSize, 0),
    );
    _interpreter!.run(input, output);
    return _l2Normalize(output.first);
  }

  /// `[1, size, size, 3]` float tensor, `[-1, 1]` normalizatsiya.
  List<List<List<List<double>>>> _toInputTensor(img.Image image) {
    return [
      List.generate(_inputSize, (y) {
        return List.generate(_inputSize, (x) {
          final px = image.getPixel(x, y);
          return [
            (px.r - 127.5) / 128.0,
            (px.g - 127.5) / 128.0,
            (px.b - 127.5) / 128.0,
          ];
        });
      }),
    ];
  }

  List<double> _l2Normalize(List<double> v) {
    var sum = 0.0;
    for (final e in v) {
      sum += e * e;
    }
    final norm = math.sqrt(sum);
    if (norm == 0) return v;
    return [for (final e in v) e / norm];
  }

  /// Ikki L2-normalizatsiya qilingan embedding orasidagi euclid masofa.
  static double euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) return double.infinity;
    var sum = 0.0;
    for (var i = 0; i < a.length; i++) {
      final d = a[i] - b[i];
      sum += d * d;
    }
    return math.sqrt(sum);
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}

/// `Uint8List` baytlardan `img.Image` dekod qiladi (null bo‘lsa `null`).
img.Image? decodeImageBytes(Uint8List bytes) => img.decodeImage(bytes);
