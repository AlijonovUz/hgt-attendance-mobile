import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

extension TextStringExtensions on String {
  Text s(double size) => Text(this).s(size);

  Text w(int weight) => Text(this).w(weight);

  Text c(Color color) => Text(this).c(color);

  String clearPhoneWithCode() {
    var clearedPhone = replaceAll(RegExp(r"[^\d+.]"), '');
    if (clearedPhone.length == 9) {
      clearedPhone = "998$clearedPhone";
    }
    return clearedPhone;
  }

  String getFormattedPhoneNumber() {
    var clearedPhone = clearPhoneWithCode();

    String formattedNumber =
        '+${clearedPhone.substring(0, 3)} ${clearedPhone.substring(3, 5)} ${clearedPhone.substring(5, 8)} ${clearedPhone.substring(8, 10)} ${clearedPhone.substring(10)}';
    Logger().w(
        "this = $this, formatted = $formattedNumber, cleared = $clearedPhone");

    return formattedNumber;
  }

  String clearPhoneWithoutCode() {
    String countryCode = "998";
    if (length > 9 && contains(countryCode)) {
      return substring(countryCode.length);
    } else {
      return this;
    }
  }

  String clearPhoneNumber() {
    var clearedPhone = replaceAll(RegExp(r"[^\d+.]"), '');
    return clearedPhone;
  }

  String clearPrice() {
    return replaceAll(RegExp(r"[^\d+.]"), '');
  }

  String clearCharacters() {
    return replaceAll(RegExp(r"[^\d+.]"), '');
  }

  String capitalizePersonName() {
    return trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String capitalizeCompanyName() {
    final RegExp quoteRegex = RegExp(r'"[^"]*"');
    final RegExp wordRegex = RegExp(r'\b\w+\b');

    return replaceAllMapped(quoteRegex, (quoteMatch) {
      return quoteMatch.group(0)!;
    }).replaceAllMapped(wordRegex, (wordMatch) {
      String word = wordMatch.group(0)!;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });
  }
}

extension TextStyleExtensions on TextStyle {
  TextStyle copyWith({
    bool? inherit,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? debugLabel,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
  }) =>
      TextStyle(
        inherit: inherit ?? this.inherit,
        color: this.foreground == null && foreground == null
            ? color ?? this.color
            : null,
        backgroundColor: this.background == null && background == null
            ? backgroundColor ?? this.backgroundColor
            : null,
        fontSize: fontSize ?? this.fontSize,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        wordSpacing: wordSpacing ?? this.wordSpacing,
        textBaseline: textBaseline ?? this.textBaseline,
        height: height ?? this.height,
        locale: locale ?? this.locale,
        foreground: foreground ?? this.foreground,
        background: background ?? this.background,
        decoration: decoration ?? this.decoration,
        decorationColor: decorationColor ?? this.decorationColor,
        decorationStyle: decorationStyle ?? this.decorationStyle,
        decorationThickness: decorationThickness ?? this.decorationThickness,
        overflow: overflow ?? this.overflow,
      );
}

extension TextExtensions on Text {
  Text copyWith({
    String? data,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    Color? selectionColor,
  }) =>
      Text(
        data ?? this.data!,
        style: style ?? this.style,
        strutStyle: strutStyle ?? this.strutStyle,
        textAlign: textAlign ?? this.textAlign,
        textDirection: textDirection ?? this.textDirection,
        locale: locale ?? this.locale,
        softWrap: softWrap ?? this.softWrap,
        overflow: overflow ?? this.overflow,
        maxLines: maxLines ?? this.maxLines,
        semanticsLabel: semanticsLabel ?? this.semanticsLabel,
        textWidthBasis: textWidthBasis ?? this.textWidthBasis,
        textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
        selectionColor: selectionColor ?? this.selectionColor,
      );

  Text s(double size) => copyWith(
        style: (style ?? GoogleFonts.manrope()).copyWith(fontSize: size),
      );

  Text c(Color color) => copyWith(
        style: (style ?? GoogleFonts.manrope()).copyWith(color: color),
      );

  Text w(int fontWeight) {
    final weight = FontWeight.values[fontWeight ~/ 100 - 1];
    return copyWith(style: (style ?? GoogleFonts.manrope()).copyWith(fontWeight: weight));
  }

  Text a(TextAlign textAlign) => copyWith(style: style, textAlign: textAlign);

  Text h(double height) =>
      copyWith(style: (style ?? GoogleFonts.manrope()).copyWith(height: height));
}

extension ResponseExtensions on String {}

extension AdResponseExtensions on String {}
