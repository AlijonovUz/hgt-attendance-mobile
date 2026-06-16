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
/// [schedule] va [kpi] — asosiy ekran jadvali/halqasi/statistikasi manbai.
class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.fullName,
    this.phone,
    this.faceImage,
    this.roleName,
    this.departmentName,
    this.branchName,
    this.schedule,
    this.kpi,
  });

  final String id;
  final String fullName;
  final String? phone;

  /// Profil rasmi (URI). `null`/bo‘sh → rasm hali yuklanmagan.
  final String? faceImage;

  final String? roleName;
  final String? departmentName;
  final String? branchName;

  final ScheduleInfo? schedule;
  final MonthKpi? kpi;

  /// Profil rasmi mavjudligi — modal so‘rovni shu hal qiladi.
  bool get hasFaceImage => faceImage != null && faceImage!.trim().isNotEmpty;

  Profile copyWith({String? faceImage}) => Profile(
    id: id,
    fullName: fullName,
    phone: phone,
    faceImage: faceImage ?? this.faceImage,
    roleName: roleName,
    departmentName: departmentName,
    branchName: branchName,
    schedule: schedule,
    kpi: kpi,
  );

  @override
  List<Object?> get props => [
    id,
    fullName,
    phone,
    faceImage,
    roleName,
    departmentName,
    branchName,
    schedule,
    kpi,
  ];
}
