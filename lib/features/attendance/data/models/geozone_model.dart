import '../../domain/entities/geozone.dart';

/// `GET /v1/attendance/geozones/` natijasini parslaydi.
///
/// Konvert (`{data: {results:[...]}, success}`) yoki to‘g‘ridan-to‘g‘ri ro‘yxat
/// — ikkalasini ham qo‘llaydi (profil/attendance modellaridagi pattern).
class GeozoneModel {
  const GeozoneModel({
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
  final double radius;
  final String branchId;

  factory GeozoneModel.fromJson(Map<String, dynamic> json) {
    double asDouble(Object? v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    String asString(Object? v) => v?.toString().trim() ?? '';

    return GeozoneModel(
      id: asString(json['id']),
      name: asString(json['name']),
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
      radius: asDouble(json['radius']),
      branchId: asString(json['branch']),
    );
  }

  /// Xom javobdan geozone ro‘yxatini ajratadi (envelope-tolerant).
  static List<GeozoneModel> listFromResponse(Object? raw) {
    final body = raw is Map ? raw.cast<String, dynamic>() : const <String, dynamic>{};
    final inner = body['data'] is Map
        ? (body['data'] as Map).cast<String, dynamic>()
        : body;
    final List list = inner['results'] is List
        ? inner['results'] as List
        : (raw is List ? raw : const []);
    return list
        .whereType<Map>()
        .map((e) => GeozoneModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Geozone toEntity() => Geozone(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        branchId: branchId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'branch': branchId,
      };
}
