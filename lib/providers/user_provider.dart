import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<User> _users = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;

  UserProvider(this._apiService);

  List<User> get users => _users;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasNextPage => _currentPage < _lastPage;

  Future<void> fetchUsers({
    String? role,
    String? search,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _users = [];
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getUsers(
        role: role,
        search: search,
        page: page,
      );

      final data = response['data'] as List;
      final newUsers = data.map((json) => User.fromJson(json)).toList();

      if (refresh) {
        _users = newUsers;
      } else {
        _users.addAll(newUsers);
      }

      _currentPage = response['meta']['current_page'];
      _lastPage = response['meta']['last_page'];
      _total = response['meta']['total'];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(UserCreateRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.createUser(request);
      await fetchUsers(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(int userId, UserUpdateRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.updateUser(userId, request);
      await fetchUsers(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> activateUser(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.activateUser(userId);
      await fetchUsers(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateUser(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.deactivateUser(userId);
      await fetchUsers(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetUserPassword(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.resetUserPassword(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getUserStats();
      _stats = response['data'];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadNextPage({String? role, String? search}) {
    if (hasNextPage && !_isLoading) {
      fetchUsers(
        role: role,
        search: search,
        page: _currentPage + 1,
      );
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}