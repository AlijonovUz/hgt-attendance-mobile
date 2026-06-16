import 'coordinate.dart';

class Routes implements Coordinate {
  const Routes._({required this.name, required this.path});

  @override
  final String name;
  @override
  final String path;

  /// Auth
  static const splash = Routes._(name: 'splash', path: '/splash');
  static const login = Routes._(name: 'login', path: '/login');

  /// Login’dan keyingi majburiy onboarding oqimi (welcome → ruxsatlar → parol →
  /// rasm → yuz tasdig‘i → tayyor). PageView.
  static const onboarding = Routes._(name: 'onboarding', path: '/onboarding');

  /// Login’dan keyingi majburiy yuz tasdig‘i (alohida — guard zanjirida emas,
  /// onboarding ichidagi bosqich ishlatadi).
  static const faceVerify = Routes._(name: 'face_verify', path: '/face_verify');

  /// Davomat (guard zanjirida emas — mosligi uchun saqlanadi).
  static const checkCode = Routes._(
    name: 'check_code_page',
    path: '/check_code',
  );

  static const root = Routes._(name: 'root', path: '/');
  static const home = Routes._(name: 'home_page', path: '/home_page');

  /// Davomat yuz-tekshiruvi (asosiy ekrandan push qilinadi, `extra` =
  /// `AttendanceEventType`). Guard zanjirida emas — authenticated user uchun.
  static const attendanceFace = Routes._(
    name: 'attendance_face',
    path: '/attendance_face',
  );

  @override
  String toString() => 'name=$name, path=$path';
}
