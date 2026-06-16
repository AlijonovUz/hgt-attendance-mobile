import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/onboarding_bloc.dart';

/// Onboarding «imageUpload» bosqichi (Figma 290‑916): katta yumaloq tugma —
/// bosilganda galereyadan rasm tanlab yuklaydi. Yuklangach «Davom etish»
/// tugmasi ko‘rinadi.
class ImageUploadStep extends StatelessWidget {
  const ImageUploadStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<OnboardingBloc>();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          l10n.onbImageTitle
              .s(24.sp)
              .w(700)
              .c(colors.textStrong)
              .a(TextAlign.center)
              .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
          SizedBox(height: 8.h),
          l10n.onbImageSubtitle
              .s(14.sp)
              .w(400)
              .c(colors.textSub)
              .h(20 / 14)
              .a(TextAlign.center)
              .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<OnboardingBloc, OnboardingState>(
                    buildWhen: (p, c) =>
                        p.pickedImagePath != c.pickedImagePath ||
                        p.imageUploading != c.imageUploading ||
                        p.imageUploaded != c.imageUploaded,
                    builder: (context, state) {
                      return _UploadCircle(
                        colors: colors,
                        l10n: l10n,
                        state: state,
                        onTap: () =>
                            bloc.add(const OnboardingImagePickRequested()),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  _HintChip(label: l10n.onbImageHint, colors: colors),
                ],
              ),
            ),
          ),
          BlocBuilder<OnboardingBloc, OnboardingState>(
            buildWhen: (p, c) => p.imageUploaded != c.imageUploaded,
            builder: (context, state) {
              if (!state.imageUploaded) return SizedBox(height: 52.h);
              return CustomButton(
                label: l10n.onbContinue,
                gradient: AppColors.onboardingActionGradient,
                onPressed: () => bloc.add(const OnboardingNextPressed()),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Katta yumaloq yuklash tugmasi: tanlangan rasm / yuklash holati / placeholder.
class _UploadCircle extends StatelessWidget {
  const _UploadCircle({
    required this.colors,
    required this.l10n,
    required this.state,
    required this.onTap,
  });

  final AppColors colors;
  final AppLocalizations l10n;
  final OnboardingState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = state.pickedImagePath != null;

    return GestureDetector(
      onTap: state.imageUploading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 180.r,
        height: 180.r,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.avatarPlaceholder,
            shape: BoxShape.circle,
            border: state.imageUploaded
                ? Border.all(color: colors.successPrimary, width: 3.r)
                : Border.all(color: colors.strokeSoft, width: 1),
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.file(File(state.pickedImagePath!), fit: BoxFit.cover)
                else
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Assets.icons.icHugeiconsCameraAdd.svg(
                          width: 36.r,
                          height: 36.r,
                          colorFilter: ColorFilter.mode(
                            colors.iconSoft,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        l10n.onbImageUpload
                            .s(13.sp)
                            .w(400)
                            .c(colors.textSub)
                            .a(TextAlign.center),
                      ],
                    ),
                  ),
                if (state.imageUploading)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 32.r,
                        height: 32.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.r,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// «Yuzingizni to‘liq ko‘rinsin» pill chipi + scan-face ikoni.
class _HintChip extends StatelessWidget {
  const _HintChip({required this.label, required this.colors});

  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: colors.strokeSoft),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.icLucideScanFace.svg(
              width: 16.r,
              height: 16.r,
              colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: label
                  .s(13.sp)
                  .w(400)
                  .c(colors.textSub)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
