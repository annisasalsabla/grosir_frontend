import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _apiService;

  SalesReport? _salesReport;
  ProfitReport? _profitReport;
  bool _isLoading = false;
  String? _error;

  ReportProvider(this._apiService);

  SalesReport? get salesReport => _salesReport;
  ProfitReport? get profitReport => _profitReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSalesReport(String period, {DateTime? date}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getSalesReport(period, date: date);
      _salesReport = SalesReport.fromJson(response['data']);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfitReport(DateTime startDate, DateTime endDate) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getProfitReport(startDate, endDate);
      _profitReport = ProfitReport.fromJson(response['data']);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportSalesExcel(DateTime startDate, DateTime endDate) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.exportSalesExcel(startDate, endDate);
      // Handle file download
      // This would typically use path_provider to save the file
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportSalesPdf(DateTime startDate, DateTime endDate) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.exportSalesPdf(startDate, endDate);
      // Handle file download
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