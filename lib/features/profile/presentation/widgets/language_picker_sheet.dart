import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/locale/locale_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';

/// «Ilova tili» tanlash bottom-sheet’i — profil sahifasidagi til qatori
/// bosilganda ochiladi. Har bir til [AppLanguage.label] (o‘z tilida, tarjima
/// qilinmaydi); joriy til yonida tasdiq belgisi. Tanlangach [LocaleChanged]
/// yuboriladi va sheet yopiladi.
Future<void> showLanguagePicker(BuildContext context) {
  final colors = AppColors.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.backgroundElevation1,
    barrierColor: colors.black.withValues(alpha: 0.30),
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
    ),
    builder: (_) => BlocProvider<LocaleBloc>.value(
      value: context.read<LocaleBloc>(),
      child: const _LanguagePickerSheet(),
    ),
  );
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SizedBox(
                width: 40.w,
                height: 4.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.strokeStrong,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            l10n.profileLanguageSheetTitle
                .s(18.sp)
                .w(700)
                .c(colors.textStrong)
                .h(24 / 18)
                .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 12.h),
            BlocBuilder<LocaleBloc, AppLanguage>(
              builder: (context, current) {
                return Column(
                  children: [
                    for (final lang in AppLanguage.values)
                      _LanguageRow(
                        language: lang,
                        selected: lang == current,
                        colors: colors,
                        onTap: () {
                          if (lang != current) {
                            context.read<LocaleBloc>().add(LocaleChanged(lang));
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.language,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.accentSoft.withValues(alpha: 0.12)
              : colors.backgroundElevation2,
          borderRadius: radius,
          border: Border.all(
            color: selected ? colors.strokeAccent : Colors.transparent,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: language.label
                        .s(15.sp)
                        .w(selected ? 600 : 500)
                        .c(selected ? colors.textAccent : colors.textStrong)
                        .copyWith(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                  if (selected)
                    Assets.icons.icLucideCheck.svg(
                      width: 20.r,
                      height: 20.r,
                      colorFilter:
                          ColorFilter.mode(colors.iconAccent, BlendMode.srcIn),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
