import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';

  String? _token;
  Map<String, dynamic>? _user;
  String? _role;
  bool _isAuthenticated = false;

  AuthService() {
    _loadAuthData();
  }

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  String? get role => _role;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _role = prefs.getString(_roleKey);

    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _user = Map<String, dynamic>.from(jsonDecode(userJson));
    }

    _isAuthenticated = _token != null && _token!.isNotEmpty;
    notifyListeners();
  }

  Future<void> saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, user['role']);
    await prefs.setString(_userKey, jsonEncode(user));

    _token = token;
    _user = user;
    _role = user['role'];
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userKey);

    _token = null;
    _user = null;
    _role = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  bool isOwner() => _role == 'owner';
  bool isAdministrator() => _role == 'administrator';
  bool isCashier() => _role == 'cashier';
}

// Helper function for json encode/decode
import 'dart:convert';