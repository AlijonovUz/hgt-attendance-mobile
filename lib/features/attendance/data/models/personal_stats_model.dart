import '../../domain/entities/attendance_stats.dart';

/// `personal-stats/` javobini parslaydi. Konvert envelope (`{data:{...}}`) ham,
/// to‘g‘ridan-to‘g‘ri obyekt ham qo‘llab-quvvatlanadi.
class PersonalStatsModel {
  const PersonalStatsModel({
    required this.presentDays,
    required this.lateDays,
    required this.avgCheckIn,
    required this.totalWorkedHours,
  });

  final int presentDays;
  final int lateDays;
  final String avgCheckIn;
  final int totalWorkedHours;

  factory PersonalStatsModel.fromJson(Map<String, dynamic> json) {
    final src = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;

    int asInt(Object? v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    String asString(Object? v) {
      final s = v?.toString().trim() ?? '';
      return s;
    }

    return PersonalStatsModel(
      presentDays: asInt(src['present_days']),
      lateDays: asInt(src['late_days']),
      avgCheckIn: asString(src['avg_check_in']),
      totalWorkedHours: asInt(src['total_worked_hours']),
    );
  }

  /// Entity → model (offline keshga yozish uchun).
  factory PersonalStatsModel.fromEntity(AttendanceStats s) => PersonalStatsModel(
        presentDays: s.presentDays,
        lateDays: s.lateDays,
        avgCheckIn: s.avgCheckIn,
        totalWorkedHours: s.totalWorkedHours,
      );

  /// [PersonalStatsModel.fromJson] qaytadan parslaydigan JSON.
  Map<String, dynamic> toJson() => {
        'present_days': presentDays,
        'late_days': lateDays,
        'avg_check_in': avgCheckIn,
        'total_worked_hours': totalWorkedHours,
      };

  AttendanceStats toEntity() => AttendanceStats(
    presentDays: presentDays,
    lateDays: lateDays,
    avgCheckIn: avgCheckIn,
    totalWorkedHours: totalWorkedHours,
  );
}
