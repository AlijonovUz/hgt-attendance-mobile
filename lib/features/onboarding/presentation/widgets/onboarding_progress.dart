import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';

/// Onboarding tepa progress ko‘rsatkichi (Figma): joriy bosqich — cho‘zilgan
/// oq «pill», qolganlari — kichik nuqtalar. Tepa har ikkala rejimda ko‘k/navy
/// gradient ustida bo‘lgani uchun ranglar oq asosida (opasitet bilan).
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({super.key, required this.total, required this.index});

  /// Bosqichlar soni (yakuniy «done»siz).
  final int total;

  /// Joriy bosqich (0‑asosli).
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final active = colors.white;
    final done = colors.white.withValues(alpha: 0.7);
    final idle = colors.white.withValues(alpha: 0.3);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) SizedBox(width: 6.w),
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: i == index ? 26.w : 7.r,
            height: 7.r,
            decoration: BoxDecoration(
              color: i == index
                  ? active
                  : (i < index ? done : idle),
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
        ],
      ],
    );
  }
}
