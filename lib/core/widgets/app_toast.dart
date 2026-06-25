import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/routes/coordinator.dart';
import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// Toast turi — har biri o‘z rang/ikon kombinatsiyasiga ega.
enum AppToastType { success, error, warning, info }

/// Custom toast — `Overlay` orqali ko‘rsatiladi, paket shart emas.
///
/// Bitta vaqtda faqat bitta toast ko‘rinadi (yangisi eskisini almashtiradi).
/// Chaqirish: `context.showSuccessToast('...')` / `context.showErrorToast('...')`
/// ([core/extentions/toast_extension.dart]).
class AppToast {
  AppToast._();

  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = rootNavigatorKey.currentState?.overlay ??
        Overlay.of(context, rootOverlay: true);

    _entry?.remove();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: _ToastBanner(
          message: message,
          type: type,
          duration: duration,
          onDismissed: () {
            if (identical(_entry, entry)) _entry = null;
            entry.remove();
          },
        ),
      ),
    );
    _entry = entry;
    overlayState.insert(entry);
  }
}

class _ToastBanner extends StatefulWidget {
  const _ToastBanner({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final AppToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_ToastBanner> createState() => _ToastBannerState();
}

class _ToastBannerState extends State<_ToastBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _close);
  }

  Future<void> _close() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final cfg = _ToastStyle.of(widget.type, colors);

    return SafeArea(
      bottom: false,
      child: SlideTransition(
        position: _offset,
        child: FadeTransition(
          opacity: _controller,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _close,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cfg.background,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(color: cfg.border),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 12.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: cfg.iconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6.r),
                            child: cfg.icon.svg(
                              width: 16.r,
                              height: 16.r,
                              colorFilter: ColorFilter.mode(
                                colors.iconWhite,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: widget.message
                              .s(13.sp)
                              .w(600)
                              .c(cfg.textColor)
                              .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(width: 8.w),
                        Assets.icons.icExclude.svg(
                          width: 14.r,
                          height: 14.r,
                          colorFilter:
                              ColorFilter.mode(cfg.textColor, BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Turga mos rang/ikon to‘plami — `AppColors` tokenlaridan quriladi.
class _ToastStyle {
  const _ToastStyle({
    required this.background,
    required this.border,
    required this.iconBg,
    required this.textColor,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color iconBg;
  final Color textColor;
  final SvgGenImage icon;

  static _ToastStyle of(AppToastType type, AppColors colors) {
    switch (type) {
      case AppToastType.success:
        return _ToastStyle(
          background: colors.successSoft,
          border: colors.successStrong,
          iconBg: colors.successStrong,
          textColor: colors.successStrong,
          icon: Assets.icons.icHugeiconsCheckmarkBadge,
        );
      case AppToastType.error:
        return _ToastStyle(
          background: colors.errorSoft,
          border: colors.errorStrong,
          iconBg: colors.errorStrong,
          textColor: colors.errorStrong,
          icon: Assets.icons.icLucideShieldAlert,
        );
      case AppToastType.warning:
        return _ToastStyle(
          background: AppColors.warningStrong.withValues(alpha: 0.12),
          border: AppColors.warningStrong,
          iconBg: AppColors.warningStrong,
          textColor: AppColors.warningStrong,
          icon: Assets.icons.icLucideShieldAlert,
        );
      case AppToastType.info:
        return _ToastStyle(
          background: colors.accentStrong.withValues(alpha: 0.12),
          border: colors.accentStrong,
          iconBg: colors.accentStrong,
          textColor: colors.accentStrong,
          icon: Assets.icons.icHugeiconsNotification,
        );
    }
  }
}
