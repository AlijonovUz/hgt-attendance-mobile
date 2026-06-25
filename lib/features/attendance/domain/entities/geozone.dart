import 'package:equatable/equatable.dart';

/// Filial geofence zonasi (`/v1/attendance/geozones/`).
///
/// Markaz ([latitude]/[longitude]) + [radius] (metr). Offline davomatda xodim
/// shu doira ichida (haversine masofa ≤ radius) bo‘lsagina yozuv saqlanadi.
/// [branch] — filial UUID; profil `branchId`siga solishtiriladi.
class Geozone extends Equatable {
  const Geozone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.branch,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;

  /// Radius (metr).
  final double radius;

  /// Filial UUID.
  final String branch;

  @override
  List<Object?> get props => [id, name, latitude, longitude, radius, branch];
}
