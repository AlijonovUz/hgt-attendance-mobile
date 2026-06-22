import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/user_avatar.dart';
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
    this.unreadCount = 0,
  });

  final Profile? profile;
  final String usernameFallback;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarLongPress;

  /// O‘qilmagan bildirishnomalar soni — >0 bo‘lsa bell ustida nuqta/son.
  final int unreadCount;

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
              child: UserAvatar(
                faceImage: profile?.faceImage,
                size: 48.r,
                radius: 16.r,
              ),
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
        _NotificationButton(
          colors: colors,
          onTap: onNotificationsTap,
          unreadCount: unreadCount,
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.colors,
    required this.onTap,
    required this.unreadCount,
  });

  final AppColors colors;
  final VoidCallback? onTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final button = Material(
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

    if (unreadCount <= 0) return button;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          top: -2.r,
          right: -2.r,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.errorStrong,
              shape: BoxShape.circle,
              border: Border.all(color: colors.backgroundBase, width: 1.5),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Center(
                  child: (unreadCount > 99 ? '99+' : '$unreadCount')
                      .s(10.sp)
                      .w(700)
                      .c(colors.textWhite)
                      .h(1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

