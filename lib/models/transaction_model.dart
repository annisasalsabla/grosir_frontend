import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Transaction {
  final int id;
  final String invoiceNumber;
  final int userId;
  final String? userName;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final String paymentType;
  final String paymentStatus;
  final double subtotal;
  final double discount;
  final double total;
  final double paidAmount;
  final double changeAmount;
  final double remainingDebt;
  final DateTime? dueDate;
  final List<TransactionDetail> details;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.invoiceNumber,
    required this.userId,
    this.userName,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.paymentType,
    required this.paymentStatus,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paidAmount,
    required this.changeAmount,
    required this.remainingDebt,
    this.dueDate,
    required this.details,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      userId: json['user']['id'] ?? 0,
      userName: json['user']['name'],
      customerId: json['customer']?['id'],
      customerName: json['customer']?['name'],
      customerPhone: json['customer']?['phone'],
      paymentType: json['payment_type'],
      paymentStatus: json['payment_status'],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      changeAmount: (json['change_amount'] ?? 0).toDouble(),
      remainingDebt: (json['remaining_debt'] ?? 0).toDouble(),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      details: (json['details'] as List?)?.map((d) => TransactionDetail.fromJson(d)).toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get formattedSubtotal => 'Rp ${NumberFormat('#,###').format(subtotal)}';
  String get formattedTotal => 'Rp ${NumberFormat('#,###').format(total)}';
  String get formattedPaidAmount => 'Rp ${NumberFormat('#,###').format(paidAmount)}';
  String get formattedRemainingDebt => 'Rp ${NumberFormat('#,###').format(remainingDebt)}';

  String get paymentTypeLabel {
    switch (paymentType) {
      case 'cash': return 'Tunai';
      case 'transfer': return 'Transfer';
      case 'qris': return 'QRIS';
      case 'receivable': return 'Piutang';
      default: return paymentType;
    }
  }

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'paid': return 'Lunas';
      case 'partial': return 'Sebagian';
      case 'unpaid': return 'Belum Dibayar';
      default: return paymentStatus;
    }
  }

  Color get paymentStatusColor {
    switch (paymentStatus) {
      case 'paid': return Colors.green;
      case 'partial': return Colors.orange;
      case 'unpaid': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class TransactionDetail {
  final int id;
  final int productId;
  final String? productName;
  final int quantity;
  final double pricePerUnit;
  final double totalPrice;

  TransactionDetail({
    required this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product']?['full_name'] ?? json['product']?['name'],
      quantity: json['quantity'],
      pricePerUnit: (json['price_per_unit'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }
}

class TransactionRequest {
  final List<TransactionItem> items;
  final String paymentType;
  final double? paidAmount;
  final int? dueDays;
  final double? discount;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? notes;

  TransactionRequest({
    required this.items,
    required this.paymentType,
    this.paidAmount,
    this.dueDays,
    this.discount,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'payment_type': paymentType,
    if (paidAmount != null) 'paid_amount': paidAmount,
    if (dueDays != null) 'due_days': dueDays,
    if (discount != null) 'discount': discount,
    if (customerName != null) 'customer_name': customerName,
    if (customerPhone != null) 'customer_phone': customerPhone,
    if (customerAddress != null) 'customer_address': customerAddress,
    if (notes != null) 'notes': notes,
  };
}

class TransactionItem {
  final int productId;
  final int quantity;

  TransactionItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
  };
}