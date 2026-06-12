import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/bloc/locale/locale_bloc.dart';
import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// Til tanlash pill’i (`UZ ▾`) — bosilganda 3 tilli menyu ochiladi. `LocaleBloc`ka
/// yozadi. Har bir til o‘z nomida ko‘rsatiladi (Uzbek / Узбек / Русский).
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return BlocBuilder<LocaleBloc, AppLanguage>(
      builder: (context, current) {
        return PopupMenuButton<AppLanguage>(
          tooltip: '',
          position: PopupMenuPosition.under,
          color: colors.backgroundBase,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: colors.strokeSoft),
          ),
          onSelected: (lang) =>
              context.read<LocaleBloc>().add(LocaleChanged(lang)),
          itemBuilder: (context) => [
            for (final lang in AppLanguage.values)
              PopupMenuItem<AppLanguage>(
                value: lang,
                height: 44.h,
                child: Row(
                  children: [
                    Expanded(
                      child: lang.label
                          .s(14.sp)
                          .w(lang == current ? 600 : 500)
                          .c(colors.textStrong)
                          .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (lang == current)
                      Icon(Icons.check, size: 18.r, color: colors.accentSub),
                  ],
                ),
              ),
          ],
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundElevation1Alt,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: colors.strokeSoft),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  current.shortCode
                      .s(14.sp)
                      .w(600)
                      .c(colors.textStrong),
                  SizedBox(width: 4.w),
                  Assets.icons.icArrowDown.svg(
                    width: 16.r,
                    height: 16.r,
                    colorFilter:
                        ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
