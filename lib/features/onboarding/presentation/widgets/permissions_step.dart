import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/onboarding_bloc.dart';
import 'onboarding_action_button.dart';
import 'permission_tile.dart';

/// Onboarding «permissions» bosqichi (Figma 256‑1138): joylashuv + kamera
/// ruxsatlari. Ikkalasi ham berilganda pastki «Davom etish» tugmasi ko‘rinadi.
class PermissionsStep extends StatelessWidget {
  const PermissionsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<OnboardingBloc>();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        children: [
          // Sarlavha + ruxsat kartalari — bo‘sh joyda vertikal markazda bitta
          // guruh (Figma 299:7805: gap 2 sarlavha→tavsif, gap 20 kartalararo).
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  l10n.onbPermissionsTitle
                      .s(24.sp)
                      .w(700)
                      .c(colors.textStrong)
                      .a(TextAlign.center)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2.h),
                  l10n.onbPermissionsSubtitle
                      .s(14.sp)
                      .w(500)
                      .c(colors.textSub)
                      .h(20 / 14)
                      .a(TextAlign.center)
                      .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 20.h),
                  BlocBuilder<OnboardingBloc, OnboardingState>(
                    buildWhen: (p, c) =>
                        p.locationGranted != c.locationGranted ||
                        p.cameraGranted != c.cameraGranted,
                    builder: (context, state) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PermissionTile(
                            icon: Assets.icons.icHugeiconsLocationShare,
                            title: l10n.onbPermLocationTitle,
                            description: l10n.onbPermLocationDesc,
                            granted: state.locationGranted,
                            onGrant: () => bloc.add(
                              const OnboardingPermissionRequested(
                                OnboardingPermission.location,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          PermissionTile(
                            icon: Assets.icons.icHugeiconsCameraAdd,
                            title: l10n.onbPermCameraTitle,
                            description: l10n.onbPermCameraDesc,
                            granted: state.cameraGranted,
                            onGrant: () => bloc.add(
                              const OnboardingPermissionRequested(
                                OnboardingPermission.camera,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<OnboardingBloc, OnboardingState>(
            buildWhen: (p, c) =>
                p.locationGranted != c.locationGranted ||
                p.cameraGranted != c.cameraGranted,
            builder: (context, state) {
              final ready = state.locationGranted && state.cameraGranted;
              if (!ready) return SizedBox(height: 52.h);
              return OnboardingActionButton(
                label: l10n.onbContinue,
                onPressed: () => bloc.add(const OnboardingNextPressed()),
              );
            },
          ),
        ],
      ),
    );
  }
}
