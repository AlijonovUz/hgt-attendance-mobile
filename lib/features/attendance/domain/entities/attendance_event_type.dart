/// Davomat hodisasi turi — backend `event_type` qiymatlari.
enum AttendanceEventType {
  checkIn('check_in'),
  lunchStart('lunch_start'),
  lunchEnd('lunch_end'),
  checkOut('check_out');

  const AttendanceEventType(this.apiValue);

  /// `/v1/attendance/attendance/` `event_type` maydoni qiymati.
  final String apiValue;

  /// Backend qiymatidan enum (noma’lum bo‘lsa `null`).
  static AttendanceEventType? fromApi(String? value) {
    for (final t in values) {
      if (t.apiValue == value) return t;
    }
    return null;
  }
}
