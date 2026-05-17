import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;

  // Cart for new transaction
  List<CartItem> _cart = [];
  double _discount = 0;
  String? _selectedPaymentType;
  String? _customerName;
  String? _customerPhone;
  String? _customerAddress;
  int? _dueDays;

  TransactionProvider(this._apiService);

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasNextPage => _currentPage < _lastPage;

  // Cart getters
  List<CartItem> get cart => _cart;
  double get discount => _discount;
  String? get selectedPaymentType => _selectedPaymentType;
  String? get customerName => _customerName;
  String? get customerPhone => _customerPhone;
  String? get customerAddress => _customerAddress;
  int? get dueDays => _dueDays;

  double get subtotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);
  double get total => subtotal - _discount;

  bool get hasItemsInCart => _cart.isNotEmpty;

  Future<void> fetchTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? paymentType,
    String? paymentStatus,
    String? invoiceNumber,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _transactions = [];
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getTransactions(
        startDate: startDate,
        endDate: endDate,
        paymentType: paymentType,
        paymentStatus: paymentStatus,
        invoiceNumber: invoiceNumber,
        page: page,
      );

      final data = response['data'] as List;
      final newTransactions = data.map((json) => Transaction.fromJson(json)).toList();

      if (refresh) {
        _transactions = newTransactions;
      } else {
        _transactions.addAll(newTransactions);
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

  Future<Transaction?> getTransaction(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getTransaction(id);
      return Transaction.fromJson(response['data']);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getInvoice(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getInvoice(id);
      return response['data'];
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getDailyReport({DateTime? date}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getDailyReport(date: date);
      return response['data'];
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction() async {
    if (_cart.isEmpty) {
      _error = 'Keranjang belanja kosong';
      notifyListeners();
      return false;
    }

    if (_selectedPaymentType == null) {
      _error = 'Pilih metode pembayaran';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final items = _cart.map((item) => TransactionItem(
        productId: item.productId,
        quantity: item.quantity,
      )).toList();

      final request = TransactionRequest(
        items: items,
        paymentType: _selectedPaymentType!,
        paidAmount: _selectedPaymentType == 'receivable' ? 0 : total,
        dueDays: _dueDays,
        discount: _discount > 0 ? _discount : null,
        customerName: _customerName,
        customerPhone: _customerPhone,
        customerAddress: _customerAddress,
      );

      await _apiService.createTransaction(request);
      clearCart();
      await fetchTransactions(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cart methods
  void addToCart(CartItem item) {
    final existingIndex = _cart.indexWhere((i) => i.productId == item.productId);
    if (existingIndex != -1) {
      _cart[existingIndex] = _cart[existingIndex].copyWith(
        quantity: _cart[existingIndex].quantity + item.quantity,
      );
    } else {
      _cart.add(item);
    }
    notifyListeners();
  }

  void updateCartQuantity(int productId, int quantity) {
    final index = _cart.indexWhere((i) => i.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = _cart[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int productId) {
    _cart.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _discount = 0;
    _selectedPaymentType = null;
    _customerName = null;
    _customerPhone = null;
    _customerAddress = null;
    _dueDays = null;
    notifyListeners();
  }

  void setDiscount(double discount) {
    _discount = discount;
    notifyListeners();
  }

  void setPaymentType(String type) {
    _selectedPaymentType = type;
    notifyListeners();
  }

  void setCustomer(String? name, String? phone, String? address) {
    _customerName = name;
    _customerPhone = phone;
    _customerAddress = address;
    notifyListeners();
  }

  void setDueDays(int? days) {
    _dueDays = days;
    notifyListeners();
  }

  void loadNextPage({
    DateTime? startDate,
    DateTime? endDate,
    String? paymentType,
    String? paymentStatus,
    String? invoiceNumber,
  }) {
    if (hasNextPage && !_isLoading) {
      fetchTransactions(
        startDate: startDate,
        endDate: endDate,
        paymentType: paymentType,
        paymentStatus: paymentStatus,
        invoiceNumber: invoiceNumber,
        page: _currentPage + 1,
      );
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class CartItem {
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final int stock;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.stock,
  });

  double get totalPrice => price * quantity;

  bool get isQuantityValid => quantity <= stock;

  CartItem copyWith({
    int? productId,
    String? productName,
    double? price,
    int? quantity,
    int? stock,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
    );
  }
}