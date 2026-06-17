import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../profile/domain/entities/profile.dart';

/// Asosiy ekran sarlavhasi (Figma 130:1590) — dumaloq avatar + ism/lavozim +
/// o‘ng tarafda bildirishnoma tugmasi.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.profile,
    required this.usernameFallback,
    this.onAvatarTap,
    this.onNotificationsTap,
    this.onAvatarLongPress,
  });

  final Profile? profile;
  final String usernameFallback;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final name = (profile?.fullName.trim().isNotEmpty ?? false)
        ? profile!.fullName.trim()
        : '—';
    final role = profile?.roleName?.trim().isNotEmpty == true
        ? profile!.roleName!.trim()
        : (profile?.departmentName?.trim().isNotEmpty == true
            ? profile!.departmentName!.trim()
            : usernameFallback);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 8,
          children: [
            GestureDetector(
              onTap: onAvatarTap,
              onLongPress: onAvatarLongPress,
              child: _Avatar(faceImage: profile?.faceImage, colors: colors),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                name
                    .s(16.sp)
                    .w(600)
                    .c(colors.textStrong)
                    .h(24 / 16)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                role
                    .s(14.sp)
                    .w(400)
                    .c(colors.textSub)
                    .h(16 / 14)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
        _NotificationButton(colors: colors, onTap: onNotificationsTap),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.colors, required this.onTap});

  final AppColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.backgroundElevation2,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40.r,
          height: 40.r,
          child: Center(
            child: Assets.icons.icHugeiconsNotification.svg(
              width: 20.r,
              height: 20.r,
              colorFilter:
                  ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.faceImage, required this.colors});

  final String? faceImage;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.r,
      height: 48.r,
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.avatarPlaceholder,
            borderRadius: BorderRadius.circular(16)
          ),
          child: _image(),
        ),
      ),
    );
  }

  Widget _image() {
    final src = faceImage?.trim() ?? '';
    if (src.isEmpty) return _placeholder();

    if (src.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: src,
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(),
        errorWidget: (context, url, error) => _placeholder(),
      );
    }
    if (src.startsWith('/media') || src.startsWith('media')) {
      final origin = ApiConstants.baseUrl.replaceFirst('/api', '');
      return CachedNetworkImage(
        imageUrl: '$origin${src.startsWith('/') ? '' : '/'}$src',
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(),
        errorWidget: (context, url, error) => _placeholder(),
      );
    }
    return Image.file(
      File(src),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder() => Center(
        child: Assets.icons.icUser.svg(
          width: 24.r,
          height: 24.r,
          colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
        ),
      );
}
