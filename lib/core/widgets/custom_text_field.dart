import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// Loyihaning umumiy kiritish maydoni.
///
/// Figma "Input" komponentiga 1:1 mos: `background-elevation-1-alt` fon,
/// `stroke-soft` ramka, 16 radius, 18/15/16/17 ichki padding, Manrope Medium 15/24.
/// Holatlar: oddiy, fokus (`stroke-accent`), xato (`error-strong`), o‘chirilgan.
/// Validatsiya uchun [TextFormField] ustiga qurilgan — `validator`, `autovalidateMode`
/// to‘liq ishlaydi.
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.initialValue,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.hasError = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.autovalidateMode,
    this.autofocus = false,
    this.backgroundColor,
    this.disabledBackgroundColor,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  /// Parol maydoni uchun matnni yashirish.
  final bool obscureText;

  /// Yashirish/ko‘rsatish tugmasini ko‘rsatish (parol uchun qulay).
  final bool showObscureToggle;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  /// Tashqi (server) xato — validatordan mustaqil ravishda qizil ramka chizadi.
  final bool hasError;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final AutovalidateMode? autovalidateMode;
  final bool autofocus;

  /// Yoqilgan holatdagi fon (`fillColor`) — berilmasa `backgroundElevation1Alt`.
  final Color? backgroundColor;

  /// O‘chirilgan holatdagi fon — berilmasa `controlBgDisabled`.
  final Color? disabledBackgroundColor;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured = widget.obscureText;

  /// Matn bormi — yashirish/ko‘rsatish tugmasi faqat matn kiritilganda chiqadi.
  late bool _hasText =
      (widget.controller?.text ?? widget.initialValue ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final has = widget.controller!.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  void _syncHasText(String value) {
    final has = value.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final radius = BorderRadius.circular(8.r);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );

    // Tashqi xato bo‘lsa oddiy/fokus ramkalar ham qizil bo‘ladi.
    final idleStroke = widget.hasError ? colors.errorStrong : colors.strokeSoft;
    final focusStroke = widget.hasError
        ? colors.errorStrong
        : colors.strokeAccent;

    final textStyle = kBaseTextStyle.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: widget.enabled ? colors.textStrong : colors.textDisabled,
    );

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      initialValue: widget.controller == null ? widget.initialValue : null,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscured,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: _obscured ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: (v) {
        _syncHasText(v);
        widget.onChanged?.call(v);
      },
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      inputFormatters: widget.inputFormatters,
      autovalidateMode: widget.autovalidateMode,
      style: textStyle,
      cursorColor: colors.accentSub,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: widget.enabled
            ? (widget.backgroundColor ?? colors.backgroundElevation1Alt)
            : (widget.disabledBackgroundColor ?? colors.controlBgDisabled),
        hintText: widget.hintText,
        labelText: widget.labelText,
        counterText: '',
        hintStyle: kBaseTextStyle.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: colors.controlTextSecondary,
        ),
        labelStyle: kBaseTextStyle.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: colors.controlTextSecondary,
        ),
        errorStyle: kBaseTextStyle.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
          color: colors.errorStrong,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        prefixIcon: widget.prefixIcon,
        prefixIconColor: colors.iconSoft,
        suffixIcon: _buildSuffix(colors),
        suffixIconColor: colors.iconSoft,
        border: border(idleStroke, 1),
        enabledBorder: border(idleStroke, 1),
        focusedBorder: border(focusStroke, 1.5),
        errorBorder: border(colors.errorStrong, 1),
        focusedErrorBorder: border(colors.errorStrong, 1.5),
        disabledBorder: border(colors.strokeSoft, 1),
      ),
    );
  }

  Widget? _buildSuffix(AppColors colors) {
    if (widget.showObscureToggle && widget.obscureText && _hasText) {
      return IconButton(
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: _obscured
            ? Assets.icons.icEyeOpen.svg(
                colorFilter: ColorFilter.mode(colors.iconSoft, BlendMode.srcIn),
              )
            : Assets.icons.icEyeClose.svg(
                colorFilter: ColorFilter.mode(colors.iconSoft, BlendMode.srcIn),
              ),
        /*Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20.r,
        )*/
        color: colors.iconSoft,
        splashRadius: 20.r,
      );
    }
    return widget.suffixIcon;
  }
}
