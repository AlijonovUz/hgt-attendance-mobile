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
        color: AppColors.onboardingCardBg,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.onboardingCardBorder),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            _Avatar(data: data),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  name
                      .s(14.sp)
                      .w(600)
                      .c(AppColors.onboardingCardText)
                      .h(20 / 14)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2.h),
                  role
                      .s(14.sp)
                      .w(400)
                      .c(AppColors.onboardingCardTextSub)
                      .h(20 / 14)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Assets.icons.icHugeiconsSecurityCheck.svg(
              width: 24.r,
              height: 24.r,
              colorFilter: ColorFilter.mode(
                colors.successPrimary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar — login rasmi (mavjud bo‘lsa) yoki ism bosh harflari.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.data});

  final OnboardingData data;

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
      width: 40.r,
      height: 40.r,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.onboardingAvatarBg,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: hasImage
              ? Image.network(
                  data.faceImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _InitialsLabel(initials: _initials()),
                )
              : _InitialsLabel(initials: _initials()),
        ),
      ),
    );
  }
}

class _InitialsLabel extends StatelessWidget {
  const _InitialsLabel({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: initials.s(16.sp).w(600).c(AppColors.onboardingAvatarText),
    );
  }
}
