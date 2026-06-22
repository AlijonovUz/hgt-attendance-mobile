import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../domain/entities/app_notification.dart';

/// Bitta bildirishnoma kartasi (Figma 554:6982).
///
/// O‘qilmaganda o‘ng-tepada ko‘k nuqta ko‘rinadi; bosilganda [onTap] orqali
/// o‘qilgan deb belgilanadi. Sarlavha/matn joriy tilga qarab tanlanadi.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.languageCode,
    required this.scriptCode,
    this.onTap,
  });

  final AppNotification notification;
  final String languageCode;
  final String? scriptCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(22.r);

    final title = notification.title(languageCode, scriptCode);
    final message = notification.message(languageCode, scriptCode);

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.backgroundElevation2, borderRadius: radius),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: notification.isRead ? null : onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Opacity(
              // Figma: bildirishnoma kontenti 80% shaffoflik bilan.
              opacity: 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title.isNotEmpty)
                              title
                                  .s(14.sp)
                                  .w(500)
                                  .c(colors.textStrong)
                                  .h(20 / 14)
                                  .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                            if (title.isNotEmpty && message.isNotEmpty)
                              SizedBox(height: 8.h),
                            if (message.isNotEmpty)
                              message
                                  .s(12.sp)
                                  .w(400)
                                  .c(colors.textSub)
                                  .h(16 / 12)
                                  .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      if (!notification.isRead) ...[
                        SizedBox(width: 8.w),
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.accentSoft,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(width: 16.r, height: 16.r),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8.h),
                  _formatDate(notification.createdAt)
                      .s(14.sp)
                      .w(400)
                      .c(colors.textSub)
                      .h(20 / 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// «01.06.2025  15:29» (Figma) — mahalliy vaqtda, ikki bo‘sh joy bilan.
  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    final d = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }
}
