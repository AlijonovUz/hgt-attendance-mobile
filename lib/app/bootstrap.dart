import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import '../core/services/push_notification_service.dart';
import '../firebase_options.dart';
import '../injection_container.dart';

Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FCM background handler — runApp’dan oldin ro‘yxatdan o‘tishi shart.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await configureDependencies();

  // Push xizmatini ishga tushiramiz (ruxsat, listenerlar, token sinxron).
  // Xato bo‘lsa ilova baribir ishlashda davom etadi.
  unawaited(getIt<PushNotificationService>().init());

  // Session stays `unknown` (the router guard holds on the animated SplashPage,
  // which the native splash hands off to). [SplashPage] dispatches
  // [SessionStarted] only after its «Davomat» reveal finishes, so the splash is
  // always visible for its full duration regardless of engine warm-up — then
  // the guard redirects to login / face / home.
  // Bloc.observer = const AppBlocObserver();
  runApp(builder());
}
