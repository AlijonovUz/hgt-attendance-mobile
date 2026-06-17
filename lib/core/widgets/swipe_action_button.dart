import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// Surib tasdiqlanadigan maxsus tugma (Figma 301:9545 / 301:10142).
///
/// Barmoq bilan o‘ngga surilganda:
/// - chapdan [fillGradient] silliq ochiladi (yorqin @50% → to‘q asos),
/// - dumaloq dasta (handle) barmoq bilan birga suriladi,
/// - yozuv rangi passiv (`swipeIdleText`) → faol (oq) ga interpolatsiya bo‘ladi.
///
/// Qo‘yib yuborilganda: chегaradan (`completeThreshold`) o‘tgan bo‘lsa — oxirga
/// silliq tugaydi va [onCompleted] chaqiriladi; aks holda boshiga qaytadi.
///
/// Gradient/yo‘lak/dasta ranglari to‘liq parametrlanadi — bitta komponent har
/// xil amallar (ishga kelish — ko‘k, tushlik — sariq, …) uchun ishlatiladi.
class SwipeActionButton extends StatefulWidget {
  const SwipeActionButton({
    super.key,
    required this.label,
    required this.onCompleted,
    this.fillGradient = AppColors.swipeArriveGradient,
    this.trackColor = AppColors.swipeTrackBlue,
    this.handleColor,
    this.handleIconColor,
    this.idleTextColor = AppColors.swipeIdleText,
    this.activeTextColor,
    this.icon,
    this.enabled = true,
    this.resetAfterComplete = false,
    this.height = 56,
    this.handleSize = 52,
    this.handleInset = 2,
    this.completeThreshold = 0.85,
  });

  /// Markazdagi yozuv.
  final String label;

  /// Surish muvaffaqiyatli tugaganda chaqiriladi.
  final VoidCallback onCompleted;

  /// Surilganda ochiladigan fon gradienti.
  final Gradient fillGradient;

  /// To‘ldirilmagan yo‘lak foni (Figma: har ikki rejimda ham och).
  final Color trackColor;

  /// Dumaloq dasta foni (default: gradient oxirgi rangi).
  final Color? handleColor;

  /// Dastadagi ikonka rangi (default: oq).
  final Color? handleIconColor;

  /// Boshlang‘ich (surilmagan) yozuv rangi.
  final Color idleTextColor;

  /// To‘liq surilgandagi yozuv rangi (default: oq).
  final Color? activeTextColor;

  /// Dastadagi ikonka (default: ikki o‘qli o‘ng strelka).
  final Widget? icon;

  final bool enabled;

  /// Tugagach boshiga qaytsinmi (qayta surish uchun).
  final bool resetAfterComplete;

  final double height;
  final double handleSize;

  /// Dasta atrofidagi bo‘shliq (yo‘lak chetidan).
  final double handleInset;

  /// Tasdiq uchun zarur minimal surish ulushi (0..1).
  final double completeThreshold;

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

class _SwipeActionButtonState extends State<SwipeActionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller; // value = surish ulushi (0..1)
  double _maxDrag = 1;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!widget.enabled || _completed) return;
    _controller.value += d.primaryDelta! / _maxDrag;
  }

  Future<void> _onDragEnd(DragEndDetails d) async {
    if (!widget.enabled || _completed) return;
    if (_controller.value >= widget.completeThreshold) {
      _completed = true;
      await _controller.animateTo(1, duration: const Duration(milliseconds: 160), curve: Curves.easeOut);
      widget.onCompleted();
      if (widget.resetAfterComplete && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 240));
        await _controller.animateBack(0, curve: Curves.easeOut);
        _completed = false;
      }
    } else {
      await _controller.animateBack(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOutBack.flipped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final gradient = widget.fillGradient;
    final handleColor = widget.handleColor ?? (gradient is LinearGradient ? gradient.colors.last : colors.accentStrong);
    final handleIconColor = widget.handleIconColor ?? colors.white;
    final activeText = widget.activeTextColor ?? colors.white;

    final height = widget.height.h;
    // Dasta/inset — yo‘lak balandligiga bog‘liq, shuning uchun ham `.h` bilan
    // shkalalanadi (`.w` bilan aralashtirilsa qurilma nisbati o‘zgarganda dasta
    // yo‘lakka sig‘maydi yoki chetidan chiqib ketadi).
    final handle = widget.handleSize.h;
    final inset = widget.handleInset.h;
    final radius = BorderRadius.circular(22.r);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        _maxDrag = (width - handle - inset * 2).clamp(1.0, double.infinity);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final handleLeft = inset + t * _maxDrag;
            // To‘ldiruvchi — faqat surilgan ulush (dastadan `inset` qadar
            // ajralib turadi). Rest holatda (t=0) eni 0 — Figma'dagidek dasta
            // chap chetda turadi, gradient umuman ko‘rinmaydi.
            final fillWidth = t * _maxDrag;
            final textColor = Color.lerp(widget.idleTextColor, activeText, (t * 1.6).clamp(0.0, 1.0))!;

            return DecoratedBox(
              decoration: BoxDecoration(
                color: widget.trackColor,
                borderRadius: radius,
                border: Border.all(color: AppColors.swipeTrackBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000), // shadow-2xs
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: SizedBox(
                height: height,
                child: ClipRRect(
                  borderRadius: radius,
                  child: Stack(
                    children: [
                      // Silliq ochiladigan gradient to‘ldiruvchi (alohida pill).
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: fillWidth.clamp(0.0, width),
                        child: DecoratedBox(
                          decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
                        ),
                      ),
                      // Markazdagi yozuv (to‘liq enga nisbatan markazda).
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: widget.label.s(16.sp).w(600).c(textColor).h(24 / 16).copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                      // Dumaloq dasta.
                      Positioned(
                        left: handleLeft,
                        top: inset,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragUpdate: _onDragUpdate,
                          onHorizontalDragEnd: _onDragEnd,
                          child: Container(
                            width: handle,
                            height: handle,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: handleColor,
                              shape: BoxShape.circle,
                              boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2))],
                            ),
                            child:
                                widget.icon ??
                                Assets.icons.icHugeiconsArrowRightDoubleRound.svg(
                                  width: 24.r,
                                  height: 24.r,
                                  colorFilter: ColorFilter.mode(handleIconColor, BlendMode.srcIn),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
