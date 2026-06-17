import 'package:equatable/equatable.dart';

import 'attendance_event_type.dart';

/// Bitta davomat yozuvi (GET `/v1/attendance/attendance/` natijasi).
class AttendanceEvent extends Equatable {
  const AttendanceEvent({
    required this.eventType,
    required this.createdAt,
    required this.faceVerify,
  });

  /// Hodisa turi (noma’lum/yangi tur bo‘lsa `null`).
  final AttendanceEventType? eventType;

  /// Server yozgan vaqt (UTC). UI’da lokal vaqtga o‘giriladi.
  final DateTime createdAt;

  /// Yuz tekshiruvidan o‘tgan-o‘tmagani.
  final bool faceVerify;

  @override
  List<Object?> get props => [eventType, createdAt, faceVerify];
}
