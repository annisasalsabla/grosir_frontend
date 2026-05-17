import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DamagedGood {
  final int id;
  final int productId;
  final String? productName;
  final int quantity;
  final String damageType;
  final String damageTypeLabel;
  final String? description;
  final int recordedBy;
  final String? recordedByName;
  final DateTime recordedDate;
  final bool reportedToSupplier;
  final DateTime? reportedDate;

  DamagedGood({
    required this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.damageType,
    required this.damageTypeLabel,
    this.description,
    required this.recordedBy,
    this.recordedByName,
    required this.recordedDate,
    required this.reportedToSupplier,
    this.reportedDate,
  });

  factory DamagedGood.fromJson(Map<String, dynamic> json) {
    final damageTypes = {
      'cracked': 'Retak/Pecah',
      'rotten': 'Busuk',
      'broken': 'Hancur',
      'expired': 'Kadaluarsa',
      'wet': 'Basah',
    };

    return DamagedGood(
      id: json['id'],
      productId: json['product']['id'] ?? 0,
      productName: json['product']['full_name'] ?? json['product']['name'],
      quantity: json['quantity'] ?? 0,
      damageType: json['damage_type'],
      damageTypeLabel: damageTypes[json['damage_type']] ?? json['damage_type'],
      description: json['description'],
      recordedBy: json['recorded_by'] ?? 0,
      recordedByName: json['recorded_by']?['name'],
      recordedDate: DateTime.parse(json['recorded_date']),
      reportedToSupplier: json['reported_to_supplier'] ?? false,
      reportedDate: json['reported_date'] != null
          ? DateTime.parse(json['reported_date'])
          : null,
    );
  }

  String get formattedQuantity => '$quantity kg';

  Color get damageTypeColor {
    switch (damageType) {
      case 'cracked':
        return Colors.orange;
      case 'rotten':
        return Colors.red;
      case 'broken':
        return Colors.brown;
      case 'expired':
        return Colors.purple;
      case 'wet':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get reportedStatusLabel => reportedToSupplier ? 'Sudah Dilaporkan' : 'Belum Dilaporkan';
  Color get reportedStatusColor => reportedToSupplier ? Colors.green : Colors.red;
}

class DamagedGoodRequest {
  final int productId;
  final int quantity;
  final String damageType;
  final String? description;

  DamagedGoodRequest({
    required this.productId,
    required this.quantity,
    required this.damageType,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'damage_type': damageType,
    if (description != null) 'description': description,
  };
}