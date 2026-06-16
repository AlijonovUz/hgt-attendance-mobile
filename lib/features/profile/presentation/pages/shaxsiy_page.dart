import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/theme/theme_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_avatar_card.dart';
import '../widgets/profile_photo_prompt_sheet.dart';

/// «Shaxsiy» tab (Figma «Shaxsiy») — profil ma’lumotlari + sozlamalar.
///
/// Hozircha: profil olib kelinadi va asosiy maydonlar ko‘rsatiladi; tema
/// almashtirish va chiqish boshqaruvi shu yerda.
class ShaxsiyPage extends StatelessWidget {
  const ShaxsiyPage({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        return SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            children: [
              SizedBox(height: 4.h),
              l10n.navProfile.s(20.sp).w(700).c(colors.textStrong),
              SizedBox(height: 16.h),
              ProfileAvatarCard(
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
              SizedBox(height: 24.h),
              const _ThemeToggleButton(),
              SizedBox(height: 12.h),
              CustomButton(
                label: l10n.homeLogout,
                variant: CustomButtonVariant.outline,
                onPressed: onLogout,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.profile,
    required this.colors,
    required this.l10n,
  });

  final Profile? profile;
  final AppColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final rows = <(SvgGenImage, String, String)>[
      (Assets.icons.icUser, l10n.profileFieldName, profile?.fullName ?? '—'),
      (
        Assets.icons.icBreifcase,
        l10n.profileFieldRole,
        profile?.roleName?.trim().isNotEmpty == true ? profile!.roleName! : '—',
      ),
      (
        Assets.icons.icBuildings,
        l10n.profileFieldDepartment,
        profile?.departmentName?.trim().isNotEmpty == true
            ? profile!.departmentName!
            : '—',
      ),
      (
        Assets.icons.icProfile,
        l10n.profileFieldPhone,
        profile?.phone?.trim().isNotEmpty == true ? profile!.phone! : '—',
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation2,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              _InfoRow(
                icon: rows[i].$1,
                label: rows[i].$2,
                value: rows[i].$3,
                colors: colors,
              ),
              if (i != rows.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Divider(height: 1, color: colors.strokeSub),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });

  final SvgGenImage icon;
  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon.svg(
          width: 20.r,
          height: 20.r,
          colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: label.s(14.sp).w(400).c(colors.textSub),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: value
              .s(14.sp)
              .w(500)
              .c(colors.textStrong)
              .a(TextAlign.end)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
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
