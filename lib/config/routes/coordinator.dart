import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/bloc/session_bloc.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/attendance/domain/entities/attendance_event_type.dart';
import '../../features/attendance/presentation/pages/attendance_face_page.dart';
import '../../features/auth/presentation/face/pages/face_verify_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import 'entity/routes.dart';

/// Root navigator key — exposed for context-free navigation (snackbars,
/// dialogs, theme toggles) outside the widget tree.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Centralized application router.
///
/// All routing lives here. A single [redirect] guard reads [SessionBloc] state
/// and decides the destination; [GoRouterRefreshStream] re-runs that guard on
/// every session change, so login / face-verify / logout transitions reroute
/// automatically with no imperative navigation scattered around.
class AppRouter {
  AppRouter(this._session) {
    router = _build();
  }

  final SessionBloc _session;
  late final GoRouter router;

  GoRouter _build() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: Routes.splash.path,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(_session.stream),
      redirect: _guard,
      routes: <RouteBase>[
        GoRoute(
          name: Routes.splash.name,
          path: Routes.splash.path,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          name: Routes.login.name,
          path: Routes.login.path,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          name: Routes.onboarding.name,
          path: Routes.onboarding.path,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          name: Routes.faceVerify.name,
          path: Routes.faceVerify.path,
          builder: (context, state) => const FaceVerifyPage(),
        ),
        GoRoute(
          name: Routes.checkCode.name,
          path: Routes.checkCode.path,
          builder: (context, state) => const AttendancePage(),
        ),
        GoRoute(
          name: Routes.home.name,
          path: Routes.home.path,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: Routes.attendanceFace.name,
          path: Routes.attendanceFace.path,
          builder: (context, state) =>
              AttendanceFacePage(eventType: state.extra as AttendanceEventType),
        ),
      ],
    );
  }

  /// The single redirect guard. Pure function of session state + target path.
  ///
  /// Flow: splash → login (no token) → faceVerify (logged in, face pending) →
  /// home (face verified).
  String? _guard(BuildContext context, GoRouterState state) {
    final session = _session.state;
    final location = state.matchedLocation;

    final onSplash = location == Routes.splash.path;
    final onLogin = location == Routes.login.path;
    final onOnboarding = location == Routes.onboarding.path;

    // Still resolving stored session -> hold on splash.
    if (!session.isResolved) {
      return onSplash ? null : Routes.splash.path;
    }

    // No token -> full login screen.
    if (session.isUnauthenticated) {
      return onLogin ? null : Routes.login.path;
    }

    // Logged in but onboarding (incl. face verify) not finished -> onboarding.
    if (session.isFaceVerificationRequired) {
      return onOnboarding ? null : Routes.onboarding.path;
    }

    // Fully authenticated: keep away from gates.
    if (onSplash || onLogin || onOnboarding) {
      return Routes.home.path;
    }

    return null;
  }
}

/// Adapts a [Stream] (a bloc stream) into a [Listenable] that GoRouter's
/// `refreshListenable` understands. Notifies once on creation, then on each event.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
