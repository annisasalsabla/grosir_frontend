class Supplier {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String productType;
  final bool isActive;
  final DateTime createdAt;

  Supplier({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.productType,
    required this.isActive,
    required this.createdAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      productType: json['product_type'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get productTypeLabel => productType == 'egg' ? 'Telur' : 'Beras';

  String get formattedPhone {
    if (phone == null || phone!.isEmpty) return '-';
    final phoneStr = phone!.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneStr.length >= 10) {
      return '+${phoneStr.substring(0, phoneStr.length - 8)} ${phoneStr.substring(phoneStr.length - 8, phoneStr.length - 4)} ${phoneStr.substring(phoneStr.length - 4)}';
    }
    return phone!;
  }
}

class SupplierRequest {
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String productType;

  SupplierRequest({
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.productType,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    if (email != null) 'email': email,
    if (address != null) 'address': address,
    'product_type': productType,
  };
}

class SupplierUpdateRequest {
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? productType;
  final bool? isActive;

  SupplierUpdateRequest({
    this.name,
    this.phone,
    this.email,
    this.address,
    this.productType,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (address != null) 'address': address,
    if (productType != null) 'product_type': productType,
    if (isActive != null) 'is_active': isActive,
  };
}