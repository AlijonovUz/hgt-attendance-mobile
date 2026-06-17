import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/onboarding_bloc.dart';
import 'onboarding_action_button.dart';
import 'profile_summary_card.dart';

/// Onboarding «welcome» bosqichi (Figma 248‑701): brend logotipi + tabrik
/// matni + profil xulosasi kartasi + pastki «Davom etish» tugmasi.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        children: [
          // Logo + matn + karta — bo‘sh joyda vertikal markazda bitta guruh
          // (Figma 299:7765: gap 12 logo→matn, gap 2 sarlavha→tavsif, gap 20 karta).
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48.r,
                    height: 48.r,
                    child: Assets.icons.icExclude.svg(
                      colorFilter: ColorFilter.mode(
                        colors.textStrong,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  l10n.onbWelcomeTitle
                      .s(24.sp)
                      .w(700)
                      .c(colors.textStrong)
                      .a(TextAlign.center)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2.h),
                  l10n.onbWelcomeSubtitle
                      .s(14.sp)
                      .w(500)
                      .c(colors.textSub)
                      .h(20 / 14)
                      .a(TextAlign.center)
                      .copyWith(maxLines: 5, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 20.h),
                  BlocBuilder<OnboardingBloc, OnboardingState>(
                    buildWhen: (p, c) => p.data != c.data,
                    builder: (context, state) =>
                        ProfileSummaryCard(data: state.data),
                  ),
                ],
              ),
            ),
          ),
          // «Davom etish» — markazda, 200 keng, 22 radiusli (Figma 299:7785).
          OnboardingActionButton(
            label: l10n.onbContinue,
            onPressed: () => context.read<OnboardingBloc>().add(
              const OnboardingNextPressed(),
            ),
          ),
        ],
      ),
    );
  }
}
