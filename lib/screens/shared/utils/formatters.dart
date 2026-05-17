import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length >= 10) {
      final prefix = cleaned.substring(0, cleaned.length - 8);
      final middle = cleaned.substring(cleaned.length - 8, cleaned.length - 4);
      final suffix = cleaned.substring(cleaned.length - 4);
      return '+$prefix $middle $suffix';
    }
    return phone;
  }

  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  static String formatCompactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}