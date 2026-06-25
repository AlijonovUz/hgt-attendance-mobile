import '../entities/attendance_event.dart';
import '../entities/attendance_event_type.dart';
import '../entities/attendance_stats.dart';

/// Davomat hodisalari (yuborish + bugungilarni olish + tarix).
abstract interface class AttendanceRepository {
  /// Selfie + GPS bilan davomat hodisasini belgilaydi. Xatoda `Failure` otadi.
  /// [createdAt] + [signature] — offline navbatdan yuborishda imzolangan vaqt.
  Future<void> mark({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    required String imagePath,
    String? createdAt,
    String? signature,
  });

  /// Bugungi davomat yozuvlari (joriy foydalanuvchi). Xatoda `Failure` otadi.
  Future<List<AttendanceEvent>> todayEvents({required String userId});

  /// Sana oralig‘idagi yozuvlar (tarix). Xatoda `Failure` otadi.
  Future<List<AttendanceEvent>> rangeEvents({
    required String userId,
    required DateTime start,
    required DateTime end,
  });

  /// Sana oralig‘i bo‘yicha shaxsiy statistika. Xatoda `Failure` otadi.
  Future<AttendanceStats> personalStats({
    required DateTime start,
    required DateTime end,
  });
}
