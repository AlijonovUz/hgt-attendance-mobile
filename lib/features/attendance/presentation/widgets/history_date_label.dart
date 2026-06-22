import 'package:flutter/widgets.dart';

import '../../../../l10n/app_localizations.dart';

/// Tarix kartasi sarlavhasidagi sana yorlig‘i:
/// bugun → «Bugun», kecha → «Kecha {hafta kuni}», aks holda «{kun} {oy}».
/// Oy/hafta kuni nomlari joriy locale’ga qarab tanlanadi (uz / uz_Cyrl / ru).
String historyDayLabel(
  BuildContext context,
  DateTime date,
  AppLocalizations l10n,
) {
  final locale = Localizations.localeOf(context);
  final key = locale.scriptCode == 'Cyrl'
      ? 'cyrl'
      : (locale.languageCode == 'ru' ? 'ru' : 'uz');

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  final diff = today.difference(d).inDays;

  if (diff == 0) return l10n.historyToday;

  // Dushanba = 1 … Yakshanba = 7 → massiv indeksi 0..6.
  final weekdays = _weekdays[key]!;
  final months = _months[key]!;

  if (diff == 1) {
    return '${l10n.historyYesterday} ${weekdays[d.weekday - 1].toLowerCase()}';
  }
  return '${d.day} ${months[d.month - 1]}';
}

const _weekdays = <String, List<String>>{
  'uz': [
    'Dushanba',
    'Seshanba',
    'Chorshanba',
    'Payshanba',
    'Juma',
    'Shanba',
    'Yakshanba',
  ],
  'cyrl': [
    'Душанба',
    'Сешанба',
    'Чоршанба',
    'Пайшанба',
    'Жума',
    'Шанба',
    'Якшанба',
  ],
  'ru': [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ],
};

const _months = <String, List<String>>{
  'uz': [
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentyabr',
    'oktyabr',
    'noyabr',
    'dekabr',
  ],
  'cyrl': [
    'январ',
    'феврал',
    'март',
    'апрел',
    'май',
    'июн',
    'июл',
    'август',
    'сентябр',
    'октябр',
    'ноябр',
    'декабр',
  ],
  'ru': [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ],
};
