import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../domain/entities/profile.dart';

/// Home tepasidagi foydalanuvchi kartasi (Figma `Avatar`): dumaloq rasm +
/// ism + lavozim/login + yashil tasdiq belgisi. Rasm yo‘q bo‘lsa placeholder
/// ko‘rinadi va [onTap] orqali yuklash modali qayta ochiladi.
class ProfileAvatarCard extends StatelessWidget {
  const ProfileAvatarCard({
    super.key,
    required this.profile,
    this.usernameFallback = 'Username',
    this.onTap,
    this.onLongPress,
  });

  final Profile? profile;
  final String usernameFallback;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final name = (profile?.fullName.trim().isNotEmpty ?? false)
        ? profile!.fullName.trim()
        : '—';
    final subtitle = profile?.roleName?.trim().isNotEmpty == true
        ? profile!.roleName!.trim()
        : (profile?.departmentName?.trim().isNotEmpty == true
            ? profile!.departmentName!.trim()
            : usernameFallback);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(22.r),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: colors.strokeSub),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                _Avatar(faceImage: profile?.faceImage, colors: colors),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      name
                          .s(14.sp)
                          .w(500)
                          .c(colors.textStrong)
                          .h(20 / 14)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      SizedBox(height: 2.h),
                      subtitle
                          .s(14.sp)
                          .w(400)
                          .c(colors.textSub)
                          .h(20 / 14)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Assets.icons.icHugeiconsSecurityCheck.svg(
                  width: 24.r,
                  height: 24.r,
                  colorFilter: ColorFilter.mode(
                    colors.successPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
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
      width: 40.r,
      height: 40.r,
      child: ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.avatarPlaceholder,
            shape: BoxShape.circle,
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
          width: 22.r,
          height: 22.r,
          colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
        ),
      );
}
