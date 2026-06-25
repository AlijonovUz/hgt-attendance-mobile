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
    this.regionName,
    this.districtName,
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
  final String? regionName;
  final String? districtName;
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

    // Viloyat/Tuman backend’da `branch_info` ichida keladi (top-level emas);
    // boshqa endpointlar uchun top-level fallback ham qoldiramiz.
    final branch = src['branch_info'];
    final branchMap = branch is Map ? branch.cast<String, dynamic>() : null;
    // Geozona moslashtirish uchun branch UUID — `branch_info.id` yoki top-level
    // `branch` (geozones endpoint’dagi `branch` maydoniga teng).
    final branchId = asString(branchMap?['id']) ?? asString(src['branch']);

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
      branchName: nestedName(branch),
      branchId: branchId,
      regionName: nestedName(branchMap?['region_info']) ??
          nestedName(src['region_info']),
      districtName: nestedName(branchMap?['district_info']) ??
          nestedName(src['district_info']),
      schedule: schedule,
      kpi: kpi,
    );
  }

  /// Entity → model (offline keshga yozish uchun).
  factory ProfileModel.fromEntity(Profile p) => ProfileModel(
        id: p.id,
        fullName: p.fullName,
        phone: p.phone,
        faceImage: p.faceImage,
        roleName: p.roleName,
        departmentName: p.departmentName,
        branchName: p.branchName,
        branchId: p.branchId,
        regionName: p.regionName,
        districtName: p.districtName,
        schedule: p.schedule,
        kpi: p.kpi,
      );

  /// Backend shakliga mos JSON — shu sabab [ProfileModel.fromJson] uni qaytadan
  /// to‘g‘ri parslaydi (kesh round-trip’i bitta parser bilan).
  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'phone': phone,
        'face_image': faceImage,
        if (roleName != null) 'role_info': {'name': roleName},
        if (departmentName != null) 'department_info': {'name': departmentName},
        'branch_info': {
          'name': branchName,
          'id': branchId,
          if (regionName != null) 'region_info': {'name': regionName},
          if (districtName != null) 'district_info': {'name': districtName},
        },
        if (schedule != null)
          'schedule_info': {
            'name': schedule!.name,
            'work_start_time': schedule!.workStartTime,
            'work_end_time': schedule!.workEndTime,
            'lunch_start_time': schedule!.lunchStartTime,
            'lunch_end_time': schedule!.lunchEndTime,
          },
        if (kpi != null)
          'current_month_kpi': {
            'attendance_kpi': kpi!.attendanceKpi,
            'monthly_kpi': kpi!.monthlyKpi,
            'total_score': kpi!.totalScore,
            'rating_category': kpi!.ratingCategory,
            'monthly_attendance': kpi!.monthlyAttendance,
          },
      };

  Profile toEntity() => Profile(
    id: id,
    fullName: fullName,
    phone: phone,
    faceImage: faceImage,
    roleName: roleName,
    departmentName: departmentName,
    branchName: branchName,
    branchId: branchId,
    regionName: regionName,
    districtName: districtName,
    schedule: schedule,
    kpi: kpi,
  );
}
