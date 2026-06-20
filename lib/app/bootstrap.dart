import 'package:flutter/widgets.dart';

import '../core/services/attendance_sync_manager.dart';
import '../injection_container.dart';


Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  // await SupabaseService.initialize();
  await configureDependencies();
  // Offline davomat navbati — tarmoq/autentifikatsiya tiklanganda avtomatik sinxron.
  getIt<AttendanceSyncManager>().start();
  // Session stays `unknown` (the router guard holds on the animated SplashPage,
  // which the native splash hands off to). [SplashPage] dispatches
  // [SessionStarted] only after its «Davomat» reveal finishes, so the splash is
  // always visible for its full duration regardless of engine warm-up — then
  // the guard redirects to login / face / home.
  // Bloc.observer = const AppBlocObserver();
  runApp(builder());
}
