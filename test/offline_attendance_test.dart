import 'package:flutter_test/flutter_test.dart';
import 'package:hgt_attendance_mobile/core/services/geofence_service.dart';
import 'package:hgt_attendance_mobile/core/services/hmac_signer.dart';
import 'package:hgt_attendance_mobile/features/attendance/domain/entities/geozone.dart';

void main() {
  group('GeofenceService.haversineMeters', () {
    const geo = GeofenceService();

    test('same point is zero distance', () {
      expect(geo.haversineMeters(41.3, 69.3, 41.3, 69.3), closeTo(0, 0.001));
    });

    test('known short distance (~111m per 0.001 lat)', () {
      // 0.001° kenglik ≈ 111.2 m.
      final d = geo.haversineMeters(41.0, 69.0, 41.001, 69.0);
      expect(d, closeTo(111.2, 1.0));
    });

    test('isInside true within radius, false outside', () {
      const zone = Geozone(
        id: '1',
        name: 'Filial',
        latitude: 41.2961350,
        longitude: 69.3494880,
        radius: 500,
        branch: 'b1',
      );
      // ~111 m shimolda — 500 m radius ichida.
      expect(
        geo.isInside(latitude: 41.2971350, longitude: 69.3494880, zone: zone),
        isTrue,
      );
      // ~1.1 km uzoqda — tashqarida.
      expect(
        geo.isInside(latitude: 41.3061350, longitude: 69.3494880, zone: zone),
        isFalse,
      );
    });
  });

  group('HmacSigner', () {
    const signer = HmacSigner();

    test('deterministic lowercase hex, 64 chars (sha256)', () {
      final sig = signer.sign('2026-06-17T08:30:00+05:00', 'secret-key');
      expect(sig.length, 64);
      expect(sig, sig.toLowerCase());
      // Determinizm — bir xil kirish, bir xil chiqish.
      expect(signer.sign('2026-06-17T08:30:00+05:00', 'secret-key'), sig);
    });

    test('different secret → different signature', () {
      final a = signer.sign('2026-06-17T08:30:00+05:00', 'k1');
      final b = signer.sign('2026-06-17T08:30:00+05:00', 'k2');
      expect(a, isNot(b));
    });

    test('formatLocalIso includes offset and seconds', () {
      final iso = HmacSigner.formatLocalIso(
        DateTime(2026, 6, 17, 8, 30, 15),
      );
      // `2026-06-17T08:30:15±HH:MM` — offset bilan tugaydi.
      expect(
        RegExp(r'^2026-06-17T08:30:15[+-]\d{2}:\d{2}$').hasMatch(iso),
        isTrue,
        reason: iso,
      );
    });
  });
}
