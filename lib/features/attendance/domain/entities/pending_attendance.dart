import 'package:equatable/equatable.dart';

import 'attendance_event_type.dart';

/// Offline belgilangan, sinxron kutayotgan davomat yozuvi (lokal navbat).
///
/// [createdAtIso] — swipe momentidagi lokal vaqt ISO 8601 + timezone offset
/// (imzolangan, verbatim saqlanadi). [signature] — `HMAC_SHA256(createdAtIso,
/// offlineSecret)`. Internet tiklanganda ikkalasi GPS + selfie bilan birga
/// `POST attendance`ga yuboriladi.
class PendingAttendance extends Equatable {
  const PendingAttendance({
    required this.localId,
    required this.eventType,
    required this.latitude,
    required this.longitude,
    required this.createdAtIso,
    required this.signature,
    required this.imagePath,
    required this.enqueuedAt,
    this.attempts = 0,
  });

  /// Lokal noyob ID (Hive kaliti, uuid).
  final String localId;
  final AttendanceEventType eventType;
  final double latitude;
  final double longitude;

  /// Imzolangan vaqt (lokal ISO 8601 + offset) — backendga `created_at`.
  final String createdAtIso;

  /// HMAC-SHA256 imzo (lowercase hex) — backendga `signature`.
  final String signature;

  /// Selfie fayl yo‘li (app docs katalogidagi nusxa).
  final String imagePath;

  /// Navbatga qo‘shilgan vaqt (FIFO tartib + 24h eskirish tekshiruvi).
  final DateTime enqueuedAt;

  /// Sinxron urinishlar soni.
  final int attempts;

  PendingAttendance copyWith({int? attempts}) => PendingAttendance(
        localId: localId,
        eventType: eventType,
        latitude: latitude,
        longitude: longitude,
        createdAtIso: createdAtIso,
        signature: signature,
        imagePath: imagePath,
        enqueuedAt: enqueuedAt,
        attempts: attempts ?? this.attempts,
      );

  @override
  List<Object?> get props => [
        localId,
        eventType,
        latitude,
        longitude,
        createdAtIso,
        signature,
        imagePath,
        enqueuedAt,
        attempts,
      ];
}
