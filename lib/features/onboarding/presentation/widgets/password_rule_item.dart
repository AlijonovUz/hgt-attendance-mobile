import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';

/// Parol shartlari ro‘yxatining bitta qatori (Figma 263‑1333): kichik nuqta
/// (qondirilsa yashil, aks holda kulrang) + shart matni.
class PasswordRuleItem extends StatelessWidget {
  const PasswordRuleItem({
    super.key,
    required this.label,
    required this.satisfied,
  });

  final String label;
  final bool satisfied;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: SizedBox(
              width: 8.r,
              height: 8.r,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: satisfied ? colors.successPrimary : colors.strokeStrong,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: label
                .s(13.sp)
                .w(satisfied ? 500 : 400)
                .c(satisfied ? colors.textStrong : colors.textSub)
                .h(18 / 13)
                .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
