import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/face/bloc/face_verify_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../painters/face_inset_painter.dart';
import 'onboarding_action_button.dart';

/// Onboarding 5‑bosqich: yuz tasdig‘i (Figma 296‑2886 / 299‑8095).
///
/// Katta doirada tirik kamera + skan chizig‘i; pastki‑chap burchakda referens
/// rasm (login’dan yoki yuklangan) — [FaceInsetPainter] bilan chiziladi. «Skaner-
/// lashni boshlash» bosilganda kamera ishga tushadi; yuz barqaror aniqlansa
/// avtomatik selfie olinib tasdiqlanadi. Muvaffaqiyatda
/// `OnboardingFaceVerifiedReported` yuboriladi (oqim yakuniy bosqichga o‘tadi).
class FaceVerifyStep extends StatelessWidget {
  const FaceVerifyStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FaceVerifyBloc>(
      create: (_) => getIt<FaceVerifyBloc>(),
      child: const _FaceVerifyBody(),
    );
  }
}

class _FaceVerifyBody extends StatefulWidget {
  const _FaceVerifyBody();

  @override
  State<_FaceVerifyBody> createState() => _FaceVerifyBodyState();
}

class _FaceVerifyBodyState extends State<_FaceVerifyBody> {
  bool _started = false;

  void _start(BuildContext context) {
    final data = context.read<OnboardingBloc>().state.data;
    setState(() => _started = true);
    context.read<FaceVerifyBloc>().add(
      FaceStarted(accessToken: data.accessToken, fullName: data.fullName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    // watch — referens rasm (yuklangan rasm) oldingi bosqichda o‘zgarsa yangilanadi.
    final onboarding = context.watch<OnboardingBloc>().state;

    return BlocListener<FaceVerifyBloc, FaceVerifyState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == FaceStatus.success) {
          context.read<OnboardingBloc>().add(
            const OnboardingFaceVerifiedReported(),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            l10n.onbFaceTitle
                .s(24.sp)
                .w(700)
                .c(colors.textStrong)
                .a(TextAlign.center)
                .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 8.h),
            l10n.onbFaceSubtitle
                .s(14.sp)
                .w(400)
                .c(colors.textSub)
                .h(20 / 14)
                .a(TextAlign.center)
                .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
            Expanded(
              child: Center(
                child: _FaceStage(
                  started: _started,
                  referenceUrl: onboarding.referenceImageUrl,
                  referencePath: onboarding.referenceImagePath,
                ),
              ),
            ),
            _FaceBottomButton(
              started: _started,
              l10n: l10n,
              onStart: () => _start(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yagona pastki tugma — holatga qarab boshlash / qayta urinish / sozlamalar
/// yoki bo‘sh (jarayon / muvaffaqiyat).
class _FaceBottomButton extends StatelessWidget {
  const _FaceBottomButton({
    required this.started,
    required this.l10n,
    required this.onStart,
  });

  final bool started;
  final AppLocalizations l10n;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    if (!started) {
      return OnboardingActionButton(
        label: l10n.onbFaceStart,
        onPressed: onStart,
      );
    }
    return BlocBuilder<FaceVerifyBloc, FaceVerifyState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final bloc = context.read<FaceVerifyBloc>();
        switch (state.status) {
          case FaceStatus.permissionDenied:
            return OnboardingActionButton(
              label: l10n.facePermissionOpenSettings,
              gradient: false,
              onPressed: openAppSettings,
            );
          case FaceStatus.failure:
          case FaceStatus.cameraError:
            return OnboardingActionButton(
              label: l10n.faceRetry,
              onPressed: () => bloc.add(const FaceRetryRequested()),
            );
          case FaceStatus.initializing:
          case FaceStatus.scanning:
          case FaceStatus.detecting:
          case FaceStatus.verifying:
          case FaceStatus.success:
            return SizedBox(height: 52.h);
        }
      },
    );
  }
}

/// Katta doira (kamera/referens) + skan chizig‘i + pastki‑chap referens rasm.
class _FaceStage extends StatelessWidget {
  const _FaceStage({
    required this.started,
    this.referenceUrl,
    this.referencePath,
  });

  final bool started;
  final String? referenceUrl;
  final String? referencePath;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<FaceVerifyBloc, FaceVerifyState>(
      builder: (context, state) {
        final diameter = 260.r;
        final borderColor = switch (state.status) {
          FaceStatus.success => colors.successPrimary,
          FaceStatus.failure => colors.errorStrong,
          _ => colors.accentSub,
        };
        final live = started && state.isCameraLive;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: diameter,
              height: diameter,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.backgroundElevation1,
                      border: Border.all(color: borderColor, width: 2.5.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: _CirclePreview(
                        diameter: diameter - 8.r,
                        started: started,
                        referenceUrl: referenceUrl,
                        referencePath: referencePath,
                      ),
                    ),
                  ),
                  if (live)
                    Padding(
                      padding: EdgeInsets.all(4.r),
                      child: ClipOval(child: _ScanLine(color: borderColor)),
                    ),
                  Positioned(
                    left: -6.r,
                    bottom: 6.r,
                    child: _ReferenceThumbnail(
                      url: referenceUrl,
                      path: referencePath,
                      size: 84.r,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _hintText(started, state, l10n)
                .s(15.sp)
                .w(500)
                .c(
                  state.status == FaceStatus.failure
                      ? colors.errorStrong
                      : colors.textSub,
                )
                .a(TextAlign.center)
                .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        );
      },
    );
  }

  String _hintText(bool started, FaceVerifyState state, AppLocalizations l10n) {
    if (!started) return l10n.onbFaceSubtitle;
    return switch (state.status) {
      FaceStatus.success => l10n.faceHintSuccess,
      FaceStatus.verifying || FaceStatus.detecting => l10n.faceHintScanning,
      FaceStatus.scanning => l10n.faceHintDefault,
      FaceStatus.failure =>
        state.failureKind == FaceFailureKind.network
            ? l10n.networkError
            : (state.failureMessage ?? l10n.faceVerifyFailed),
      FaceStatus.permissionDenied => l10n.facePermissionBody,
      FaceStatus.cameraError => l10n.faceCameraError,
      FaceStatus.initializing => l10n.faceHintDefault,
    };
  }
}

/// Katta doira ichidagi tirik kamera (yoki referens rasm / placeholder).
class _CirclePreview extends StatelessWidget {
  const _CirclePreview({
    required this.diameter,
    required this.started,
    this.referenceUrl,
    this.referencePath,
  });

  final double diameter;
  final bool started;
  final String? referenceUrl;
  final String? referencePath;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final controller = context.read<FaceVerifyBloc>().cameraController;

    return BlocBuilder<FaceVerifyBloc, FaceVerifyState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final live =
            started &&
            controller != null &&
            controller.value.isInitialized &&
            state.isCameraLive;

        if (live) {
          final preview = controller.value.previewSize!;
          return ClipOval(
            child: SizedBox(
              width: diameter,
              height: diameter,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: preview.height,
                  height: preview.width,
                  child: CameraPreview(controller),
                ),
              ),
            ),
          );
        }

