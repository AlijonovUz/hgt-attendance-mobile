import 'package:intl/intl.dart';

abstract final class Formatters {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
