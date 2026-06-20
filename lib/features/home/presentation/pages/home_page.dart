import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/domain/usecases/cache_geozone_usecase.dart';
import '../../../attendance/domain/usecases/ensure_reference_embedding_usecase.dart';
import '../../../attendance/presentation/pages/davomat_tarixi_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/pages/shaxsiy_page.dart';
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
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
        ),
        BlocProvider<AttendanceBloc>(create: (_) => getIt<AttendanceBloc>()),
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
  bool _offlineCachePrimed = false;

  void _openPrompt() {
    showProfilePhotoPrompt(context, context.read<ProfileBloc>());
  }

  /// Profil yuklangach (online) offline davomat uchun ish hududi (geozone) va
  /// reference yuz embeddingini lokalga tayyorlaydi. Fire-and-forget — offline
  /// bo‘lsa jimgina o‘tadi (oldingi cache qoladi).
  void _primeOfflineCache(ProfileState state) {
    final profile = state.profile;
    if (profile == null || _offlineCachePrimed) return;
    _offlineCachePrimed = true;
    final branchId = profile.branchId;
    if (branchId != null && branchId.isNotEmpty) {
      getIt<CacheGeozoneForBranchUseCase>()(branchId).ignore();
    }
    getIt<EnsureReferenceEmbeddingUseCase>()(profile).ignore();
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final session = context.read<SessionBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.backgroundElevation1,
        title: l10n.homeLogout.s(16.sp).w(700).c(colors.textStrong),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: l10n.commonCancel.s(14.sp).w(500).c(colors.textSub),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: l10n.homeLogout.s(14.sp).w(700).c(colors.errorStrong),
          ),
        ],
      ),
    );
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (p, c) => p.needsPhoto != c.needsPhoto,
            listener: (context, state) {
              if (state.needsPhoto && !_promptShown) {
                _promptShown = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _openPrompt();
                });
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (p, c) => p.profile != c.profile,
            listener: (context, state) => _primeOfflineCache(state),
          ),
        ],
        child: IndexedStack(
          index: _index,
          children: [
            AsosiyPage(
              onAvatarNeedsPhoto: _openPrompt,
              onLogout: _confirmLogout,
            ),
            const DavomatTarixiPage(),
            ShaxsiyPage(onLogout: _confirmLogout),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          AppBottomNavItem(
            icon: Assets.icons.icHugeiconsMenuSquare,
            label: l10n.navHome,
          ),
          AppBottomNavItem(
            icon: Assets.icons.icHugeiconsClock,
            label: l10n.navHistory,
          ),
          AppBottomNavItem(
            icon: Assets.icons.icHugeiconsMale,
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
