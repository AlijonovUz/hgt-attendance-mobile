import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../app/bloc/theme/theme_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/widgets/profile_avatar_card.dart';
import '../../../profile/presentation/widgets/profile_photo_prompt_sheet.dart';

/// Autentifikatsiyadan keyingi asosiy ekran (Figma 57-2578).
///
/// Yuklanishida profil olinadi; profil rasmi (`face_image`) yo‘q bo‘lsa
/// «shaxsiy rasm o‘rnating» modali avtomatik ochiladi. Foydalanuvchi qurilmadan
/// rasm tanlab yuklaydi → PATCH `face_image`.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  bool _promptShown = false;

  void _openPrompt() {
    final bloc = context.read<ProfileBloc>();
    showProfilePhotoPrompt(context, bloc);
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
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (p, c) => p.needsPhoto != c.needsPhoto,
        listener: (context, state) {
          if (state.needsPhoto && !_promptShown) {
            _promptShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _openPrompt();
            });
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 12.h),
                  ProfileAvatarCard(
                    profile: state.profile,
                    usernameFallback: l10n.profileUsernameFallback,
                    onTap: state.needsPhoto ? _openPrompt : null,
                    onLongPress: _confirmLogout,
                  ),
                  SizedBox(height: 24.h),
                  const Center(child: _ControlPill()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Markazlashgan segment (Figma `Frame 1999`): tema almashtirish + yuz skani.
class _ControlPill extends StatelessWidget {
  const _ControlPill();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1Alt,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: colors.strokeSoft),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.r),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PillButton(
                  icon: isDark
                      ? Assets.icons.icHugeiconsMoon
                      : Assets.icons.icHugeiconsSun,
                  colors: colors,
                  onTap: () => context.read<ThemeBloc>().add(
                        ThemeModeSelected(
                          isDark ? ThemeMode.light : ThemeMode.dark,
                        ),
                      ),
                ),
                _PillButton(
                  icon: Assets.icons.icLucideScanFace,
                  colors: colors,
                  onTap: () => context
                      .read<ProfileBloc>()
                      .add(const ProfileRequested()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final SvgGenImage icon;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52.w,
        height: 36.h,
        child: Center(
          child: icon.svg(
            width: 20.r,
            height: 20.r,
            colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
