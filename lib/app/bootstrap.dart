import 'package:flutter/widgets.dart';

import '../injection_container.dart';
import 'bloc/session_bloc.dart';


Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  // await SupabaseService.initialize();
  await configureDependencies();
  // Resolve persisted session before first frame so the router has a
  // concrete status (authenticated / unauthenticated) to act on.
  final session = getIt<SessionBloc>()..add(const SessionStarted());
  await session.stream.firstWhere((state) => state.isResolved);
  // Bloc.observer = const AppBlocObserver();
  runApp(builder());
}
