import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// Pastki navigatsiya elementi tavsifi.
class AppBottomNavItem {
  const AppBottomNavItem({required this.icon, required this.label});

  /// flutter_gen SVG ikonkasi.
  final SvgGenImage icon;
  final String label;
}

/// Ilova pastki navigatsiya paneli (Figma 125:488 — Asosiy / Davomat tarixi /
/// Shaxsiy). Faol element to‘q (icon/text strong + 600), passivi sub rangda.
/// Tepada yengil ajratuvchi chiziq.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundBase,
        border: Border(top: BorderSide(color: colors.strokeSub)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.h,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    item: items[i],
                    selected: i == currentIndex,
                    colors: colors,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? colors.iconStrong : colors.iconSub;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          item.icon.svg(
            width: 24.r,
            height: 24.r,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          SizedBox(height: 6.h),
          item.label
              .s(11.sp)
              .w(600)
              .c(selected ? colors.textStrong : colors.textSub)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
