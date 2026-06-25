import '../../domain/entities/attendance_event.dart';
import '../../domain/entities/attendance_event_type.dart';

/// GET `/v1/attendance/attendance/` `results[]` elementini parslaydi.
class AttendanceEventModel {
  const AttendanceEventModel({
    required this.eventType,
    required this.createdAt,
    required this.faceVerify,
  });

  final AttendanceEventType? eventType;
  final DateTime createdAt;
  final bool faceVerify;

  factory AttendanceEventModel.fromJson(Map<String, dynamic> json) {
    return AttendanceEventModel(
      eventType: AttendanceEventType.fromApi(json['event_type'] as String?),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      faceVerify: json['face_verify'] == true,
    );
  }

  /// Entity → model (offline keshga yozish uchun).
  factory AttendanceEventModel.fromEntity(AttendanceEvent e) =>
      AttendanceEventModel(
        eventType: e.eventType,
        createdAt: e.createdAt,
        faceVerify: e.faceVerify,
      );

  /// [AttendanceEventModel.fromJson] qaytadan parslaydigan JSON.
  Map<String, dynamic> toJson() => {
        'event_type': eventType?.apiValue,
        'created_at': createdAt.toUtc().toIso8601String(),
        'face_verify': faceVerify,
      };

  AttendanceEvent toEntity() => AttendanceEvent(
    eventType: eventType,
    createdAt: createdAt,
    faceVerify: faceVerify,
  );
}
