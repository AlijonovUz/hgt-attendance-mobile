import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/bloc/theme/theme_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/attendance_event_type.dart';
import '../bloc/attendance_check_bloc.dart';

/// Davomat yuz-tekshiruvi ekrani (asosiy ekrandan push qilinadi).
///
/// UI login yuz-tasdig‘i ([FaceVerifyPage]) bilan bir xil: foydalanuvchi
/// kartasi + tema/yuz tugmalari + markaziy doira. Kamera + GPS bilan selfie
/// olinib `POST /v1/attendance/attendance/` yuboriladi; muvaffaqiyatda
/// `Navigator.pop(true)` — asosiy ekran bosqichni belgilab profilni qayta
/// GET qiladi.
class AttendanceFacePage extends StatelessWidget {
  const AttendanceFacePage({super.key, required this.eventType});

  final AttendanceEventType eventType;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AttendanceCheckBloc>(
          create: (_) =>
              getIt<AttendanceCheckBloc>()
                ..add(AttendanceCheckStarted(eventType)),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
        ),
      ],
      child: const _AttendanceFaceView(),
    );
  }
}

class _AttendanceFaceView extends StatelessWidget {
  const _AttendanceFaceView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: BlocListener<AttendanceCheckBloc, AttendanceCheckState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: (context, state) {
            if (state.status == AttendanceCheckStatus.success) {
              Navigator.of(context).pop(true);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                const _UserCard(),
                SizedBox(height: 20.h),
                const _Controls(),
                const Spacer(),
                const _Stage(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Foydalanuvchi kartasi: avatar + ism + tasdiq nishoni.
class _UserCard extends StatelessWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.strokeSoft),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Row(
          children: [
            SizedBox(
              width: 44.r,
              height: 44.r,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.avatarPlaceholder,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Assets.icons.icUser.svg(
                    width: 24.r,
                    height: 24.r,
                    colorFilter: ColorFilter.mode(
                      colors.iconSub,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                buildWhen: (p, c) => p.profile?.fullName != c.profile?.fullName,
                builder: (context, state) {
                  final full = state.profile?.fullName.trim() ?? '';
                  final name = full.isNotEmpty ? full : l10n.appName;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      name
                          .s(15.sp)
                          .w(700)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      SizedBox(height: 2.h),
                      l10n.appName
                          .s(13.sp)
                          .w(400)
                          .c(colors.textSoft)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(width: 8.w),
            Assets.icons.icHugeiconsSecurityCheck.svg(
              width: 24.r,
              height: 24.r,
              colorFilter: ColorFilter.mode(
                colors.successPrimary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tema (quyosh) + yuz nishoni tugmalari.
class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          icon: Theme.of(context).brightness == Brightness.dark
              ? Assets.icons.icHugeiconsMoon
              : Assets.icons.icHugeiconsSun,
          colors: colors,
          onTap: () {
            final bloc = context.read<ThemeBloc>();
            final next = Theme.of(context).brightness == Brightness.dark
                ? ThemeMode.light
                : ThemeMode.dark;
            bloc.add(ThemeModeSelected(next));
          },
        ),
        SizedBox(width: 12.w),
        _CircleButton(icon: Assets.icons.icLucideScanFace, colors: colors),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.colors, this.onTap});

  final SvgGenImage icon;
  final AppColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44.r,
        height: 44.r,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1Alt,
            shape: BoxShape.circle,
            border: Border.all(color: colors.strokeSoft),
          ),
          child: Center(
            child: icon.svg(
              width: 20.r,
              height: 20.r,
              colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

/// Markaziy doira (kamera/holat) + ostidagi izoh va «Qayta urinish».
class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AttendanceCheckBloc, AttendanceCheckState>(
      builder: (context, state) {
        if (state.status == AttendanceCheckStatus.permissionDenied ||
            state.status == AttendanceCheckStatus.cameraError) {
          return _ErrorState(state: state, colors: colors, l10n: l10n);
        }

        final diameter = 260.r;
        final borderColor = switch (state.status) {
          AttendanceCheckStatus.success => colors.successPrimary,
          AttendanceCheckStatus.failure => colors.errorStrong,
          _ => colors.accentSub,
        };

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: diameter,
              height: diameter,
              child: Stack(
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
                      child: _CirclePreview(diameter: diameter - 8.r),
                    ),
                  ),
                  // Skan / kuzatuv chizig‘i — faqat ko‘k (skan) holatlarida.
                  if (state.status == AttendanceCheckStatus.scanning ||
                      state.status == AttendanceCheckStatus.detecting ||
                      state.status == AttendanceCheckStatus.verifying)
                    Padding(
                      padding: EdgeInsets.all(4.r),
                      child: ClipOval(child: _ScanLine(color: borderColor)),
                    ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            _hintText(state, l10n)
                .s(15.sp)
                .w(500)
                .c(
                  state.status == AttendanceCheckStatus.failure
                      ? colors.errorStrong
                      : colors.textSub,
                )
                .a(TextAlign.center)
                .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
            if (state.status == AttendanceCheckStatus.failure) ...[
              SizedBox(height: 16.h),
              SizedBox(
                width: 200.w,
                child: CustomButton(
                  label: l10n.faceRetry,
                  onPressed: () => context.read<AttendanceCheckBloc>().add(
                    const AttendanceRetryRequested(),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _hintText(AttendanceCheckState state, AppLocalizations l10n) {
    return switch (state.status) {
      AttendanceCheckStatus.success => l10n.faceHintSuccess,
      AttendanceCheckStatus.verifying ||
      AttendanceCheckStatus.detecting => l10n.faceHintScanning,
      AttendanceCheckStatus.failure => switch (state.failureKind) {
        AttendanceFailureKind.network => l10n.networkError,
        AttendanceFailureKind.location => l10n.attendanceLocationError,
        AttendanceFailureKind.noFace => l10n.faceHintNoFace,
        _ => l10n.faceVerifyFailed,
      },
      _ => l10n.faceHintDefault,
    };
  }
}

/// Kamerani doira ichida (kesilgan, cover) ko‘rsatadi; tirik bo‘lmasa — loader.
class _CirclePreview extends StatelessWidget {
  const _CirclePreview({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final controller = context.read<AttendanceCheckBloc>().cameraController;

    return BlocBuilder<AttendanceCheckBloc, AttendanceCheckState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final live =
            controller != null &&
            controller.value.isInitialized &&
            state.status != AttendanceCheckStatus.success &&
            state.status != AttendanceCheckStatus.failure;

        if (!live) {
          return ClipOval(
            child: ColoredBox(
              color: colors.backgroundElevation2Alt,
              child: Center(
                child: state.status == AttendanceCheckStatus.initializing
                    ? SizedBox(
                        width: 28.r,
                        height: 28.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5.r,
                          valueColor: AlwaysStoppedAnimation(colors.accentSub),
                        ),
                      )
                    : (state.status == AttendanceCheckStatus.success
                              ? Assets.icons.icHugeiconsSecurityCheck
                              : Assets.icons.icLucideScanFace)
                          .svg(
                            width: 64.r,
                            height: 64.r,
                            colorFilter: ColorFilter.mode(
                              state.status == AttendanceCheckStatus.success
                                  ? colors.successPrimary
                                  : colors.iconSoft,
                              BlendMode.srcIn,
                            ),
                          ),
              ),
            ),
          );
        }

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
      },
    );
  }
}

/// Doira ichida yuqoridan pastga takror harakatlanuvchi skan chizig‘i — kuzatuv
/// ko‘rsatkichi (Figma «scan» holati). Bitta `AnimationController` — silliq.
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

/// Ruxsat berilmadi / kamera xatosi holati.
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.state,
    required this.colors,
    required this.l10n,
  });

  final AttendanceCheckState state;
  final AppColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isPermission = state.status == AttendanceCheckStatus.permissionDenied;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPermission
              ? Icons.no_photography_outlined
              : Icons.videocam_off_outlined,
          size: 56.r,
          color: colors.errorStrong,
        ),
        SizedBox(height: 16.h),
        (isPermission ? l10n.facePermissionTitle : l10n.faceCameraError)
            .s(16.sp)
            .w(700)
            .c(colors.textStrong)
            .a(TextAlign.center)
            .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
        if (isPermission) ...[
          SizedBox(height: 8.h),
          l10n.facePermissionBody
              .s(14.sp)
              .w(400)
              .c(colors.textSub)
              .h(20 / 14)
              .a(TextAlign.center)
              .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
          SizedBox(height: 20.h),
          SizedBox(
            width: 220.w,
            child: CustomButton(
              label: l10n.facePermissionOpenSettings,
              onPressed: openAppSettings,
            ),
          ),
        ],
      ],
    );
  }
}
