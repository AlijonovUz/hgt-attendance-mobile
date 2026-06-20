import 'package:flutter_test/flutter_test.dart';
import 'package:hgt_attendance_mobile/core/utils/attendance_signature.dart';

void main() {
  group('signCreatedAt', () {
    const secret = 'a1b2c3d4e5f6g7h8';
    const time = '2026-06-17T08:30:00+05:00';

    test('determenistik — bir xil kirish bir xil imzo', () {
      expect(signCreatedAt(time, secret), signCreatedAt(time, secret));
    });

    test('lowercase hex, 64 belgili (sha256)', () {
      final sig = signCreatedAt(time, secret);
      expect(sig, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('vaqt o‘zgarsa imzo o‘zgaradi', () {
      final a = signCreatedAt(time, secret);
      final b = signCreatedAt('2026-06-17T08:31:00+05:00', secret);
      expect(a, isNot(b));
    });

    test('kalit o‘zgarsa imzo o‘zgaradi', () {
      final a = signCreatedAt(time, secret);
      final b = signCreatedAt(time, 'boshqa-kalit');
      expect(a, isNot(b));
    });

    test('ma’lum vektor — HMAC-SHA256 mosligi', () {
      // python: hmac.new(secret, time, sha256).hexdigest()
      expect(
        signCreatedAt(time, secret),
        '0a35f45c9ead14250417ad1d06ad7043256acd0723f0e3f25f8b87258a5c59e0',
      );
    });
  });
}
