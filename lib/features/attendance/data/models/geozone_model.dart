import '../../domain/entities/geozone.dart';

/// `/v1/attendance/geozones/` natijasini parslaydi. `latitude`/`longitude`/
/// `radius` backend’da string yoki son kelishi mumkin — ikkalasini ham qabul
/// qiladi. JSON ↔ entity (lokal keshga yozish uchun `toJson` ham bor).
class GeozoneModel {
  const GeozoneModel({
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
  final double radius;
  final String branch;

  static double _asDouble(Object? v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String _asString(Object? v) => v?.toString() ?? '';

  factory GeozoneModel.fromJson(Map<String, dynamic> json) => GeozoneModel(
        id: _asString(json['id']),
        name: _asString(json['name']),
        latitude: _asDouble(json['latitude']),
        longitude: _asDouble(json['longitude']),
        radius: _asDouble(json['radius']),
        branch: _asString(json['branch']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'branch': branch,
      };

  Geozone toEntity() => Geozone(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        branch: branch,
      );

  factory GeozoneModel.fromEntity(Geozone z) => GeozoneModel(
        id: z.id,
        name: z.name,
        latitude: z.latitude,
        longitude: z.longitude,
        radius: z.radius,
        branch: z.branch,
      );
}
