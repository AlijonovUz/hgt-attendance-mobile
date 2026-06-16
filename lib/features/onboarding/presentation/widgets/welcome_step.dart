import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/onboarding_bloc.dart';
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
          SizedBox(height: 12.h),
          l10n.onbWelcomeTitle
              .s(24.sp)
              .w(700)
              .c(colors.textStrong)
              .a(TextAlign.center)
              .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
          SizedBox(height: 8.h),
          l10n.onbWelcomeSubtitle
              .s(14.sp)
              .w(400)
              .c(colors.textSub)
              .h(20 / 14)
              .a(TextAlign.center)
              .copyWith(maxLines: 5, overflow: TextOverflow.ellipsis),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 72.r,
                    height: 72.r,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.brandNavy,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(18.r),
                        child: Assets.icons.icExclude.svg(
                          colorFilter: ColorFilter.mode(
                            colors.textWhite,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  BlocBuilder<OnboardingBloc, OnboardingState>(
                    buildWhen: (p, c) => p.data != c.data,
                    builder: (context, state) =>
                        ProfileSummaryCard(data: state.data),
                  ),
                ],
              ),
            ),
          ),
          CustomButton(
            label: l10n.onbContinue,
            gradient: AppColors.onboardingActionGradient,
            onPressed: () =>
                context.read<OnboardingBloc>().add(const OnboardingNextPressed()),
          ),
        ],
      ),
    );
  }
}
