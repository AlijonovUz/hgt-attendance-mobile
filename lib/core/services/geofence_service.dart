import 'dart:math' as math;

import '../../features/attendance/domain/entities/geozone.dart';

/// Geofence hisob-kitoblari — ikki nuqta orasidagi masofa (haversine) va
/// nuqtaning zona ichidaligini tekshirish. Sof Dart, holatsiz → oson test
/// qilinadi. Offline davomatda yozuvni saqlashdan oldin ishlatiladi.
class GeofenceService {
  const GeofenceService();

  /// Yer radiusi (metr).
  static const double earthRadius = 6371000;

  /// Ikki koordinata orasidagi masofa (metr). Foydalanuvchi bergan Python
  /// `haversine` formulasining aynan ko‘chirmasi.
  double haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final phi1 = _rad(lat1);
    final phi2 = _rad(lat2);
    final dPhi = _rad(lat2 - lat1);
    final dLambda = _rad(lon2 - lon1);
    final a = math.pow(math.sin(dPhi / 2), 2) +
        math.cos(phi1) * math.cos(phi2) * math.pow(math.sin(dLambda / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Nuqta zona doirasi ichidami (masofa ≤ radius).
  bool isInside({
    required double latitude,
    required double longitude,
    required Geozone zone,
  }) {
    final distance = haversineMeters(
      latitude,
      longitude,
      zone.latitude,
      zone.longitude,
    );
    return distance <= zone.radius;
  }

  double _rad(double deg) => deg * math.pi / 180;
}
