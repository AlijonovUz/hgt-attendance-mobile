import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme/app_colors.dart';

/// Yuklanish (loading) holatlari uchun mavzuga moslashuvchi shimmer wrapper.
///
/// Skelet bloklari ([ShimmerBox]) shu wrapper ichida joylashadi; bir butun
/// gradient «sweep» ularning ustidan yuradi. Och va qorong‘i rejimlarda
/// alohida base/highlight ranglar — har ikkalasida ham yumshoq, dizaynga mos
/// ko‘rinadi (ranglar `AppColors` tokenlaridan, hech qanday xom hex emas).
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Och: kartalardan biroz to‘qroq base + karta foni highlight (yumshoq sweep).
    // Qorong‘i: karta foni base + bir pog‘ona yorug‘ highlight (ko‘rinadigan sweep).
    final base =
        dark ? colors.backgroundElevation2 : colors.backgroundElevation3;
    final highlight =
        dark ? colors.backgroundElevation3Alt : colors.backgroundElevation2;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

/// [AppShimmer] ichidagi yagona skelet bloki — to‘la shaffofmas, yumaloq
/// burchakli. [width]/[height] chaqiruvchi tomonidan miqyoslangan (`.w`/`.h`/`.r`)
/// holda beriladi; [radius] esa ichkarida `.r` ga o‘giriladi (dizayn tokeni).
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.of(context).backgroundElevation2,
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(radius.r),
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}
