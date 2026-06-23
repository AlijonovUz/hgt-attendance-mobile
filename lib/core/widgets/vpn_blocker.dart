import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../../injection_container.dart';
import '../../l10n/app_localizations.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';
import '../services/vpn_detector_service.dart';

/// Butun ilova ustidan VPN’ni bloklovchi qatlam.
///
/// [App] builder’ida MaterialApp navigatori ustiga o‘raladi — shuning uchun
/// istalgan ekran (login, yuz tasdig‘i, home, dialoglar) ochiq bo‘lganda ham
/// VPN aniqlansa, ustdan to‘sib turuvchi oyna chiqadi. Oyna [VpnDetectorService]
/// oqimini tinglaydi: VPN o‘chirilishi bilan avtomatik yopiladi. Tashqariga
/// bosib yoki «orqaga» bilan yopib bo‘lmaydi.
class VpnBlocker extends StatefulWidget {
  const VpnBlocker({required this.child, super.key});

  final Widget child;

  @override
  State<VpnBlocker> createState() => _VpnBlockerState();
}

class _VpnBlockerState extends State<VpnBlocker> {
  final VpnDetectorService _vpn = getIt<VpnDetectorService>();
  StreamSubscription<bool>? _sub;
  bool _vpnOn = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _sub = _vpn.stream.listen(_onVpnChanged);
    // Ilova ochilganda darhol bir marta tekshiramiz (oqim faqat o‘zgarishda
    // emit qiladi — boshlang‘ich holat shu yerda olinadi).
    _recheck();
  }

  void _onVpnChanged(bool on) {
    if (mounted && on != _vpnOn) setState(() => _vpnOn = on);
  }

  Future<void> _recheck() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final on = await _vpn.isActive();
      if (mounted) setState(() => _vpnOn = on);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          widget.child,
          if (_vpnOn)
            Positioned.fill(
              child: _VpnOverlay(checking: _checking, onRecheck: _recheck),
            ),
        ],
      ),
    );
  }
}

class _VpnOverlay extends StatelessWidget {
  const _VpnOverlay({required this.checking, required this.onRecheck});

  final bool checking;
  final VoidCallback onRecheck;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    // Orqaga tugmasini bloklaymiz — VPN o‘chmaguncha qatlamdan chiqib bo‘lmaydi.
    return PopScope(
      canPop: false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: ColoredBox(
          color: colors.black.withValues(alpha: 0.55),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.backgroundElevation2,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 20.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.errorSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Assets.icons.icLucideShieldAlert.svg(
                            width: 32.r,
                            height: 32.r,
                            colorFilter: ColorFilter.mode(
                              colors.errorStrong,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      l10n.vpnBlockedTitle
                          .s(18.sp)
                          .w(700)
                          .c(colors.textStrong)
                          .h(24 / 18)
                          .a(TextAlign.center)
                          .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 10.h),
                      l10n.vpnBlockedBody
                          .s(13.sp)
                          .w(400)
                          .c(colors.textSub)
                          .h(18 / 13)
                          .a(TextAlign.center)
                          .copyWith(maxLines: 5, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 24.h),
                      _RecheckButton(
                        label: l10n.vpnRecheck,
                        loading: checking,
                        onTap: onRecheck,
                        colors: colors,
                      ),
                    ],
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

class _RecheckButton extends StatelessWidget {
  const _RecheckButton({
    required this.label,
    required this.loading,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool loading;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r);
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.accentStrong, borderRadius: radius),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: loading ? null : onTap,
            borderRadius: radius,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.textWhite),
                      ),
                    )
                  : label
                      .s(15.sp)
                      .w(600)
                      .c(colors.textWhite)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}
