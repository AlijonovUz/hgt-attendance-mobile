import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/onboarding_data.dart';

/// Welcome bosqichidagi profil xulosasi kartasi (Figma 248‑701).
///
/// Yumaloq 22 radiusli translucent karta: avatar (login rasmi yoki bosh harflar)
/// + ism/lavozim + yashil «xavfsizlik» belgisi. Rang/o‘lcham tokenlardan.
class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({super.key, required this.data});

  final OnboardingData data;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    final name = data.fullName.trim();
    final role = (data.roleName?.trim().isNotEmpty ?? false)
        ? data.roleName!.trim()
        : l10n.onbRoleEmployee;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: colors.strokeSoft),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            _Avatar(data: data, colors: colors),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  name
                      .s(15.sp)
                      .w(700)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2.h),
                  role
                      .s(13.sp)
                      .w(400)
                      .c(colors.textSub)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Assets.icons.icHugeiconsSecurityCheck.svg(
              width: 22.r,
              height: 22.r,
              colorFilter:
                  ColorFilter.mode(colors.successPrimary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar — login rasmi (mavjud bo‘lsa) yoki ism bosh harflari.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.data, required this.colors});

  final OnboardingData data;
  final AppColors colors;

  /// Ismdan eng ko‘pi 2 ta katta harf (masalan «Akmal Karimov» → «AK»).
  String _initials() {
    final parts = data.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = data.hasFaceImage;

    return SizedBox(
      width: 44.r,
      height: 44.r,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.avatarPlaceholder,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: hasImage
              ? Image.network(
                  data.faceImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _InitialsLabel(
                    initials: _initials(),
                    colors: colors,
                  ),
                )
              : _InitialsLabel(initials: _initials(), colors: colors),
        ),
      ),
    );
  }
}

class _InitialsLabel extends StatelessWidget {
  const _InitialsLabel({required this.initials, required this.colors});

  final String initials;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: initials.s(15.sp).w(700).c(colors.textStrong),
    );
  }
}
