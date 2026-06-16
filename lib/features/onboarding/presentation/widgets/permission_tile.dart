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
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

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
            _IconBox(icon: icon, granted: granted, colors: colors),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title
                      .s(15.sp)
                      .w(600)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2.h),
                  description
                      .s(13.sp)
                      .w(400)
                      .c(colors.textSub)
                      .h(18 / 13)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (granted)
              Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: Assets.icons.icHugeiconsSecurityCheck.svg(
                  width: 22.r,
                  height: 22.r,
                  colorFilter: ColorFilter.mode(
                    colors.successPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              )
            else ...[
              SizedBox(width: 12.w),
              _GrantButton(
                label: l10n.onbGrant,
                colors: colors,
                onTap: onGrant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Oq yumaloq ikon qutisi — berilganda yashil tus oladi.
class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.granted,
    required this.colors,
  });

  final SvgGenImage icon;
  final bool granted;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.r,
      height: 44.r,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: granted ? colors.successSoft : colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.strokeSoft),
        ),
        child: Center(
          child: icon.svg(
            width: 22.r,
            height: 22.r,
            colorFilter: ColorFilter.mode(
              granted ? colors.successPrimary : colors.iconStrong,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

/// To‘q «pill» tugma (`textStrong` fon, oq yozuv).
class _GrantButton extends StatelessWidget {
  const _GrantButton({
    required this.label,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10.r);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.textStrong,
        borderRadius: radius,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
            child: label.s(13.sp).w(600).c(colors.backgroundBase),
          ),
        ),
      ),
    );
  }
}
