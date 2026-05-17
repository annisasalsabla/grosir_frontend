import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class StockProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<StockMutation> _mutations = [];
  Product? _selectedProduct;
  Map<String, dynamic>? _stockSummary;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;

  StockProvider(this._apiService);

  List<StockMutation> get mutations => _mutations;
  Product? get selectedProduct => _selectedProduct;
  Map<String, dynamic>? get stockSummary => _stockSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasNextPage => _currentPage < _lastPage;

  Future<void> fetchMutations({
    int? productId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _mutations = [];
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getStockMutations(
        productId: productId,
        type: type,
        startDate: startDate,
        endDate: endDate,
        page: page,
      );

      final data = response['data'] as List;
      final newMutations = data.map((json) => StockMutation.fromJson(json)).toList();

      if (refresh) {
        _mutations = newMutations;
      } else {
        _mutations.addAll(newMutations);
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

  Future<void> fetchProductHistory(int productId, {int page = 1}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getProductStockHistory(productId, page: page);
      _selectedProduct = Product.fromJson(response['data']['product']);
      final mutationsData = response['data']['mutations']['data'] as List;
      _mutations = mutationsData.map((json) => StockMutation.fromJson(json)).toList();
      _currentPage = response['data']['mutations']['meta']['current_page'];
      _lastPage = response['data']['mutations']['meta']['last_page'];
      _total = response['data']['mutations']['meta']['total'];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStockSummary() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getStockSummary();
      _stockSummary = response['data'];
      _error = null;
    } catch (e) {
      _error = e.toString();
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

class StockMutation {
  final int id;
  final int productId;
  final String? productName;
  final String type;
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final String? description;
  final String? creatorName;
  final DateTime createdAt;

  StockMutation({
    required this.id,
    required this.productId,
    this.productName,
    required this.type,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    this.description,
    this.creatorName,
    required this.createdAt,
  });

  factory StockMutation.fromJson(Map<String, dynamic> json) {
    return StockMutation(
      id: json['id'],
      productId: json['product']['id'] ?? 0,
      productName: json['product']['full_name'] ?? json['product']['name'],
      type: json['type'],
      quantity: json['quantity'] ?? 0,
      stockBefore: json['stock_before'] ?? 0,
      stockAfter: json['stock_after'] ?? 0,
      description: json['description'],
      creatorName: json['creator']?['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get typeLabel {
    switch (type) {
      case 'in':
        return 'Masuk';
      case 'out':
        return 'Keluar';
      case 'damaged':
        return 'Rusak';
      case 'adjustment':
        return 'Penyesuaian';
      default:
        return type;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'in':
        return Colors.green;
      case 'out':
        return Colors.orange;
      case 'damaged':
        return Colors.red;
      case 'adjustment':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get stockChange => type == 'in' ? '+$quantity' : '-$quantity';
}