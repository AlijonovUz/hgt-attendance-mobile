import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';

/// Asosiy ekran pastidagi statistika kartasi (Figma 301:9933) — sarlavha +
/// burchakdagi rangli ikonka + katta qiymat. KPI / oylik davomat uchun
/// qayta ishlatiladigan modul.
class HomeStatCard extends StatelessWidget {
  const HomeStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final SvgGenImage icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation2,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: label
                      .s(14.sp)
                      .w(400)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 8.w),
                icon.svg(
                  width: 20.r,
                  height: 20.r,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            value.s(28.sp).w(700).c(colors.textStrong).h(32 / 28),
          ],
        ),
      ),
    );
  }
}
