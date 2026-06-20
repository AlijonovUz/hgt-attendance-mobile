import '../entities/attendance_event.dart';
import '../entities/attendance_event_type.dart';
import '../entities/pending_attendance.dart';

/// Davomat hodisalari (yuborish + bugungilarni olish + offline navbat).
abstract interface class AttendanceRepository {
  /// Selfie + GPS bilan davomat hodisasini belgilaydi (online). Offline
  /// sinxronda [createdAtIso] + [signature] (HMAC) ham yuboriladi. Xatoda
  /// `Failure` otadi.
  Future<void> mark({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    required String imagePath,
    String? createdAtIso,
    String? signature,
  });

  /// Bugungi davomat yozuvlari (joriy foydalanuvchi). Xatoda `Failure` otadi.
  Future<List<AttendanceEvent>> todayEvents({required String userId});

  // ── Offline navbat (lokal, Hive) ─────────────────────────────────────────

  /// Offline belgilangan davomatni navbatga qo‘shadi.
  Future<void> enqueue(PendingAttendance item);

  /// Navbatdagilar FIFO tartibida (`enqueuedAt`).
  List<PendingAttendance> pending();

  /// Navbatdagilar soni.
  int pendingCount();

  /// Sinxron muvaffaqiyatli yoki yaroqsiz (4xx) bo‘lganda navbatdan o‘chiradi.
  Future<void> removePending(String localId);

  /// Sinxron urinishlar sonini oshiradi (retry kuzatuvi).
  Future<void> incrementAttempt(PendingAttendance item);
}
