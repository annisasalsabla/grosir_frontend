import 'package:flutter/material.dart';
import '../models/receivable_model.dart';
import '../services/api_service.dart';

class ReceivableProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Receivable> _receivables = [];
  List<Receivable> _overdueReceivables = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  Map<String, dynamic>? _report;

  ReceivableProvider(this._apiService);

  List<Receivable> get receivables => _receivables;
  List<Receivable> get overdueReceivables => _overdueReceivables;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasNextPage => _currentPage < _lastPage;
  Map<String, dynamic>? get report => _report;

  Future<void> fetchReceivables({
    String? status,
    int? customerId,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _receivables = [];
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getReceivables(
        status: status,
        customerId: customerId,
        page: page,
      );

      final data = response['data'] as List;
      final newReceivables = data.map((json) => Receivable.fromJson(json)).toList();

      if (refresh) {
        _receivables = newReceivables;
      } else {
        _receivables.addAll(newReceivables);
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

  Future<Receivable?> getReceivable(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getReceivable(id);
      return Receivable.fromJson(response['data']);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payReceivable(int id, double amount, String paymentMethod, {String? notes}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.payReceivable(id, amount, paymentMethod, notes: notes);
      await fetchReceivables(refresh: true);
      await fetchOverdueReceivables();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOverdueReceivables() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getOverdueReceivables();
      _overdueReceivables = (response['data'] as List)
          .map((json) => Receivable.fromJson(json))
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

      final response = await _apiService.getReceivableReport();
      _report = response['data'];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadNextPage({String? status, int? customerId}) {
    if (hasNextPage && !_isLoading) {
      fetchReceivables(
        status: status,
        customerId: customerId,
        page: _currentPage + 1,
      );
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}