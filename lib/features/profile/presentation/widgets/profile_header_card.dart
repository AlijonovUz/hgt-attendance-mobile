import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/profile.dart';

/// «Shaxsiy» sahifasi tepasidagi profil kartasi (Figma 549‑15533):
/// markazda rasm + ism + lavozim (ko‘k), ostida ikki statistika qutisi —
/// «Oylik KPI» va «Oylik davomat».
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.profile, this.usernameFallback = 'Username', this.onTap});

  final Profile? profile;
  final String usernameFallback;

  /// Rasm yo‘q bo‘lganda — yuklash modalini ochish uchun.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    final name = (profile?.fullName.trim().isNotEmpty ?? false) ? profile!.fullName.trim() : '—';
    final role = profile?.roleName?.trim().isNotEmpty == true ? profile!.roleName!.trim() : usernameFallback;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.backgroundElevation2, borderRadius: BorderRadius.circular(22.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
        child: Column(
          children: [
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: _Avatar(faceImage: profile?.faceImage, colors: colors),
            ),
            SizedBox(height: 8.h),
            name.s(18.sp).w(700).c(colors.textStrong).h(24 / 18).a(TextAlign.center).copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 2.h),
            role.s(14.sp).w(500).c(colors.accentSub).h(20 / 14).a(TextAlign.center).copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _StatBox(
                    label: l10n.homeKpi,
                    value: _kpiText(profile),
                    icon: Assets.icons.icHugeiconsMoneyReceiveFlow,
                    iconColor: colors.successPrimary,
                    colors: colors,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _StatBox(
                    label: l10n.homeMonthlyAttendance,
                    value: profile?.kpi?.monthlyAttendance ?? '—',
                    icon: Assets.icons.icHugeiconsDataTime,
                    iconColor: colors.accentSub,
                    colors: colors,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _kpiText(Profile? profile) {
    final kpi = profile?.kpi?.monthlyKpi;
    if (kpi == null) return '—';
    return '${kpi.toStringAsFixed(0)}%';
  }
}

/// «Oylik KPI» / «Oylik davomat» qutisi.
class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.icon, required this.iconColor, required this.colors});

  final String label;
  final String value;
  final SvgGenImage icon;
  final Color iconColor;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.backgroundElevation1, borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: label.s(13.sp).w(400).c(colors.textSub).h(16 / 13).copyWith(maxLines: 1, overflow: TextOverflow.ellipsis)),
                SizedBox(width: 8.w),
                icon.svg(width: 20.r, height: 20.r, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
              ],
            ),
            SizedBox(height: 8.h),
            value.s(18.sp).w(700).c(colors.textStrong).h(24 / 18).copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

/// Profil rasmi (yumaloq-kvadrat) — tarmoq / media / lokal / placeholder.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.faceImage, required this.colors});

  final String? faceImage;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.r,
      height: 64.r,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: DecoratedBox(
          decoration: BoxDecoration(color: colors.avatarPlaceholder),
          child: _image(),
        ),
      ),
    );
  }

  Widget _image() {
    final src = faceImage?.trim() ?? '';
    if (src.isEmpty) return _placeholder();

    if (src.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: src,
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(),
        errorWidget: (context, url, error) => _placeholder(),
      );
    }
    if (src.startsWith('/media') || src.startsWith('media')) {
      final origin = ApiConstants.baseUrl.replaceFirst('/api', '');
      return CachedNetworkImage(
        imageUrl: '$origin${src.startsWith('/') ? '' : '/'}$src',
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(),
        errorWidget: (context, url, error) => _placeholder(),
      );
    }
    return Image.file(File(src), fit: BoxFit.cover, errorBuilder: (context, error, stack) => _placeholder());
  }

  Widget _placeholder() => Center(
    child: Assets.icons.icUser.svg(width: 32.r, height: 32.r, colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn)),
  );
}
