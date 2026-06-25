import 'package:equatable/equatable.dart';

/// Ish jadvali (Figma «Bugungi tartib» + halqa sanagichi uchun manba).
///
/// Vaqtlar "HH:MM:SS" ko‘rinishida yoki `null` (mos qator UI’da yashiriladi).
class ScheduleInfo extends Equatable {
  const ScheduleInfo({
    this.name,
    this.workStartTime,
    this.workEndTime,
    this.lunchStartTime,
    this.lunchEndTime,
  });

  final String? name;
  final String? workStartTime;
  final String? workEndTime;
  final String? lunchStartTime;
  final String? lunchEndTime;

  @override
  List<Object?> get props => [
    name,
    workStartTime,
    workEndTime,
    lunchStartTime,
    lunchEndTime,
  ];
}

/// Joriy oy KPI ko‘rsatkichlari (statistika kartalari uchun).
class MonthKpi extends Equatable {
  const MonthKpi({
    this.attendanceKpi = 0,
    this.monthlyKpi = 0,
    this.totalScore = 0,
    this.ratingCategory,
    this.monthlyAttendance = '0/0',
  });

  final double attendanceKpi;
  final double monthlyKpi;
  final double totalScore;
  final String? ratingCategory;

  /// «keldi/jami» ko‘rinishi, masalan "23/22".
  final String monthlyAttendance;

  @override
  List<Object?> get props => [
    attendanceKpi,
    monthlyKpi,
    totalScore,
    ratingCategory,
    monthlyAttendance,
  ];
}

/// Joriy foydalanuvchi profili (GET `/v1/users/auth/profile/`).
///
/// [faceImage] — profil/yuz rasmi URL’i; bo‘sh bo‘lsa rasm o‘rnatish so‘raladi.
/// [localFaceImagePath] — qurilma xotirasiga (path_provider docs dir) baytlar
/// shaklida saqlangan nusxa yo‘li. Offline yuz tasdig‘i va internet yo‘qligida
/// avatar render qilish uchun ishlatiladi.
/// [schedule] va [kpi] — asosiy ekran jadvali/halqasi/statistikasi manbai.
class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.fullName,
    this.phone,
    this.faceImage,
    this.localFaceImagePath,
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

  /// Profil rasmi (URI). `null`/bo‘sh → rasm hali yuklanmagan.
  final String? faceImage;

  /// Lokal fayl yo‘li (`<docs>/face_images/<id>.jpg`) — bayt-bayt yuklab
  /// olingan nusxa. `null` → hali keshlanmagan.
  final String? localFaceImagePath;

  final String? roleName;
  final String? departmentName;
  final String? branchName;

  /// Filial UUID (`branch_info.id`) — geozona moslashtirish kaliti (offline
  /// geofence uchun `/v1/attendance/geozones/` `branch` maydoniga solishtiriladi).
  final String? branchId;

  /// Viloyat (`region_info.name`).
  final String? regionName;

  /// Tuman (`district_info.name`).
  final String? districtName;

  final ScheduleInfo? schedule;
  final MonthKpi? kpi;

  /// Profil rasmi mavjudligi — modal so‘rovni shu hal qiladi.
  /// Lokal kesh ham yetarli (offline holatda URL bo‘sh, lekin fayl mavjud).
  bool get hasFaceImage =>
      (faceImage != null && faceImage!.trim().isNotEmpty) ||
      (localFaceImagePath != null && localFaceImagePath!.trim().isNotEmpty);

  Profile copyWith({String? faceImage, String? localFaceImagePath}) => Profile(
    id: id,
    fullName: fullName,
    phone: phone,
    faceImage: faceImage ?? this.faceImage,
    localFaceImagePath: localFaceImagePath ?? this.localFaceImagePath,
    roleName: roleName,
    departmentName: departmentName,
    branchName: branchName,
    branchId: branchId,
    regionName: regionName,
    districtName: districtName,
    schedule: schedule,
    kpi: kpi,
  );

  @override
  List<Object?> get props => [
    id,
    fullName,
    phone,
    faceImage,
    localFaceImagePath,
    roleName,
    departmentName,
    branchName,
    branchId,
    regionName,
    districtName,
    schedule,
    kpi,
  ];
}
