import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';

/// «Davomat tarixi» tab — kunlik davomat yozuvlari ro‘yxati.
///
/// Batafsil chizma hali berilmagan; hozircha sarlavha + bo‘sh holat.
class DavomatTarixiPage extends StatelessWidget {
  const DavomatTarixiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            l10n.navHistory.s(20.sp).w(700).c(colors.textStrong),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.icons.icHugeiconsClock.svg(
                      width: 48.r,
                      height: 48.r,
                      colorFilter: ColorFilter.mode(
                        colors.iconSoft,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    l10n.historyEmpty
                        .s(14.sp)
                        .w(400)
                        .c(colors.textSub)
                        .a(TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
