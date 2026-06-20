import '../../domain/entities/attendance_event_type.dart';
import '../../domain/entities/pending_attendance.dart';

/// [PendingAttendance]ni Hive `Box<String>`da saqlash uchun JSON Map ↔ entity
/// konvertori (`hive_generator` `flutter_gen_runner` bilan to‘qnashgani uchun
/// TypeAdapter ishlatilmaydi — `jsonEncode`/`jsonDecode`).
abstract final class PendingAttendanceMapper {
  static Map<String, dynamic> toJson(PendingAttendance p) => {
        'localId': p.localId,
        'eventType': p.eventType.apiValue,
        'latitude': p.latitude,
        'longitude': p.longitude,
        'createdAtIso': p.createdAtIso,
        'signature': p.signature,
        'imagePath': p.imagePath,
        'enqueuedAt': p.enqueuedAt.toIso8601String(),
        'attempts': p.attempts,
      };

  static PendingAttendance fromJson(Map<String, dynamic> json) {
    double asDouble(Object? v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

    return PendingAttendance(
      localId: json['localId']?.toString() ?? '',
      eventType: AttendanceEventType.fromApi(json['eventType']?.toString()) ??
          AttendanceEventType.checkIn,
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
      createdAtIso: json['createdAtIso']?.toString() ?? '',
      signature: json['signature']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      enqueuedAt:
          DateTime.tryParse(json['enqueuedAt']?.toString() ?? '') ??
              DateTime.now(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    );
  }
}
