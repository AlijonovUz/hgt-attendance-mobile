import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

/// Onboarding bosqichlaridagi yagona pastki amal tugmasi (Figma 299:7785):
/// markazda, kamida 200 keng, 22 radiusli, ko‘k gradient. Yorliq uzun bo‘lsa
/// kengayadi (200 — minimal kenglik).
class OnboardingActionButton extends StatelessWidget {
  const OnboardingActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.gradient = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Ko‘k gradient fon (asosiy «davom etish» tugmalari). `false` bo‘lsa bir rang
  /// `accent` fon (masalan «Sozlamalarni ochish»).
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200.w),
        child: CustomButton(
          label: label,
          expand: false,
          isLoading: isLoading,
          gradient: gradient ? AppColors.onboardingActionGradient : null,
          borderRadius: 22.r,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
