extension StringExtension on String {
  String get formatPhoneNumber => replaceAll(RegExp(r'\D'), '');

  String get removeSpace => replaceAll(' ', '');

  String get capitalize => substring(0, 1).toUpperCase() + substring(1);
}

extension StringNull on String? {
  String get nullEmpty => (this ?? '').isEmpty ? '' : this!;
}
