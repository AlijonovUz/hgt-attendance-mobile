// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/c_tuilcon_login_large.svg
  SvgGenImage get cTuilconLoginLarge =>
      const SvgGenImage('assets/icons/c_tuilcon_login_large.svg');

  /// File path: assets/icons/ic_arrow_down.svg
  SvgGenImage get icArrowDown =>
      const SvgGenImage('assets/icons/ic_arrow_down.svg');

  /// File path: assets/icons/ic_arrow_left_large.svg
  SvgGenImage get icArrowLeftLarge =>
      const SvgGenImage('assets/icons/ic_arrow_left_large.svg');

  /// File path: assets/icons/ic_breifcase.svg
  SvgGenImage get icBreifcase =>
      const SvgGenImage('assets/icons/ic_breifcase.svg');

  /// File path: assets/icons/ic_buildings.svg
  SvgGenImage get icBuildings =>
      const SvgGenImage('assets/icons/ic_buildings.svg');

  /// File path: assets/icons/ic_databese.svg
  SvgGenImage get icDatabese =>
      const SvgGenImage('assets/icons/ic_databese.svg');

  /// File path: assets/icons/ic_ellipse.svg
  SvgGenImage get icEllipse => const SvgGenImage('assets/icons/ic_ellipse.svg');

  /// File path: assets/icons/ic_exclude.svg
  SvgGenImage get icExclude => const SvgGenImage('assets/icons/ic_exclude.svg');

  /// File path: assets/icons/ic_eye_close.svg
  SvgGenImage get icEyeClose =>
      const SvgGenImage('assets/icons/ic_eye_close.svg');

  /// File path: assets/icons/ic_eye_open.svg
  SvgGenImage get icEyeOpen =>
      const SvgGenImage('assets/icons/ic_eye_open.svg');

  /// File path: assets/icons/ic_globe.svg
  SvgGenImage get icGlobe => const SvgGenImage('assets/icons/ic_globe.svg');

  /// File path: assets/icons/ic_hugeicons_moon.svg
  SvgGenImage get icHugeiconsMoon =>
      const SvgGenImage('assets/icons/ic_hugeicons_moon.svg');

  /// File path: assets/icons/ic_hugeicons_security_check.svg
  SvgGenImage get icHugeiconsSecurityCheck =>
      const SvgGenImage('assets/icons/ic_hugeicons_security_check.svg');

  /// File path: assets/icons/ic_hugeicons_sun.svg
  SvgGenImage get icHugeiconsSun =>
      const SvgGenImage('assets/icons/ic_hugeicons_sun.svg');

  /// File path: assets/icons/ic_lucide_scan_face.svg
  SvgGenImage get icLucideScanFace =>
      const SvgGenImage('assets/icons/ic_lucide_scan_face.svg');

  /// File path: assets/icons/ic_lucide_shield_alert.svg
  SvgGenImage get icLucideShieldAlert =>
      const SvgGenImage('assets/icons/ic_lucide_shield_alert.svg');

  /// File path: assets/icons/ic_profile.svg
  SvgGenImage get icProfile => const SvgGenImage('assets/icons/ic_profile.svg');

  /// File path: assets/icons/ic_user.svg
  SvgGenImage get icUser => const SvgGenImage('assets/icons/ic_user.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    cTuilconLoginLarge,
    icArrowDown,
    icArrowLeftLarge,
    icBreifcase,
    icBuildings,
    icDatabese,
    icEllipse,
    icExclude,
    icEyeClose,
    icEyeOpen,
    icGlobe,
    icHugeiconsMoon,
    icHugeiconsSecurityCheck,
    icHugeiconsSun,
    icLucideScanFace,
    icLucideShieldAlert,
    icProfile,
    icUser,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/cardboard_texture.jpg
  AssetGenImage get cardboardTexture =>
      const AssetGenImage('assets/images/cardboard_texture.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [cardboardTexture];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
