import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/bloc/theme/theme_bloc.dart';
import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_photo_prompt_sheet.dart';

/// «Shaxsiy» tab (Figma 549‑15305): yuqorida fixed AppBar (navProfile) +
/// scroll qilinadigan body — profil kartasi, ma’lumotlar, parol o‘zgartirish,
/// tema almashtirish, chiqish.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      appBar: AppBar(
        backgroundColor: colors.backgroundBase,
        surfaceTintColor: colors.backgroundBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20.w,
        automaticallyImplyLeading: false,
        title: l10n.navProfile.s(20.sp).w(700).c(colors.textStrong),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final profile = state.profile;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeaderCard(
                  profile: profile,
                  usernameFallback: l10n.profileUsernameFallback,
                  onTap: state.needsPhoto
                      ? () => showProfilePhotoPrompt(
                          context,
                          context.read<ProfileBloc>(),
                        )
                      : null,
                ),
                SizedBox(height: 16.h),
                _InfoSection(profile: profile, colors: colors, l10n: l10n),
                SizedBox(height: 16.h),
                _SettingsTile(
                  icon: Assets.icons.icHugeiconsSecurity,
                  iconColor: colors.iconStrong,
                  label: l10n.profileChangePassword,
                  labelColor: colors.textStrong,
                  background: colors.backgroundElevation2,
                  trailing: Assets.icons.icHugeiconsArrowRightRound.svg(
                    width: 20.r,
                    height: 20.r,
                    colorFilter: ColorFilter.mode(
                      colors.iconSub,
                      BlendMode.srcIn,
                    ),
                  ),
                  onTap: () => context.pushNamed(Routes.changePassword.name),
                ),
                SizedBox(height: 24.h),
                const _ThemeToggleButton(),
                SizedBox(height: 12.h),
                _SettingsTile(
                  icon: Assets.icons.icHugeiconsLogoutCircle,
                  iconColor: colors.errorStrong,
                  label: l10n.homeLogout,
                  labelColor: colors.errorStrong,
                  background: colors.errorSoft,
                  centered: true,
                  onTap: onLogout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Profil ma’lumotlari kartasi: Filial / Bo‘lim / Viloyat / Tuman / Telefon.
class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.profile,
    required this.colors,
    required this.l10n,
  });

  final Profile? profile;
  final AppColors colors;
  final AppLocalizations l10n;

  String _val(String? v) => v?.trim().isNotEmpty == true ? v!.trim() : '—';

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      (l10n.profileFieldBranch, _val(profile?.branchName)),
      (l10n.profileFieldDepartment, _val(profile?.departmentName)),
      (l10n.profileFieldRegion, _val(profile?.regionName)),
      (l10n.profileFieldDistrict, _val(profile?.districtName)),
      (l10n.profileFieldPhone, _val(profile?.phone)),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation2,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              _InfoRow(label: rows[i].$1, value: rows[i].$2, colors: colors),
              if (i != rows.length - 1)
                Divider(height: 1, color: colors.strokeSub),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          label.s(14.sp).w(400).c(colors.textSub).h(20 / 14),
          SizedBox(width: 12.w),
          Expanded(
            child: value
                .s(14.sp)
                .w(500)
                .c(colors.textStrong)
                .h(20 / 14)
                .a(TextAlign.end)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// Sozlama qatori (parol o‘zgartirish / chiqish) — ikonka + yorliq + ixtiyoriy
/// trailing. [centered] bo‘lsa ikonka+yorliq markazda (Chiqish).
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
    required this.background,
    this.trailing,
    this.centered = false,
    this.onTap,
  });

  final SvgGenImage icon;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final Color background;
  final Widget? trailing;
  final bool centered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.r);
    final iconWidget = icon.svg(
      width: 24.r,
      height: 24.r,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
    final text = label
        .s(15.sp)
        .w(600)
        .c(labelColor)
        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis);

    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: radius),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: centered
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconWidget,
                      SizedBox(width: 8.w),
                      Flexible(child: text),
                    ],
                  )
                : Row(
                    children: [
                      iconWidget,
                      SizedBox(width: 12.w),
                      Expanded(child: text),
                      if (trailing != null) ...[
                        SizedBox(width: 12.w),
                        trailing!,
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Tema almashtirish tugmasi — joriy effektiv rejimga qarab Yorug‘ ↔ Qorong‘i.
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);

        return CustomButton(
          label: isDark ? l10n.themeLight : l10n.themeDark,
          variant: CustomButtonVariant.outline,
          leading: (isDark
                  ? Assets.icons.icHugeiconsSun
                  : Assets.icons.icHugeiconsMoon)
              .svg(
            width: 20.r,
            height: 20.r,
            colorFilter: ColorFilter.mode(colors.accentSub, BlendMode.srcIn),
          ),
          onPressed: () => context.read<ThemeBloc>().add(
                ThemeModeSelected(isDark ? ThemeMode.light : ThemeMode.dark),
              ),
        );
      },
    );
  }
}
