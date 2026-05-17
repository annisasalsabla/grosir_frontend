import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../models/receivable_model.dart';
import '../models/debt_model.dart';
import '../models/damaged_good_model.dart';
import '../models/supplier_model.dart';
import '../models/report_model.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService;
  String? _token;

  ApiService({required StorageService storageService}) : _storageService = storageService {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await _storageService.getToken();
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _storageService.saveToken(token);
  }

  Future<void> clearToken() async {
    _token = null;
    await _storageService.clearToken();
  }

  String get token => _token ?? '';

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _request(
      String method,
      String endpoint, {
        Map<String, dynamic>? data,
        Map<String, String>? queryParams,
      }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(queryParameters: queryParams);

    late http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: _headers, body: jsonEncode(data));
          break;
        case 'PUT':
          response = await http.put(uri, headers: _headers, body: jsonEncode(data));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers);
          break;
        default:
          throw Exception('Invalid HTTP method');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'Terjadi kesalahan',
          statusCode: response.statusCode,
          errors: responseData['errors'],
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // ==================== AUTH ====================

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _request('POST', ApiConfig.login, data: {
      'email': email,
      'password': password,
    });
    await setToken(response['data']['access_token']);
    return response;
  }

  Future<void> logout() async {
    await _request('POST', ApiConfig.logout);
    await clearToken();
  }

  Future<Map<String, dynamic>> getMe() async {
    return await _request('GET', ApiConfig.me);
  }

  Future<void> forgotPassword(String email) async {
    await _request('POST', ApiConfig.forgotPassword, data: {'email': email});
  }

  Future<void> resetPassword(String email, String token, String password) async {
    await _request('POST', ApiConfig.resetPassword, data: {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': password,
    });
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _request('POST', ApiConfig.changePassword, data: {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
    });
  }

  Future<Map<String, dynamic>> updateProfile(String name, String? phone) async {
    final data = {'name': name};
    if (phone != null) data['phone'] = phone;
    return await _request('PUT', ApiConfig.profile, data: data);
  }

  // ==================== DASHBOARD ====================

  Future<Map<String, dynamic>> getDashboard() async {
    return await _request('GET', ApiConfig.dashboard);
  }

  // ==================== USERS ====================

  Future<Map<String, dynamic>> getUsers({
    String? role,
    String? search,
    int? page,
    int? perPage,
  }) async {
    final params = <String, String>{};
    if (role != null) params['role'] = role;
    if (search != null) params['search'] = search;
    if (page != null) params['page'] = page.toString();
    if (perPage != null) params['per_page'] = perPage.toString();
    return await _request('GET', ApiConfig.users, queryParams: params);
  }

  Future<Map<String, dynamic>> createUser(UserCreateRequest request) async {
    return await _request('POST', ApiConfig.users, data: request.toJson());
  }

  Future<Map<String, dynamic>> updateUser(int userId, UserUpdateRequest request) async {
    return await _request('PUT', '${ApiConfig.users}/$userId', data: request.toJson());
  }

  Future<void> deleteUser(int userId) async {
    await _request('DELETE', '${ApiConfig.users}/$userId');
  }

  Future<void> activateUser(int userId) async {
    await _request('POST', '${ApiConfig.users}/$userId/activate');
  }

  Future<void> deactivateUser(int userId) async {
    await _request('POST', '${ApiConfig.users}/$userId/deactivate');
  }

  Future<void> resetUserPassword(int userId) async {
    await _request('POST', '${ApiConfig.users}/$userId/reset-password');
  }

  Future<Map<String, dynamic>> getUserStats() async {
    return await _request('GET', ApiConfig.usersStats);
  }

  // ==================== SUPPLIERS ====================

  Future<Map<String, dynamic>> getSuppliers({String? productType, int? page}) async {
    final params = <String, String>{};
    if (productType != null) params['product_type'] = productType;
    if (page != null) params['page'] = page.toString();
    return await _request('GET', ApiConfig.suppliers, queryParams: params);
  }

  Future<Map<String, dynamic>> createSupplier(SupplierRequest request) async {
    return await _request('POST', ApiConfig.suppliers, data: request.toJson());
  }

  Future<Map<String, dynamic>> updateSupplier(int supplierId, SupplierUpdateRequest request) async {
    return await _request('PUT', '${ApiConfig.suppliers}/$supplierId', data: request.toJson());
  }

  Future<void> deleteSupplier(int supplierId) async {
    await _request('DELETE', '${ApiConfig.suppliers}/$supplierId');
  }

  // ==================== PRODUCTS ====================

  Future<Map<String, dynamic>> getProducts({
    String? productType,
    String? search,
    bool? isActive,
    int? page,
    int? perPage,
  }) async {
    final params = <String, String>{};
    if (productType != null) params['product_type'] = productType;
    if (search != null) params['search'] = search;
    if (isActive != null) params['is_active'] = isActive.toString();
    if (page != null) params['page'] = page.toString();
    if (perPage != null) params['per_page'] = perPage.toString();
    return await _request('GET', ApiConfig.products, queryParams: params);
  }

  Future<Map<String, dynamic>> getProduct(int productId) async {
    return await _request('GET', '${ApiConfig.products}/$productId');
  }

  Future<Map<String, dynamic>> createProduct(ProductCreateRequest request) async {
    return await _request('POST', ApiConfig.products, data: request.toJson());
  }

  Future<Map<String, dynamic>> updateProduct(int productId, Map<String, dynamic> data) async {
    return await _request('PUT', '${ApiConfig.products}/$productId', data: data);
  }

  Future<void> deleteProduct(int productId) async {
    await _request('DELETE', '${ApiConfig.products}/$productId');
  }

  Future<Map<String, dynamic>> getLowStockProducts({int? page}) async {
    final params = page != null ? {'page': page.toString()} : null;
    return await _request('GET', ApiConfig.productsLowStock, queryParams: params);
  }

  Future<Map<String, dynamic>> getCategories() async {
    return await _request('GET', ApiConfig.productsCategories);
  }

  Future<Map<String, dynamic>> updateStock(int productId, int quantity, String type, {String? description}) async {
    return await _request('POST', '${ApiConfig.products}/$productId/stock', data: {
      'quantity': quantity,
      'type': type,
      if (description != null) 'description': description,
    });
  }

  // ==================== TRANSACTIONS ====================

  Future<Map<String, dynamic>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? paymentType,
    String? paymentStatus,
    String? invoiceNumber,
    int? page,
    int? perPage,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['start_date'] = startDate.toIso8601String().split('T').first;
    if (endDate != null) params['end_date'] = endDate.toIso8601String().split('T').first;
    if (paymentType != null) params['payment_type'] = paymentType;
    if (paymentStatus != null) params['payment_status'] = paymentStatus;
    if (invoiceNumber != null) params['invoice_number'] = invoiceNumber;
    if (page != null) params['page'] = page.toString();
    if (perPage != null) params['per_page'] = perPage.toString();
    return await _request('GET', ApiConfig.transactions, queryParams: params);
  }

  Future<Map<String, dynamic>> createTransaction(TransactionRequest request) async {
    return await _request('POST', ApiConfig.transactions, data: request.toJson());
  }

  Future<Map<String, dynamic>> getTransaction(int transactionId) async {
    return await _request('GET', '${ApiConfig.transactions}/$transactionId');
  }

  Future<Map<String, dynamic>> getInvoice(int transactionId) async {
    return await _request('GET', '${ApiConfig.transactions}/$transactionId/invoice');
  }

  Future<Map<String, dynamic>> getDailyReport({DateTime? date}) async {
    final params = date != null ? {'date': date.toIso8601String().split('T').first} : null;
    return await _request('GET', ApiConfig.transactionsDailyReport, queryParams: params);
  }

  // ==================== RECEIVABLES ====================

  Future<Map<String, dynamic>> getReceivables({
    String? status,
    int? customerId,
    int? page,
    int? perPage,
  }) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (customerId != null) params['customer_id'] = customerId.toString();
    if (page != null) params['page'] = page.toString();
    if (perPage != null) params['per_page'] = perPage.toString();
    return await _request('GET', ApiConfig.receivables, queryParams: params);
  }

  Future<Map<String, dynamic>> getReceivable(int receivableId) async {
    return await _request('GET', '${ApiConfig.receivables}/$receivableId');
  }

  Future<Map<String, dynamic>> payReceivable(int receivableId, double amount, String paymentMethod, {String? notes}) async {
    return await _request('POST', '${ApiConfig.receivables}/$receivableId/pay', data: {
      'amount': amount,
      'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
    });
  }

  Future<Map<String, dynamic>> getOverdueReceivables() async {
    return await _request('GET', ApiConfig.receivablesOverdue);
  }

  Future<Map<String, dynamic>> getReceivableReport() async {
    return await _request('GET', ApiConfig.receivablesReport);
  }

  // ==================== DEBTS ====================

  Future<Map<String, dynamic>> getDebts({
    int? supplierId,
    String? status,
    int? page,
    int? perPage,
  }) async {
    final params = <String, String>{};
    if (supplierId != null) params['supplier_id'] = supplierId.toString();
    if (status != null) params['status'] = status;
    if (page != null) params['page'] = page.toString();
    if (perPage != null) params['per_page'] = perPage.toString();
    return await _request('GET', ApiConfig.debts, queryParams: params);
  }

  Future<Map<String, dynamic>> getDebt(int debtId) async {
    return await _request('GET', '${ApiConfig.debts}/$debtId');
  }

  Future<Map<String, dynamic>> createDebt(DebtRequest request) async {
    return await _request('POST', ApiConfig.debts, data: request.toJson());
  }

  Future<Map<String, dynamic>> payDebt(int debtId, double amount, String paymentMethod, {String? notes}) async {
    return await _request('POST', '${ApiConfig.debts}/$debtId/pay', data: {
      'amount': amount,
      'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
    });
  }

  Future<Map<String, dynamic>> getOverdueDebts() async {
    return await _request('GET', ApiConfig.debtsOverdue);
  }

  Future<Map<String, dynamic>> getDebtReport() async {
    return await _request('GET', ApiConfig.debtsReport);
  }

  // ==================== DAMAGED GOODS ====================

  Future<Map<String, dynamic>> getDamagedGoods({
    int? productId,
    String? damageType,
    bool? reportedToSupplier,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? perPage,
  }) async {
    final params = <String, String>{};
    if (productId != null) params['product_id'] = productId.toString();
    if (damageType != null) params['damage_type'] = damageType;
    if (reportedToSupplier != null) params['reported_to_supplier'] = reportedToSupplier.toString();
    if (startDate != null) params['start_date'] = startDate.toIso8601String().split('T').first;
    if (endDate != null) params['end_date'] = endDate.toIso8601String().split('T').first;
    if (page != null) params['page'] = page.toString();
    if (perPage != null) params['per_page'] = perPage.toString();
    return await _request('GET', ApiConfig.damagedGoods, queryParams: params);
  }

  Future<Map<String, dynamic>> createDamagedGood(DamagedGoodRequest request) async {
    return await _request('POST', ApiConfig.damagedGoods, data: request.toJson());
  }

  Future<Map<String, dynamic>> updateDamagedGood(int damagedGoodId, Map<String, dynamic> data) async {
    return await _request('PUT', '${ApiConfig.damagedGoods}/$damagedGoodId', data: data);
  }

  Future<void> deleteDamagedGood(int damagedGoodId) async {
    await _request('DELETE', '${ApiConfig.damagedGoods}/$damagedGoodId');
  }

  Future<Map<String, dynamic>> reportDamagedGoodToSupplier(int damagedGoodId) async {
    return await _request('POST', '${ApiConfig.damagedGoods}/$damagedGoodId/report-to-supplier');
  }

  Future<Map<String, dynamic>> getDamagedGoodsReport(DateTime startDate, DateTime endDate, {String? productType}) async {
    final params = {
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
    };
    if (productType != null) params['product_type'] = productType;
    return await _request('GET', ApiConfig.damagedGoodsReport, queryParams: params);
  }

  // ==================== STOCK ====================

  Future<Map<String, dynamic>> getStockMutations({
    int? productId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? perPage,
  }) async {
    final params = <String, String>{};
    if (productId != null) params['product_id'] = productId.toString();
    if (type != null) params['type'] = type;
    if (startDate != null) params['start_date'] = startDate.toIso8601String().split('T').first;
    if (endDate != null) params['end_date'] = endDate.toIso8601String().split('T').first;
    if (page != null) params['page'] = page.toString();
    if (perPage != null) params['per_page'] = perPage.toString();
    return await _request('GET', ApiConfig.stockMutations, queryParams: params);
  }

  Future<Map<String, dynamic>> getProductStockHistory(int productId, {int? page}) async {
    final params = page != null ? {'page': page.toString()} : null;
    return await _request('GET', '/api/stock/product/$productId/history', queryParams: params);
  }

  Future<Map<String, dynamic>> getStockSummary() async {
    return await _request('GET', ApiConfig.stockSummary);
  }

  // ==================== REPORTS ====================

  Future<Map<String, dynamic>> getSalesReport(String period, {DateTime? date}) async {
    final params = {'period': period};
    if (date != null) params['date'] = date.toIso8601String().split('T').first;
    return await _request('GET', ApiConfig.reportsSales, queryParams: params);
  }

  Future<Map<String, dynamic>> getProfitReport(DateTime startDate, DateTime endDate) async {
    return await _request('GET', ApiConfig.reportsProfit, queryParams: {
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
    });
  }

  Future<Map<String, dynamic>> getEggProfitReport(DateTime startDate, DateTime endDate) async {
    return await _request('GET', ApiConfig.reportsEggProfit, queryParams: {
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
    });
  }

  Future<Map<String, dynamic>> getRiceProfitReport(DateTime startDate, DateTime endDate) async {
    return await _request('GET', ApiConfig.reportsRiceProfit, queryParams: {
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
    });
  }

  Future<Map<String, dynamic>> getStockReport({String? productType}) async {
    final params = productType != null ? {'product_type': productType} : null;
    return await _request('GET', ApiConfig.reportsStock, queryParams: params);
  }

  // ==================== EXPORTS ====================

  Future<http.Response> exportSalesExcel(DateTime startDate, DateTime endDate) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.exportSalesExcel}').replace(queryParameters: {
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
    });
    return await http.get(uri, headers: _headers);
  }

  Future<http.Response> exportSalesPdf(DateTime startDate, DateTime endDate) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.exportSalesPdf}').replace(queryParameters: {
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
    });
    return await http.get(uri, headers: _headers);
  }

  Future<http.Response> exportProfitExcel(DateTime startDate, DateTime endDate) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.exportProfitExcel}').replace(queryParameters: {
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
    });
    return await http.get(uri, headers: _headers);
  }

  Future<http.Response> exportProfitPdf(DateTime startDate, DateTime endDate) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.exportProfitPdf}').replace(queryParameters: {
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
    });
    return await http.get(uri, headers: _headers);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode = 500,
    this.errors,
  });

  @override
  String toString() => message;
}