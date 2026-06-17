import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';

/// Ruxsat kartasi (Figma 256‑1138): ikon qutisi + sarlavha/tavsif + «Ruxsat
/// berish» tugmasi. Berilgan bo‘lsa ikon yashil, tugma yo‘qoladi.
class PermissionTile extends StatelessWidget {
  const PermissionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.onGrant,
  });

  /// Karta ikoni (location / camera SVG).
  final SvgGenImage icon;
  final String title;
  final String description;
  final bool granted;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.onboardingCardBg,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.onboardingCardBorder),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBox(icon: icon, granted: granted),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title
                          .s(14.sp)
                          .w(500)
                          .c(AppColors.onboardingCardText)
                          .h(20 / 14)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      SizedBox(height: 2.h),
                      description
                          .s(14.sp)
                          .w(400)
                          .c(AppColors.onboardingCardTextSub)
                          .h(20 / 14)
                          .copyWith(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ],
                  ),
                ),
              ],
            ),
            // Berilmagan bo‘lsa «Ruxsat berish» tugmasi pastda, o‘ngda (Figma).
            if (!granted) ...[
              SizedBox(height: 16.h),
              _GrantButton(label: l10n.onbGrant, onTap: onGrant),
            ],
          ],
        ),
      ),
    );
  }
}

/// To‘q yumaloq ikon qutisi (Figma `card` fon) — berilganda ikon yashil tus oladi.
class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.granted});

  final SvgGenImage icon;
  final bool granted;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SizedBox(
      width: 40.r,
      height: 40.r,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.onboardingCardIconBg,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: icon.svg(
            width: 20.r,
            height: 20.r,
            colorFilter: ColorFilter.mode(
              granted ? colors.successPrimary : colors.iconWhite,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

/// «Ruxsat berish» pill tugmasi (Figma `primary` `#e5e5e5` fon, `#171717` yozuv).
class _GrantButton extends StatelessWidget {
  const _GrantButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10.r);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.onboardingCardButtonBg,
        borderRadius: radius,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: label.s(14.sp).w(500).c(AppColors.onboardingCardButtonText),
          ),
        ),
      ),
    );
  }
}
