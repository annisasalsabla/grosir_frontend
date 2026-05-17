import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Receivable {
  final int id;
  final String receivableNumber;
  final int transactionId;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final double amount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime dueDate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final List<ReceivablePayment>? payments;

  Receivable({
    required this.id,
    required this.receivableNumber,
    required this.transactionId,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.amount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.status,
    this.notes,
    required this.createdAt,
    this.payments,
  });

  factory Receivable.fromJson(Map<String, dynamic> json) {
    return Receivable(
      id: json['id'],
      receivableNumber: json['receivable_number'],
      transactionId: json['transaction']['id'] ?? 0,
      customerId: json['customer']?['id'],
      customerName: json['customer']?['name'],
      customerPhone: json['customer']?['phone'],
      amount: (json['amount'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      payments: json['payments'] != null
          ? (json['payments'] as List)
          .map((p) => ReceivablePayment.fromJson(p))
          .toList()
          : null,
    );
  }

  String get formattedAmount => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);

  String get formattedPaidAmount => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(paidAmount);

  String get formattedRemainingAmount => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(remainingAmount);

  String get statusLabel {
    switch (status) {
      case 'paid':
        return 'Lunas';
      case 'partial':
        return 'Sebagian';
      case 'pending':
        return 'Menunggu';
      case 'overdue':
        return 'Jatuh Tempo';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && remainingAmount > 0;
  bool get isFullyPaid => remainingAmount <= 0;
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

class ReceivablePayment {
  final int id;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? paymentProof;
  final String? notes;
  final String? creatorName;

  ReceivablePayment({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.paymentProof,
    this.notes,
    this.creatorName,
  });

  factory ReceivablePayment.fromJson(Map<String, dynamic> json) {
    return ReceivablePayment(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'],
      paymentDate: DateTime.parse(json['payment_date']),
      paymentProof: json['payment_proof'],
      notes: json['notes'],
      creatorName: json['creator']?['name'],
    );
  }
}

class PayReceivableRequest {
  final double amount;
  final String paymentMethod;
  final String? notes;

  PayReceivableRequest({
    required this.amount,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'payment_method': paymentMethod,
    if (notes != null) 'notes': notes,
  };
}