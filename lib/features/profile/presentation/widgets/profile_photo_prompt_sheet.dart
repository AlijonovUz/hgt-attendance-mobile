import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/profile_bloc.dart';

/// «Shaxsiy rasm o‘rnating» modali (Figma `Bottom-sheet`) — markazlashgan karta:
/// sarlavha + uzuq-uzuq doira (rasm tanlash) + «Yuklash» tugmasi. Rasm
/// qurilmadan tanlanadi va PATCH `face_image` bilan yuklanadi.
///
/// [bloc] — home’dagi mavjud `ProfileBloc` (BlocProvider.value bilan uzatiladi),
/// shunda tanlash/yuklash bir holatda kechadi.
/// [dismissible] `false` bo‘lsa modal majburiy — scrim/back orqali yopilmaydi
/// (yuz tasdig‘idan oldingi bosqich: rasm shart). Yuklash muvaffaqiyatli
/// tugagachgina yopiladi.
Future<void> showProfilePhotoPrompt(
  BuildContext context,
  ProfileBloc bloc, {
  bool dismissible = true,
}) {
  final colors = AppColors.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: dismissible,
    barrierColor: colors.black.withValues(alpha: 0.30),
    builder: (_) => BlocProvider<ProfileBloc>.value(
      value: bloc,
      child: _ProfilePhotoPromptSheet(dismissible: dismissible),
    ),
  );
}

class _ProfilePhotoPromptSheet extends StatelessWidget {
  const _ProfilePhotoPromptSheet({required this.dismissible});

  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: dismissible,
      child: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (p, c) => p.uploadStatus != c.uploadStatus,
        listener: (context, state) {
          if (state.uploadStatus == ProfileUploadStatus.success) {
            Navigator.of(context).pop();
          }
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1,
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                l10n.profilePhotoPromptTitle
                    .s(20.sp)
                    .w(600)
                    .c(colors.textStrong)
                    .h(28 / 20)
                    .a(TextAlign.center)
                    .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
                SizedBox(height: 16.h),
                const Center(child: _PhotoPicker()),
                SizedBox(height: 24.h),
                const _UploadError(),
                const _UploadButton(),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

/// Uzuq-uzuq doira: tanlangan rasm yoki «Rasm yuklash» placeholderi. Bosilganda
/// qurilmadan rasm tanlaydi.
class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (p, c) => p.pickedImagePath != c.pickedImagePath,
      builder: (context, state) {
        final size = 150.r;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context
              .read<ProfileBloc>()
              .add(const ProfilePhotoPickRequested(ImageSourceKind.gallery)),
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _DashedCirclePainter(
                color: colors.strokeStrong,
                strokeWidth: 1.5,
                dashLength: 6,
                gapLength: 6,
              ),
              child: state.hasPickedImage
                  ? Padding(
                      padding: EdgeInsets.all(4.r),
                      child: ClipOval(
                        child: Image.file(
                          File(state.pickedImagePath!),
                          fit: BoxFit.cover,
                          width: size,
                          height: size,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.icProfile.svg(
                          width: 24.r,
                          height: 24.r,
                          colorFilter: ColorFilter.mode(
                            colors.iconSub,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        l10n.profilePhotoUploadLabel
                            .s(14.sp)
                            .w(400)
                            .c(colors.textSub)
                            .h(20 / 14)
                            .a(TextAlign.center)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _UploadError extends StatelessWidget {
  const _UploadError();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (p, c) =>
          p.uploadStatus != c.uploadStatus ||
          p.uploadErrorKind != c.uploadErrorKind,
      builder: (context, state) {
        if (state.uploadStatus != ProfileUploadStatus.failure) {
          return const SizedBox.shrink();
        }
        final text = switch (state.uploadErrorKind) {
          ProfileErrorKind.network => l10n.networkError,
          _ => l10n.profileUploadFailed,
        };
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: text
              .s(13.sp)
              .w(500)
              .c(colors.errorStrong)
              .h(18 / 13)
              .a(TextAlign.center)
              .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (p, c) =>
          p.uploadStatus != c.uploadStatus ||
          p.hasPickedImage != c.hasPickedImage,
      builder: (context, state) {
        final bloc = context.read<ProfileBloc>();
        return CustomButton(
          label: l10n.profilePhotoUploadButton,
          isLoading: state.isUploading,
          onPressed: () {
            if (state.hasPickedImage) {
              bloc.add(const ProfilePhotoSubmitted());
            } else {
              bloc.add(
                const ProfilePhotoPickRequested(ImageSourceKind.gallery),
              );
            }
          },
        );
      },
    );
  }
}

/// Uzuq-uzuq aylana ramka chizadi (radius-full placeholder doirasi uchun).
class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * math.pi * radius;
    final step = dashLength + gapLength;
    final dashCount = (circumference / step).floor();
    final dashAngle = dashLength / radius;
    final gapAngle = (2 * math.pi - dashCount * dashAngle) / dashCount;

    var angle = -math.pi / 2;
    for (var i = 0; i < dashCount; i++) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, angle, dashAngle, false, paint);
      angle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}
