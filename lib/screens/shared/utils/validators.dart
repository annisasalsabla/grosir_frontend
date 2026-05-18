import 'package:intl/intl.dart';

class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Nomor telepon tidak valid (10-13 digit)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != password) {
      return 'Password tidak cocok';
    }
    return null;
  }

  static String? number(String? value, {int min = 1, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Field ini wajib diisi';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Harus berupa angka';
    }
    if (number < min) {
      return 'Nilai minimal $min';
    }
    if (max != null && number > max) {
      return 'Nilai maksimal $max';
    }
    return null;
  }

  static String? numeric(String? value, {double min = 0, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Field ini wajib diisi';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Harus berupa angka';
    }
    if (number < min) {
      return 'Nilai minimal ${FormatCurrency(min)}';
    }
    if (max != null && number > max) {
      return 'Nilai maksimal ${FormatCurrency(max)}';
    }
    return null;
  }

  static String FormatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}