import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Debt {
  final int id;
  final String debtNumber;
  final int supplierId;
  final String? supplierName;
  final int productId;
  final String? productName;
  final int quantity;
  final double pricePerUnit;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime dueDate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final List<DebtPayment>? payments;

  Debt({
    required this.id,
    required this.debtNumber,
    required this.supplierId,
    this.supplierName,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.status,
    this.notes,
    required this.createdAt,
    this.payments,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      debtNumber: json['debt_number'],
      supplierId: json['supplier']['id'] ?? 0,
      supplierName: json['supplier']['name'],
      productId: json['product']['id'] ?? 0,
      productName: json['product']['full_name'] ?? json['product']['name'],
      quantity: json['quantity'] ?? 0,
      pricePerUnit: (json['price_per_unit'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      payments: json['payments'] != null
          ? (json['payments'] as List)
          .map((p) => DebtPayment.fromJson(p))
          .toList()
          : null,
    );
  }

  String get formattedTotalAmount => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(totalAmount);

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
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

class DebtPayment {
  final int id;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? paymentProof;
  final String? notes;
  final String? creatorName;

  DebtPayment({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.paymentProof,
    this.notes,
    this.creatorName,
  });

  factory DebtPayment.fromJson(Map<String, dynamic> json) {
    return DebtPayment(
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

class DebtRequest {
  final int supplierId;
  final int productId;
  final int quantity;
  final double pricePerUnit;
  final DateTime dueDate;
  final String? notes;

  DebtRequest({
    required this.supplierId,
    required this.productId,
    required this.quantity,
    required this.pricePerUnit,
    required this.dueDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'supplier_id': supplierId,
    'product_id': productId,
    'quantity': quantity,
    'price_per_unit': pricePerUnit,
    'due_date': dueDate.toIso8601String().split('T').first,
    if (notes != null) 'notes': notes,
  };
}

class PayDebtRequest {
  final double amount;
  final String paymentMethod;
  final String? notes;

  PayDebtRequest({
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