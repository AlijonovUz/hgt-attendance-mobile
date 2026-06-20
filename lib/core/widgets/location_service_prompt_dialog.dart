import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../../injection_container.dart';
import '../../l10n/app_localizations.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';
import '../services/location_service.dart';
import 'custom_button.dart';

/// «Joylashuv xizmati o‘chiq» modali — qurilmada GPS o‘chiq bo‘lsa, uni yoqishni
/// so‘raydi. Ilova umumiy dizayniga mos (radius-3xl karta, `AppColors`,
/// `CustomButton`).
///
/// «Yoqish» bosilganda qurilma joylashuv sozlamalari ochiladi; foydalanuvchi
/// ilovaga qaytganda xizmat holati qayta tekshiriladi va yoqilgan bo‘lsa modal
/// avtomatik yopilib `true` qaytaradi. «Keyinroq» — `false`.
///
/// Qaytadi: GPS endi yoqilgan bo‘lsa `true`, aks holda `false`.
Future<bool> showLocationServicePrompt(BuildContext context) async {
  final colors = AppColors.of(context);
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: colors.black.withValues(alpha: 0.30),
    builder: (_) => const _LocationServicePromptDialog(),
  );
  return result ?? false;
}

class _LocationServicePromptDialog extends StatefulWidget {
  const _LocationServicePromptDialog();

  @override
  State<_LocationServicePromptDialog> createState() =>
      _LocationServicePromptDialogState();
}

class _LocationServicePromptDialogState
    extends State<_LocationServicePromptDialog> with WidgetsBindingObserver {
  final LocationService _location = getIt<LocationService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Foydalanuvchi sozlamalardan qaytganda (resumed) GPS yoqilganini tekshiramiz.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _recheck();
  }

  Future<void> _recheck() async {
    final enabled = await _location.isServiceEnabled();
    if (enabled && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _onEnable() async {
    await _location.openLocationSettings();
    // Sozlamalardan qaytish `didChangeAppLifecycleState`da ushlanadi; ba’zi
    // qurilmalarda lifecycle o‘tmasligi mumkin — shu yerda ham tekshiramiz.
    await _recheck();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
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
                Center(
                  child: SizedBox(
                    width: 72.r,
                    height: 72.r,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.backgroundElevation1Alt,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.strokeSoft),
                      ),
                      child: Center(
                        child: Assets.icons.icHugeiconsLocationShare.svg(
                          width: 32.r,
                          height: 32.r,
                          colorFilter: ColorFilter.mode(
                            colors.accentSub,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                l10n.locationServiceTitle
                    .s(18.sp)
                    .w(600)
                    .c(colors.textStrong)
                    .h(26 / 18)
                    .a(TextAlign.center)
                    .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.h),
                l10n.locationServiceBody
                    .s(14.sp)
                    .w(400)
                    .c(colors.textSub)
                    .h(20 / 14)
                    .a(TextAlign.center)
                    .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
                SizedBox(height: 24.h),
                CustomButton(
                  label: l10n.locationServiceEnable,
                  onPressed: _onEnable,
                ),
                SizedBox(height: 8.h),
                CustomButton(
                  label: l10n.locationServiceLater,
                  variant: CustomButtonVariant.text,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
