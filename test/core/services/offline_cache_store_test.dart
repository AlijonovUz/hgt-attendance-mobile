import 'package:flutter_test/flutter_test.dart';
import 'package:hgt_attendance_mobile/core/services/attendance_cache_store.dart';
import 'package:hgt_attendance_mobile/core/services/profile_cache_store.dart';
import 'package:hgt_attendance_mobile/core/services/storage_service.dart';
import 'package:hgt_attendance_mobile/features/attendance/domain/entities/attendance_event.dart';
import 'package:hgt_attendance_mobile/features/attendance/domain/entities/attendance_event_type.dart';
import 'package:hgt_attendance_mobile/features/attendance/domain/entities/attendance_stats.dart';
import 'package:hgt_attendance_mobile/features/profile/domain/entities/profile.dart';

/// Offline kesh round-trip — `StorageService()` (xotira fallback) bilan host
/// VM’da ishlaydi. Yozilgan ma’lumot teng holда qaytishini qulflaydi.
void main() {
  group('ProfileCacheStore', () {
    test('write → read profilni saqlab qaytaradi', () async {
      final store = ProfileCacheStore(StorageService());
      const profile = Profile(
        id: 'u1',
        fullName: 'Ali Valiyev',
        phone: '+998901112233',
        faceImage: 'https://x/media/a.jpg',
        roleName: 'Dasturchi',
        departmentName: 'IT',
        branchName: 'Bosh ofis',
        branchId: 'b1',
        regionName: 'Toshkent',
        districtName: 'Chilonzor',
        schedule: ScheduleInfo(
          name: 'Standart',
          workStartTime: '09:00:00',
          workEndTime: '18:00:00',
          lunchStartTime: '13:00:00',
          lunchEndTime: '14:00:00',
        ),
        kpi: MonthKpi(
          attendanceKpi: 98.5,
          monthlyKpi: 90,
          totalScore: 188.5,
          ratingCategory: 'A',
          monthlyAttendance: '22/22',
        ),
      );

      await store.write(profile);
      final read = store.read();

      expect(read, isNotNull);
      expect(read!.id, 'u1');
      expect(read.fullName, 'Ali Valiyev');
      expect(read.branchId, 'b1');
      expect(read.regionName, 'Toshkent');
      expect(read.districtName, 'Chilonzor');
      expect(read.schedule?.workStartTime, '09:00:00');
      expect(read.kpi?.attendanceKpi, 98.5);
      expect(read.kpi?.monthlyAttendance, '22/22');
    });

    test('kesh bo‘sh bo‘lsa null', () {
      expect(ProfileCacheStore(StorageService()).read(), isNull);
    });
  });

  group('AttendanceCacheStore', () {
    AttendanceEvent ev(AttendanceEventType t) => AttendanceEvent(
          eventType: t,
          createdAt: DateTime.now().toUtc(),
          faceVerify: true,
        );

    test('today write → read shu user uchun qaytadi', () async {
      final store = AttendanceCacheStore(StorageService());
      final events = [ev(AttendanceEventType.checkIn), ev(AttendanceEventType.lunchStart)];

      await store.writeToday('u1', events);
      final read = store.readToday('u1');

      expect(read, isNotNull);
      expect(read!.length, 2);
      expect(read.first.eventType, AttendanceEventType.checkIn);
      expect(read.first.faceVerify, isTrue);
    });

    test('today boshqa user uchun null', () async {
      final store = AttendanceCacheStore(StorageService());
      await store.writeToday('u1', [ev(AttendanceEventType.checkIn)]);
      expect(store.readToday('u2'), isNull);
    });

    test('personal stats write → read', () async {
      final store = AttendanceCacheStore(StorageService());
      final start = DateTime(2026, 6, 1);
      final end = DateTime(2026, 6, 30);
      const stats = AttendanceStats(
        presentDays: 20,
        lateDays: 2,
        avgCheckIn: '09:05',
        totalWorkedHours: 160,
      );

      await store.writePersonalStats(start, end, stats);
      final read = store.readPersonalStats(start, end);

      expect(read, isNotNull);
      expect(read!.presentDays, 20);
      expect(read.lateDays, 2);
      expect(read.avgCheckIn, '09:05');
      expect(read.totalWorkedHours, 160);
      // Boshqa oraliq → null.
      expect(
        store.readPersonalStats(DateTime(2026, 5, 1), DateTime(2026, 5, 31)),
        isNull,
      );
    });
  });
}
