import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/logout_dialog.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/bloc/history/attendance_history_bloc.dart';
import '../../../attendance/presentation/pages/attendance_page.dart';
import '../../../attendance/presentation/pages/face_match_diagnostic_page.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/widgets/profile_photo_prompt_sheet.dart';
import '../bloc/attendance_bloc.dart';
import 'asosiy_page.dart';

/// Autentifikatsiyadan keyingi asosiy qobiq (shell): pastki navigatsiya bilan
/// uchta tab — Asosiy / Davomat tarixi / Shaxsiy (Figma 57:2055, 125:488).
///
/// [ProfileBloc] shu yerda taqdim etiladi va Asosiy header avatari hamda
/// Shaxsiy tab o‘rtasida bo‘lishiladi. Profil rasmi (`face_image`) yo‘q bo‘lsa
/// «shaxsiy rasm o‘rnating» modali avtomatik ochiladi.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested())),
        BlocProvider<AttendanceBloc>(create: (_) => getIt<AttendanceBloc>()),
        // Davomat tarixi bloci shu yerda — shell pastki-nav almashtirilganda
        // qayta GET (`HistoryRefreshed`) yuborishi uchun (tab IndexedStack’da
        // bir marta quriladi, shuning uchun sahifa o‘zi qayta yuklamaydi).
        BlocProvider<AttendanceHistoryBloc>(
          create: (_) => getIt<AttendanceHistoryBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>()..add(const NotificationCountRequested()),
        ),
      ],
      child: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;
  bool _promptShown = false;
  StreamSubscription<RemoteMessage>? _pushSub;

  @override
  void initState() {
    super.initState();
    // Old planda push kelganda badge sonini yangilab qo‘yamiz.
    _pushSub = getIt<PushNotificationService>().messages.listen((_) {
      if (mounted) {
        context.read<NotificationBloc>().add(const NotificationCountRequested());
      }
    });
  }

  @override
  void dispose() {
    _pushSub?.cancel();
    super.dispose();
  }

  void _openPrompt() {
    showProfilePhotoPrompt(context, context.read<ProfileBloc>());
  }

  /// Pastki-nav tab almashganda — tegishli blocga qayta GET yuboramiz, shunda
  /// tabga o‘tilganda doim yangi ma’lumot keladi (IndexedStack sahifani tirik
  /// saqlagani sababli sahifaning o‘zi qayta yuklamasdi). Avval yuklanmagan
  /// bloclar (`userId` yo‘q) so‘rovni e’tiborsiz qoldiradi — konfiguratsiya
  /// listener’lari boshlang‘ich yuklashni baribir bajaradi.
  void _onTabChanged(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    switch (index) {
      case 0:
        context.read<ProfileBloc>().add(const ProfileRequested());
        context.read<AttendanceBloc>().add(const AttendanceRefreshed());
      case 1:
        context.read<AttendanceHistoryBloc>().add(const HistoryRefreshed());
    }
  }

  Future<void> _confirmLogout() async {
    final session = context.read<SessionBloc>();
    final confirmed = await showLogoutDialog(context);
    if (confirmed == true) {
      session.add(const SessionLogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (p, c) => p.needsPhoto != c.needsPhoto,
        listener: (context, state) {
          if (state.needsPhoto && !_promptShown) {
            _promptShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _openPrompt();
            });
          }
        },
        child: IndexedStack(
          index: _index,
          children: [
            AsosiyPage(onAvatarNeedsPhoto: _openPrompt, onLogout: _confirmLogout),
            const AttendancePage(),
            ProfilePage(onLogout: _confirmLogout),
          ],
        ),
      ),
      // Debug: yuz moslik diagnostika sahifasi (ikki rasm → cosine sim + log).
      // Faqat debug build’da ko‘rinadi; relizda yo‘q.
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              heroTag: 'face_match_diag',
              backgroundColor: colors.accentStrong,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FaceMatchDiagnosticPage(),
                ),
              ),
              child: Icon(Icons.face_retouching_natural, color: colors.iconWhite),
            )
          : null,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: _onTabChanged,
        items: [
          AppBottomNavItem(icon: Assets.icons.icHugeiconsMenuSquare, label: l10n.navHome),
          AppBottomNavItem(icon: Assets.icons.icHugeiconsClock, label: l10n.navHistory),
          AppBottomNavItem(icon: Assets.icons.icHugeiconsMale, label: l10n.navProfile),
        ],
      ),
    );
  }
}
