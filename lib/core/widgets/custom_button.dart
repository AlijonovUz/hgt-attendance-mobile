import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';

/// Tugma ko‘rinishlari.
enum CustomButtonVariant {
  /// To‘ldirilgan asosiy tugma (`accent-sub` fon, oq yozuv).
  primary,

  /// Faqat ramkali tugma.
  outline,

  /// Fonsiz, faqat yozuvli tugma.
  text,
}

/// Loyihaning umumiy tugmasi.
///
/// Figma "Button / L" ga 1:1 mos: 52 balandlik, 16 radius, Manrope Medium 15/24.
/// Holatlar: yoqilgan, o‘chirilgan (`control/bg/disabled` + `control/text/disabled`),
/// yuklanmoqda (spinner). `onPressed == null` yoki [isLoading] bo‘lsa avtomatik o‘chadi.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.variant = CustomButtonVariant.primary,
    this.expand = true,
    this.leading,
    this.trailing,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final CustomButtonVariant variant;

  /// To‘liq enga cho‘zilsinmi.
  final bool expand;
  final Widget? leading;
  final Widget? trailing;
  final double? height;

  bool get _isInteractive => enabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(10.r);

    final (Color background, Color foreground, BorderSide side) = _resolveStyle(
      colors,
    );

    final content = isLoading
        ? SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.r,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, SizedBox(width: 8.w)],
              Flexible(
                child: label
                    .s(15.sp)
                    .w(500)
                    .c(foreground)
                    .copyWith(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
              if (trailing != null) ...[SizedBox(width: 8.w), trailing!],
            ],
          );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height ?? 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: side == BorderSide.none ? null : Border.fromBorderSide(side),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _isInteractive ? onPressed : null,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, BorderSide) _resolveStyle(AppColors colors) {
    if (!_isInteractive) {
      return switch (variant) {
        CustomButtonVariant.primary => (
          colors.controlBgDisabled,
          colors.controlTextDisabled,
          BorderSide.none,
        ),
        CustomButtonVariant.outline => (
          colors.white.withValues(alpha: 0),
          colors.controlTextDisabled,
          BorderSide(color: colors.strokeSub, width: 1),
        ),
        CustomButtonVariant.text => (
          colors.white.withValues(alpha: 0),
          colors.controlTextDisabled,
          BorderSide.none,
        ),
      };
    }
    return switch (variant) {
      CustomButtonVariant.primary => (
        colors.accentStrong,
        colors.textWhite,
        BorderSide.none,
      ),
      CustomButtonVariant.outline => (
        colors.white.withValues(alpha: 0),
        colors.accentSub,
        BorderSide(color: colors.strokeAccent, width: 1),
      ),
      CustomButtonVariant.text => (
        colors.white.withValues(alpha: 0),
        colors.accentSub,
        BorderSide.none,
      ),
    };
  }
}
