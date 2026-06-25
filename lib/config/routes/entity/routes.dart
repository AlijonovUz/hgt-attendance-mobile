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

  static const root = Routes._(name: 'root', path: '/');
  static const home = Routes._(name: 'home_page', path: '/home_page');

  /// Parol o‘zgartirish (Shaxsiy tabdan push qilinadi — authenticated user).
  static const changePassword = Routes._(name: 'change_password', path: '/change_password');

  /// Davomat yuz-tekshiruvi (asosiy ekrandan push qilinadi, `extra` =
  /// `AttendanceEventType`). Guard zanjirida emas — authenticated user uchun.
  static const attendanceFace = Routes._(name: 'attendance_face', path: '/attendance_face');

  /// Bildirishnomalar (asosiy ekran bell tugmasidan push qilinadi —
  /// authenticated user). Guard zanjirida emas.
  static const notifications = Routes._(name: 'notifications', path: '/notifications');

  /// Debug: offline yuz moslik diagnostika (ikki rasm → cosine sim + log).
  /// Faqat `kDebugMode` entry’sidan ochiladi; guard zanjirida emas.
  static const faceMatchDiagnostic =
      Routes._(name: 'face_match_diagnostic', path: '/face_match_diagnostic');

  @override
  String toString() => 'name=$name, path=$path';
}
