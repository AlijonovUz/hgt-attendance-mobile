import 'coordinate.dart';

class Routes implements Coordinate {
  const Routes._({
    required this.name,
    required this.path,
  });

  @override
  final String name;
  @override
  final String path;

  /// Auth
  static const splash = Routes._(name: 'splash', path: '/splash');
  static const login = Routes._(name: 'login', path: '/login');

  /// Login’dan keyingi majburiy yuz tasdig‘i.
  static const faceVerify = Routes._(name: 'face_verify', path: '/face_verify');

  /// Davomat (guard zanjirida emas — mosligi uchun saqlanadi).
  static const checkCode = Routes._(name: 'check_code_page', path: '/check_code');

  static const root = Routes._(name: 'root', path: '/');
  static const home = Routes._(name: 'home_page', path: '/home_page');

  @override
  String toString() => 'name=$name, path=$path';
}
