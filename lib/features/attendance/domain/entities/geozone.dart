import 'package:equatable/equatable.dart';

import '../../../../core/utils/geo.dart';

/// Ish hududi (geozone) — `GET /v1/attendance/geozones/` natijasi.
///
/// Profildagi `branchId`ga mos geozone topilib lokalga cache qilinadi; offline
/// davomatda foydalanuvchi shu markaz [radius] (metr) ichidami — [contains]
/// haversine masofa orqali tekshiradi.
class Geozone extends Equatable {
  const Geozone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.branchId,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;

  /// Ruxsat etilgan radius (metr).
  final double radius;

  /// Tegishli filial ID’si (profile `branch_info.id` bilan moslanadi).
  final String branchId;

  /// Berilgan koordinata geozone radiusi ichidami.
  bool contains(double lat, double lng) =>
      haversineMeters(latitude, longitude, lat, lng) <= radius;

  @override
  List<Object?> get props => [id, name, latitude, longitude, radius, branchId];
}
