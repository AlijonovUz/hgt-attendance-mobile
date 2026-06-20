import 'dart:math' as math;

/// Yer radiusi (metr) — haversine uchun.
const double _earthRadiusMeters = 6371000;

/// Ikki koordinata orasidagi masofa (metr) — haversine formulasi.
///
/// Davomat geofence tekshiruvida ishlatiladi: foydalanuvchi ish hududi
/// (geozone markazi) radiusi ichidami yoki yo‘q.
double haversineMeters(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  final phi1 = _toRadians(lat1);
  final phi2 = _toRadians(lat2);
  final dPhi = _toRadians(lat2 - lat1);
  final dLambda = _toRadians(lon2 - lon1);

  final a = math.pow(math.sin(dPhi / 2), 2) +
      math.cos(phi1) * math.cos(phi2) * math.pow(math.sin(dLambda / 2), 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return _earthRadiusMeters * c;
}

double _toRadians(double degrees) => degrees * math.pi / 180;
