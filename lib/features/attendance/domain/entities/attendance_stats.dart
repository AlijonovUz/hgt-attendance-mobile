import 'package:equatable/equatable.dart';

/// Sana oralig‘i bo‘yicha shaxsiy davomat statistikasi
/// (`GET /v1/attendance/attendance/personal-stats/`).
///
/// «Davomat tarixi» (Haftalik/Oylik/Custom) yuqorisidagi 4 ta karta manbai.
class AttendanceStats extends Equatable {
  const AttendanceStats({
    required this.presentDays,
    required this.lateDays,
    required this.avgCheckIn,
    required this.totalWorkedHours,
  });

  /// Ishga chiqqan kunlar.
  final int presentDays;

  /// Ishga kechikkan kunlar.
  final int lateDays;

  /// O‘rtacha kelish vaqti ("HH:MM" yoki bo‘sh).
  final String avgCheckIn;

  /// Jami ishlagan soat.
  final int totalWorkedHours;

  @override
  List<Object?> get props => [
    presentDays,
    lateDays,
    avgCheckIn,
    totalWorkedHours,
  ];
}
