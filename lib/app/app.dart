import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Thunder ataylab dev_dependency (faqat debug overlay) — lib’dan import qilamiz,
// lekin `kDebugMode` bilan release’da o‘chadi.
// ignore: depend_on_referenced_packages
import 'package:thunder/thunder.dart';

import '../config/routes/coordinator.dart';
import '../config/theme/app_theme.dart';
import '../core/network/dio_client.dart';
import '../core/widgets/vpn_blocker.dart';
import '../injection_container.dart';
import '../l10n/app_localizations.dart';
import 'bloc/locale/locale_bloc.dart';
import 'bloc/session_bloc.dart';
import 'bloc/theme/theme_bloc.dart';

final _rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Ilova ildizi. App-level bloclar (`Session`, `Theme`, `Locale`) shu yerda
/// taqdim etiladi; tema rejimi va til shu bloclardan o‘qiladi. PIN/fon-timeout
/// lifecycle mantiqi olib tashlandi — bu loyihada faqat yuz tasdig‘i bor.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Thunder kuzatadigan asosiy Dio (interceptorlar bilan). Faqat debug’da
    // overlay ko‘rinadi (`enable: kDebugMode`).
    final monitoredDio = getIt<DioClient>().dio;

    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionBloc>.value(value: getIt<SessionBloc>()),
        BlocProvider<ThemeBloc>.value(value: getIt<ThemeBloc>()),
        BlocProvider<LocaleBloc>.value(value: getIt<LocaleBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<LocaleBloc, AppLanguage>(
                builder: (context, language) {
                  return MaterialApp.router(
                    scaffoldMessengerKey: _rootScaffoldMessengerKey,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    themeMode: themeMode,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: language.locale,
                    routerConfig: getIt<AppRouter>().router,
                    // Thunder MaterialApp ichida (builder) joylashadi — debug
                    // tarmoq overlay’i. Release’da `kDebugMode` orqali o‘chadi.
                    // VpnBlocker eng ustki qatlam — istalgan ekran/dialog
                    // ochiq bo‘lsa ham VPN aniqlansa to‘sib turuvchi oyna chiqadi.
                    builder: (context, child) => VpnBlocker(
                      child: Thunder(
                        enabled: kDebugMode,
                        dio: [monitoredDio],
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
