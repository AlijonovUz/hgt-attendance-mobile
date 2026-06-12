import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/bloc/theme/theme_bloc.dart';
import '../../config/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// Yorug‘ / Qorong‘i segmentli toggle (login toolbar’i). `ThemeBloc`ka yozadi.
///
/// `system` rejimda joriy platforma yorqinligiga qarab segment yoritiladi.
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1Alt,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: colors.strokeSoft),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.r),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Segment(
                  label: l10n.themeLight,
                  icon: Assets.icons.icHugeiconsSun,
                  selected: !isDark,
                  colors: colors,
                  onTap: () => context
                      .read<ThemeBloc>()
                      .add(const ThemeModeSelected(ThemeMode.light)),
                ),
                _Segment(
                  label: l10n.themeDark,
                  icon: Assets.icons.icHugeiconsMoon,
                  selected: isDark,
                  colors: colors,
                  onTap: () => context
                      .read<ThemeBloc>()
                      .add(const ThemeModeSelected(ThemeMode.dark)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final SvgGenImage icon;
  final bool selected;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? colors.textStrong : colors.textSoft;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? colors.backgroundBase : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.black.withValues(alpha: 0.08),
                    offset: Offset(0, 1.h),
                    blurRadius: 3.r,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: label
                  .s(13.sp)
                  .w(selected ? 600 : 500)
                  .c(fg)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(width: 5.w),
            icon.svg(
              width: 15.r,
              height: 15.r,
              colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
