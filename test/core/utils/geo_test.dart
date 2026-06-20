import 'package:flutter_test/flutter_test.dart';
import 'package:hgt_attendance_mobile/core/utils/geo.dart';

void main() {
  group('haversineMeters', () {
    test('bir xil nuqta → 0 metr', () {
      expect(haversineMeters(41.2961, 69.3494, 41.2961, 69.3494), 0);
    });

    test('Toshkent geozone markazidan ~100m → radius (500m) ichida', () {
      // ~0.0009° lat ≈ 100m.
      final d = haversineMeters(41.296135, 69.349488, 41.296935, 69.349488);
      expect(d, greaterThan(80));
      expect(d, lessThan(120));
    });

    test('Toshkent ↔ Farg‘ona filiali → bir necha yuz km', () {
      final d = haversineMeters(41.296135, 69.349488, 40.388040, 71.787730);
      // ~230 km.
      expect(d, greaterThan(200000));
      expect(d, lessThan(260000));
    });

    test('1 daraja kenglik farqi ≈ 111 km', () {
      final d = haversineMeters(0, 0, 1, 0);
      expect(d, closeTo(111195, 500));
    });
  });
}
