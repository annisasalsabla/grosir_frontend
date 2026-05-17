import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  AuthProvider(this._apiService, this._storageService) {
    _checkAuthStatus();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  Future<void> _checkAuthStatus() async {
    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      _apiService.setToken(token);
      await fetchUser();
    }
  }

  Future<void> fetchUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getMe();
      _user = User.fromJson(response['data']['user']);
      _isAuthenticated = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.login(email, password);
      _user = User.fromJson(response['data']['user']);
      _isAuthenticated = true;

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.logout();
      _user = null;
      _isAuthenticated = false;
    } catch (e) {
      // ignore error on logout
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String name, String? phone) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.updateProfile(name, phone);
      _user = User.fromJson(response['data']);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.forgotPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}