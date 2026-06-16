import '../entities/attendance_event.dart';
import '../entities/attendance_event_type.dart';

/// Davomat hodisalari (yuborish + bugungilarni olish).
abstract interface class AttendanceRepository {
  /// Selfie + GPS bilan davomat hodisasini belgilaydi. Xatoda `Failure` otadi.
  Future<void> mark({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    required String imagePath,
  });

  /// Bugungi davomat yozuvlari (joriy foydalanuvchi). Xatoda `Failure` otadi.
  Future<List<AttendanceEvent>> todayEvents({required String userId});
}
