import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:hgt_attendance_mobile/core/services/face_embedder_service.dart';

/// Yuz moslik QARORI cosine o‘xshashlikka tayanadi. Bu test sof matematikani
/// (native tflite/ML Kit’siz, host VM’da) qulflaydi: bir xil embedding → 1.0,
/// ortogonal → 0, qarama-qarshi → -1; euclid masofa mosligi.
void main() {
  List<double> l2(List<double> v) {
    final n = math.sqrt(v.fold<double>(0, (s, e) => s + e * e));
    return n == 0 ? v : [for (final e in v) e / n];
  }

  group('FaceEmbedderService.cosineSimilarity', () {
    test('bir xil vektor → 1.0', () {
      final a = l2([0.2, 0.5, 0.1, 0.8]);
      expect(FaceEmbedderService.cosineSimilarity(a, a), closeTo(1.0, 1e-9));
    });

    test('ortogonal vektor → 0', () {
      final a = l2([1, 0, 0, 0]);
      final b = l2([0, 1, 0, 0]);
      expect(FaceEmbedderService.cosineSimilarity(a, b), closeTo(0.0, 1e-9));
    });

    test('qarama-qarshi vektor → -1', () {
      final a = l2([0.3, 0.4, 0.5, 0.1]);
      final b = [for (final e in a) -e];
      expect(FaceEmbedderService.cosineSimilarity(a, b), closeTo(-1.0, 1e-9));
    });

    test('uzunlik teng emas → -1 (xavfsiz default)', () {
      expect(FaceEmbedderService.cosineSimilarity([1, 0], [1, 0, 0]), -1);
    });
  });

  group('FaceEmbedderService.euclideanDistance', () {
    test('bir xil vektor → 0', () {
      final a = l2([0.2, 0.5, 0.1, 0.8]);
      expect(FaceEmbedderService.euclideanDistance(a, a), closeTo(0.0, 1e-9));
    });

    test('qarama-qarshi normalizatsiya qilingan vektor → 2', () {
      final a = l2([0.3, 0.4, 0.5, 0.1]);
      final b = [for (final e in a) -e];
      expect(FaceEmbedderService.euclideanDistance(a, b), closeTo(2.0, 1e-9));
    });

    test('uzunlik teng emas → infinity', () {
      expect(
        FaceEmbedderService.euclideanDistance([1, 0], [1, 0, 0]),
        double.infinity,
      );
    });
  });
}
