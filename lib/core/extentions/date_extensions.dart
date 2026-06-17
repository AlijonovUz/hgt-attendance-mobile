import 'package:flutter/widgets.dart';

/// Sana formatlash yordamchisi — uchta til uchun oy nomlari (intl locale
/// ma’lumotini yuklamasdan, oldindan aniqlangan jadval bilan).
class AppDate {
  const AppDate._();

  static const List<String> _uzLatin = [
    'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
    'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr',
  ];

  static const List<String> _uzCyrl = [
    'январ', 'феврал', 'март', 'апрел', 'май', 'июн',
    'июл', 'август', 'сентябр', 'октябр', 'ноябр', 'декабр',
  ];

  static const List<String> _ru = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];

  /// «13-iyun» (uz) / «13 июня» (ru) ko‘rinishida — joriy [locale] ga qarab.
  static String monthDay(DateTime date, Locale locale) {
    final month = switch (locale.languageCode) {
      'ru' => _ru[date.month - 1],
      'uz' when locale.scriptCode == 'Cyrl' => _uzCyrl[date.month - 1],
      _ => _uzLatin[date.month - 1],
    };
    return locale.languageCode == 'ru'
        ? '${date.day} $month'
        : '${date.day}-$month';
  }
}
