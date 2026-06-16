import '../../../attendance/domain/entities/attendance_event_type.dart';
import '../../../profile/domain/entities/profile.dart';

/// Kunlik davomat belgilash bosqichlari (navbat bilan suriladi).
enum AttendanceStep { arrive, lunchOut, lunchIn, leave, done }

/// To‘liq tartib (schedule’dagi mavjud vaqtlarga qarab filtrlanadi).
const List<AttendanceStep> kAllSteps = [
  AttendanceStep.arrive,
  AttendanceStep.lunchOut,
  AttendanceStep.lunchIn,
  AttendanceStep.leave,
];

extension AttendanceStepX on AttendanceStep {
  /// Backendga yuboriladigan hodisa turi.
  AttendanceEventType get eventType => switch (this) {
    AttendanceStep.arrive => AttendanceEventType.checkIn,
    AttendanceStep.lunchOut => AttendanceEventType.lunchStart,
    AttendanceStep.lunchIn => AttendanceEventType.lunchEnd,
    AttendanceStep.leave => AttendanceEventType.checkOut,
    AttendanceStep.done => AttendanceEventType.checkOut,
  };

  /// Shu bosqichga mos belgilangan (schedule) vaqt — null bo‘lsa bosqich yo‘q.
  String? scheduleTime(ScheduleInfo? s) => switch (this) {
    AttendanceStep.arrive => s?.workStartTime,
    AttendanceStep.lunchOut => s?.lunchStartTime,
    AttendanceStep.lunchIn => s?.lunchEndTime,
    AttendanceStep.leave => s?.workEndTime,
    AttendanceStep.done => null,
  };
}

/// Backend hodisa turidan bosqich (mos kelmasa `null`).
AttendanceStep? stepForEventType(AttendanceEventType? type) => switch (type) {
  AttendanceEventType.checkIn => AttendanceStep.arrive,
  AttendanceEventType.lunchStart => AttendanceStep.lunchOut,
  AttendanceEventType.lunchEnd => AttendanceStep.lunchIn,
  AttendanceEventType.checkOut => AttendanceStep.leave,
  null => null,
};

/// Schedule’da vaqti mavjud bo‘lgan bosqichlar (null vaqt → o‘tkazib yuboriladi;
/// masalan tushlik vaqtlari yo‘q → `[arrive, leave]`).
List<AttendanceStep> activeStepsFromSchedule(ScheduleInfo? schedule) {
  final steps = kAllSteps
      .where((s) => (s.scheduleTime(schedule) ?? '').isNotEmpty)
      .toList();
  // Schedule kelmagan/bo‘sh holatda ham hech bo‘lmasa kelish/ketish ko‘rinsin.
  return steps.isEmpty
      ? const [AttendanceStep.arrive, AttendanceStep.leave]
      : steps;
}
