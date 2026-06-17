import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import 'onboarding_action_button.dart';

/// Onboarding yakuniy bosqichi (Figma 299‑8223): «Hammasi tayyor!». «Ishni
/// boshlash» bosilganda `SessionFaceVerified` yuboriladi — RAM tokenlar diskka
/// saqlanadi va guard home’ga yo‘naltiradi.
class OnboardingDoneStep extends StatelessWidget {
  const OnboardingDoneStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.icons.icHugeiconsParty.svg(width: 96.r, height: 96.r),
                  SizedBox(height: 20.h),
                  l10n.onbDoneTitle
                      .s(24.sp)
                      .w(600)
                      .c(colors.white)
                      .a(TextAlign.center)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2.h),
                  l10n.onbDoneSubtitle
                      .s(14.sp)
                      .w(600)
                      .c(AppColors.onboardingAvatarBg)
                      .h(20 / 14)
                      .a(TextAlign.center)
                      .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
          OnboardingActionButton(
            label: l10n.onbDoneStart,
            onPressed: () =>
                context.read<SessionBloc>().add(const SessionFaceVerified()),
          ),
        ],
      ),
    );
  }
}
