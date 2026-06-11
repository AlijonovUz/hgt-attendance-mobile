import 'coordinate.dart';

class Routes implements Coordinate {
  const Routes._({
    required this.name,
    required this.path,
  });

  final String name;
  final String path;

  /// Auth
  static const authIntro = Routes._(name: 'auth_intro_page', path: '/auth_intro');
  static const splash = Routes._(name: 'splash', path: '/splash');
  static const login = Routes._(name: 'login', path: '/login');
  static const checkCode = Routes._(name: 'check_code_page', path: '/check_code');
  static const confirmCode = Routes._(name: "confirm_code", path: "/confirm_code");
  static const pinCode = Routes._(name: "pin_code", path: "/pin_code");

  static const root = Routes._(name: 'root', path: '/');
  static const home = Routes._(name: 'home_page', path: '/home_page');

  @override
  String toString() => 'name=$name, path=$path';
}
