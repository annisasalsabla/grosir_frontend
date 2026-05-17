class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? avatar;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatar,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      avatar: json['avatar'],
      isActive: json['is_active'] ?? true,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'avatar': avatar,
      'is_active': isActive,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isOwner => role == 'owner';
  bool get isAdministrator => role == 'administrator';
  bool get isCashier => role == 'cashier';

  String get roleLabel {
    switch (role) {
      case 'owner':
        return 'Pemilik';
      case 'administrator':
        return 'Administrator';
      case 'cashier':
        return 'Kasir';
      default:
        return role;
    }
  }
}

class UserCreateRequest {
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;

  UserCreateRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'is_active': isActive,
  };
}

class UserUpdateRequest {
  final String? name;
  final String? phone;
  final String? role;
  final bool? isActive;

  UserUpdateRequest({this.name, this.phone, this.role, this.isActive});

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (phone != null) 'phone': phone,
    if (role != null) 'role': role,
    if (isActive != null) 'is_active': isActive,
  };
}