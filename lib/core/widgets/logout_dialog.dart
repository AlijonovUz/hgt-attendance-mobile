import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// Chiqishni tasdiqlash dialogi (Figma 551‑16263 / 551‑16756).
///
/// Markazda karta: sarlavha + tavsif + ikki tugma («Orqaga» / «Chiqish»). `true`
/// (Chiqish) yoki `false`/`null` (Orqaga / tashqariga bosildi) qaytaradi.
Future<bool?> showLogoutDialog(BuildContext context) {
  final colors = AppColors.of(context);
  return showDialog<bool>(
    context: context,
    barrierColor: colors.black.withValues(alpha: 0.5),
    builder: (dialogContext) => const _LogoutDialog(),
  );
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: colors.backgroundElevation2,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            l10n.logoutTitle
                .s(18.sp)
                .w(700)
                .c(colors.textStrong)
                .h(24 / 18)
                .a(TextAlign.center)
                .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 8.h),
            l10n.logoutBody
                .s(13.sp)
                .w(400)
                .c(colors.textSub)
                .h(18 / 13)
                .a(TextAlign.center)
                .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: l10n.logoutBack,
                    background: colors.backgroundElevation1,
                    foreground: colors.textStrong,
                    border: colors.strokeSub,
                    icon: Assets.icons.icHugeiconsArrowLeftRound,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _DialogButton(
                    label: l10n.homeLogout,
                    background: colors.errorStrong,
                    foreground: colors.textWhite,
                    icon: Assets.icons.icHugeiconsLogoutCircle,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.onTap,
    this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final SvgGenImage icon;
  final VoidCallback onTap;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r);
    return SizedBox(
      height: 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: border == null ? null : Border.all(color: border!),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon.svg(
                    width: 20.r,
                    height: 20.r,
                    colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: label
                        .s(15.sp)
                        .w(600)
                        .c(foreground)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
