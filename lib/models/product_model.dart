import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Product {
  final int id;
  final String name;
  final String slug;
  final String fullName;
  final String productType;
  final String? eggSize;
  final String? riceVariant;
  final double purchasePrice;
  final double sellingPrice;
  final double profitPerUnit;
  final int stock;
  final int minStock;
  final String unit;
  final String? supplierName;
  final int? supplierId;
  final bool isActive;
  final Category? category;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.fullName,
    required this.productType,
    this.eggSize,
    this.riceVariant,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.profitPerUnit,
    required this.stock,
    required this.minStock,
    required this.unit,
    this.supplierName,
    this.supplierId,
    required this.isActive,
    this.category,
    required this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      fullName: json['full_name'] ?? json['name'],
      productType: json['product_type'],
      eggSize: json['egg_size'],
      riceVariant: json['rice_variant'],
      purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      profitPerUnit: (json['profit_per_unit'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'] ?? 10,
      unit: json['unit'] ?? 'kg',
      supplierName: json['supplier_name'],
      supplierId: json['supplier_id'],
      isActive: json['is_active'] ?? true,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock <= 0;

  String get formattedSellingPrice => 'Rp ${NumberFormat('#,###').format(sellingPrice)}';
  String get formattedPurchasePrice => 'Rp ${NumberFormat('#,###').format(purchasePrice)}';
  String get formattedProfit => 'Rp ${NumberFormat('#,###').format(profitPerUnit)}';

  String get statusLabel {
    if (isOutOfStock) return 'Habis';
    if (isLowStock) return 'Menipis';
    return 'Tersedia';
  }

  Color get statusColor {
    if (isOutOfStock) return Colors.red;
    if (isLowStock) return Colors.orange;
    return Colors.green;
  }
}

class Category {
  final int id;
  final String name;
  final String slug;
  final int? productsCount;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.productsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      productsCount: json['products_count'],
    );
  }
}

class ProductCreateRequest {
  final String name;
  final int categoryId;
  final String productType;
  final String? eggSize;
  final String? riceVariant;
  final double purchasePrice;
  final double sellingPrice;
  final int stock;
  final int minStock;
  final String unit;
  final int supplierId;
  final bool isActive;

  ProductCreateRequest({
    required this.name,
    required this.categoryId,
    required this.productType,
    this.eggSize,
    this.riceVariant,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
    required this.minStock,
    required this.unit,
    required this.supplierId,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'category_id': categoryId,
    'product_type': productType,
    if (eggSize != null) 'egg_size': eggSize,
    if (riceVariant != null) 'rice_variant': riceVariant,
    'purchase_price': purchasePrice,
    'selling_price': sellingPrice,
    'stock': stock,
    'min_stock': minStock,
    'unit': unit,
    'supplier_id': supplierId,
    'is_active': isActive,
  };
}