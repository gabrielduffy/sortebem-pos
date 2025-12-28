import 'package:intl/intl.dart';

class Formatters {
  static String currency(double value) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return currencyFormatter.format(value);
  }

  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
