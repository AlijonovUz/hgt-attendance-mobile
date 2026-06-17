import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../constants/api_constants.dart';
import '../gen/assets.gen.dart';

/// Foydalanuvchi avatari — `faceImage` manbasini (http / `/media` / lokal fayl)
/// hal qilib ko‘rsatadi; bo‘sh yoki xato bo‘lsa `ic_user` o‘rin egasi.
///
/// [size] — kvadrat o‘lcham; [radius] `null` bo‘lsa doira, aks holda burchak
/// radiusi. Asosiy ekran sarlavhasi va yuz-tekshiruv kartasi shu vidjetni
/// ulashadi.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.faceImage,
    required this.size,
    this.radius,
    this.iconSize,
  });

  final String? faceImage;
  final double size;
  final double? radius;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final borderRadius = radius == null
        ? BorderRadius.circular(size / 2)
        : BorderRadius.circular(radius!);

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.avatarPlaceholder,
            borderRadius: borderRadius,
          ),
          child: _image(colors),
        ),
      ),
    );
  }

  Widget _image(AppColors colors) {
    final src = faceImage?.trim() ?? '';
    if (src.isEmpty) return _placeholder(colors);

    if (src.startsWith('http')) {
      return _network(src, colors);
    }
    if (src.startsWith('/media') || src.startsWith('media')) {
      final origin = ApiConstants.baseUrl.replaceFirst('/api', '');
      return _network('$origin${src.startsWith('/') ? '' : '/'}$src', colors);
    }
    return Image.file(
      File(src),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _placeholder(colors),
    );
  }

  Widget _network(String url, AppColors colors) => CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(colors),
        errorWidget: (context, url, error) => _placeholder(colors),
      );

  Widget _placeholder(AppColors colors) => Center(
        child: Assets.icons.icUser.svg(
          width: iconSize ?? 24.r,
          height: iconSize ?? 24.r,
          colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
        ),
      );
}
