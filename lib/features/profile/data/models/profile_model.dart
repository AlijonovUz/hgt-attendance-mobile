import '../../domain/entities/profile.dart';

/// `/v1/users/auth/profile/` javobini parslaydi.
///
/// Backend xom obyekt (`{ id, full_name, face_image, ... }`) yoki konvert
/// (`{ data: {...}, success }`) qaytarishi mumkin — ikkalasini ham qo‘llaymiz.
/// Ichki obyektlar (`role_info`, `branch_info`) `name` maydonidan o‘qiladi;
/// `schedule_info` va `current_month_kpi` to‘liq parslanadi.
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.fullName,
    this.phone,
    this.faceImage,
    this.roleName,
    this.departmentName,
    this.branchName,
    this.branchId,
    this.schedule,
    this.kpi,
  });

  final String id;
  final String fullName;
  final String? phone;
  final String? faceImage;
  final String? roleName;
  final String? departmentName;
  final String? branchName;
  final String? branchId;
  final ScheduleInfo? schedule;
  final MonthKpi? kpi;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final src = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;

    String? nestedName(Object? node) {
      if (node is Map && node['name'] is String) return node['name'] as String;
      return null;
    }

    String? nestedId(Object? node) {
      if (node is Map && node['id'] != null) {
        final s = node['id'].toString().trim();
        return s.isEmpty ? null : s;
      }
      return null;
    }

    String? asString(Object? v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    double asDouble(Object? v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    ScheduleInfo? schedule;
    final sc = src['schedule_info'];
    if (sc is Map) {
      final m = sc.cast<String, dynamic>();
      schedule = ScheduleInfo(
        name: asString(m['name']),
        workStartTime: asString(m['work_start_time']),
        workEndTime: asString(m['work_end_time']),
        lunchStartTime: asString(m['lunch_start_time']),
        lunchEndTime: asString(m['lunch_end_time']),
      );
    }

    MonthKpi? kpi;
    final k = src['current_month_kpi'];
    if (k is Map) {
      final m = k.cast<String, dynamic>();
      kpi = MonthKpi(
        attendanceKpi: asDouble(m['attendance_kpi']),
        monthlyKpi: asDouble(m['monthly_kpi']),
        totalScore: asDouble(m['total_score']),
        ratingCategory: asString(m['rating_category']),
        monthlyAttendance: asString(m['monthly_attendance']) ?? '0/0',
      );
    }

    return ProfileModel(
      id: asString(src['id']) ?? '',
      fullName: asString(src['full_name']) ?? '',
      phone: asString(src['phone']),
      faceImage: asString(src['face_image']),
      roleName:
          nestedName(src['role_info']) ?? nestedName(src['position_info']),
      departmentName: nestedName(src['department_info']),
      branchName: nestedName(src['branch_info']),
      branchId: nestedId(src['branch_info']),
      schedule: schedule,
      kpi: kpi,
    );
  }

  Profile toEntity() => Profile(
    id: id,
    fullName: fullName,
    phone: phone,
    faceImage: faceImage,
    roleName: roleName,
    departmentName: departmentName,
    branchName: branchName,
    branchId: branchId,
    schedule: schedule,
    kpi: kpi,
  );
}