        // Tirik emas — muvaffaqiyatda check, aks holda referens rasm/placeholder.
        if (state.status != FaceStatus.success) {
          final provider = _imageProvider(referenceUrl, referencePath);
          if (provider != null) {
            return ClipOval(
              child: SizedBox(
                width: diameter,
                height: diameter,
                child: Image(image: provider, fit: BoxFit.cover),
              ),
            );
          }
        }

        return ClipOval(
          child: ColoredBox(
            color: colors.backgroundElevation2Alt,
            child: Center(
              child:
                  (state.status == FaceStatus.success
                          ? Assets.icons.icHugeiconsSecurityCheck
                          : Assets.icons.icLucideScanFace)
                      .svg(
                        width: 64.r,
                        height: 64.r,
                        colorFilter: ColorFilter.mode(
                          state.status == FaceStatus.success
                              ? colors.successPrimary
                              : colors.iconSoft,
                          BlendMode.srcIn,
                        ),
                      ),
            ),
          ),
        );
      },
    );
  }
}

ImageProvider? _imageProvider(String? url, String? path) {
  if (path != null && path.trim().isNotEmpty) return FileImage(File(path));
  if (url != null && url.trim().isNotEmpty) return NetworkImage(url);
  return null;
}

/// Pastki‑chap kichik referens rasm — `CustomPaint` + [FaceInsetPainter].
class _ReferenceThumbnail extends StatefulWidget {
  const _ReferenceThumbnail({this.url, this.path, required this.size});

  final String? url;
  final String? path;
  final double size;

  @override
  State<_ReferenceThumbnail> createState() => _ReferenceThumbnailState();
}

class _ReferenceThumbnailState extends State<_ReferenceThumbnail> {
  ui.Image? _image;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(_ReferenceThumbnail old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url || old.path != widget.path) _resolve();
  }

  void _resolve() {
    final provider = _imageProvider(widget.url, widget.path);
    if (provider == null) return;
    final stream = provider.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _detach();
    _stream = stream;
    _listener = ImageStreamListener((info, _) {
      if (mounted) setState(() => _image = info.image);
    }, onError: (_, _) {});
    stream.addListener(_listener!);
  }

  void _detach() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: FaceInsetPainter(
          image: _image,
          ringColor: colors.white,
          placeholderColor: colors.backgroundElevation2Alt,
          ringWidth: 3.r,
        ),
      ),
    );
  }
}

/// Doira ichida yuqori‑past harakatlanuvchi skan chizig‘i.
class _ScanLine extends StatefulWidget {
  const _ScanLine({required this.color});

  final Color color;

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _y = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return AnimatedBuilder(
      animation: _y,
      builder: (context, _) {
        return Align(
          alignment: Alignment(0, _y.value * 2 - 1),
          child: SizedBox(
            width: double.infinity,
            height: 2.r,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0),
                    color,
                    color.withValues(alpha: 0),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8.r,
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
