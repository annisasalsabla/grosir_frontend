import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Product> _products = [];
  List<Product> _lowStockProducts = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;

  ProductProvider(this._apiService);

  List<Product> get products => _products;
  List<Product> get lowStockProducts => _lowStockProducts;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasNextPage => _currentPage < _lastPage;
  bool get hasPreviousPage => _currentPage > 1;

  Future<void> fetchProducts({
    String? productType,
    String? search,
    bool? isActive,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _products = [];
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getProducts(
        productType: productType,
        search: search,
        isActive: isActive,
        page: page,
      );

      final data = response['data'] as List;
      final newProducts = data.map((json) => Product.fromJson(json)).toList();

      if (refresh) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
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

  Future<void> fetchLowStockProducts({int page = 1}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getLowStockProducts(page: page);
      _lowStockProducts = (response['data'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getCategories();
      _categories = (response['data'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> getProduct(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getProduct(id);
      return Product.fromJson(response['data']);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct(ProductCreateRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.createProduct(request);
      await fetchProducts(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.updateProduct(id, data);
      await fetchProducts(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStock(int productId, int quantity, String type, {String? description}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.updateStock(productId, quantity, type, description: description);
      await fetchProducts(refresh: true);
      await fetchLowStockProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadNextPage({String? productType, String? search}) {
    if (hasNextPage && !_isLoading) {
      fetchProducts(
        productType: productType,
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