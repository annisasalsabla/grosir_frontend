import 'package:flutter/material.dart';
import '../models/debt_model.dart';
import '../services/api_service.dart';

class DebtProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Debt> _debts = [];
  List<Debt> _overdueDebts = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  Map<String, dynamic>? _report;

  DebtProvider(this._apiService);

  List<Debt> get debts => _debts;
  List<Debt> get overdueDebts => _overdueDebts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasNextPage => _currentPage < _lastPage;
  Map<String, dynamic>? get report => _report;

  Future<void> fetchDebts({
    int? supplierId,
    String? status,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _debts = [];
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getDebts(
        supplierId: supplierId,
        status: status,
        page: page,
      );

      final data = response['data'] as List;
      final newDebts = data.map((json) => Debt.fromJson(json)).toList();

      if (refresh) {
        _debts = newDebts;
      } else {
        _debts.addAll(newDebts);
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

  Future<Debt?> getDebt(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getDebt(id);
      return Debt.fromJson(response['data']);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDebt(DebtRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.createDebt(request);
      await fetchDebts(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payDebt(int id, double amount, String paymentMethod, {String? notes}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.payDebt(id, amount, paymentMethod, notes: notes);
      await fetchDebts(refresh: true);
      await fetchOverdueDebts();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOverdueDebts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getOverdueDebts();
      _overdueDebts = (response['data'] as List)
          .map((json) => Debt.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReport() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getDebtReport();
      _report = response['data'];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadNextPage({int? supplierId, String? status}) {
    if (hasNextPage && !_isLoading) {
      fetchDebts(
        supplierId: supplierId,
        status: status,
        page: _currentPage + 1,
      );
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}