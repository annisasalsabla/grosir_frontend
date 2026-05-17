import 'package:flutter/material.dart';
import '../models/supplier_model.dart';
import '../services/api_service.dart';

class SupplierProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;

  SupplierProvider(this._apiService);

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasNextPage => _currentPage < _lastPage;

  Future<void> fetchSuppliers({
    String? productType,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _suppliers = [];
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getSuppliers(
        productType: productType,
        page: page,
      );

      final data = response['data'] as List;
      final newSuppliers = data.map((json) => Supplier.fromJson(json)).toList();

      if (refresh) {
        _suppliers = newSuppliers;
      } else {
        _suppliers.addAll(newSuppliers);
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

  Future<bool> createSupplier(SupplierRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.createSupplier(request);
      await fetchSuppliers(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSupplier(int id, SupplierUpdateRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.updateSupplier(id, request);
      await fetchSuppliers(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSupplier(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.deleteSupplier(id);
      _suppliers.removeWhere((s) => s.id == id);
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