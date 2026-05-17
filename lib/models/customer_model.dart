import 'package:intl/intl.dart';

class Customer {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double totalDebt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.totalDebt,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      totalDebt: (json['total_debt'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  String get formattedTotalDebt => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(totalDebt);

  String get formattedPhone {
    if (phone == null || phone!.isEmpty) return '-';
    final phoneStr = phone!.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneStr.length >= 10) {
      return '+${phoneStr.substring(0, phoneStr.length - 8)} ${phoneStr.substring(phoneStr.length - 8, phoneStr.length - 4)} ${phoneStr.substring(phoneStr.length - 4)}';
    }
    return phone!;
  }
}