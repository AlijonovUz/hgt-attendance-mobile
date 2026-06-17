import '../../../../attendance/domain/entities/attendance_event_type.dart';

/// Universal yuz-tekshiruv oqimining rejimi — `FaceVerifyBloc` shu rejimga qarab
/// GPS oladimi, selfini qayerga (verify-face yoki attendance) yuboradi va qaysi
/// token bilan ishlashini hal qiladi.
sealed class FaceFlowMode {
  const FaceFlowMode();
}

/// Login’dan keyingi yuz tasdig‘i: selfie `verify-face`ga RAM’dagi (hali
/// saqlanmagan) access token bilan yuboriladi. GPS yo‘q.
class LoginFaceMode extends FaceFlowMode {
  const LoginFaceMode({required this.accessToken, required this.fullName});

  final String accessToken;
  final String fullName;
}

/// Davomat hodisasi: GPS olinadi, selfie `attendance`ga `event_type` + koordinata
/// bilan yuboriladi (saqlangan token AuthInterceptor orqali).
class AttendanceFaceMode extends FaceFlowMode {
  const AttendanceFaceMode(this.eventType);

  final AttendanceEventType eventType;
}
