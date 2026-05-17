import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/receivable_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/report_provider.dart';
import 'providers/user_provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final apiService = ApiService(storageService: storageService);

  runApp(MyApp(
    apiService: apiService,
    storageService: storageService,
  ));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final StorageService storageService;

  const MyApp({
    super.key,
    required this.apiService,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService, storageService)),
        ChangeNotifierProvider(create: (_) => ProductProvider(apiService)),
        ChangeNotifierProvider(create: (_) => TransactionProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ReceivableProvider(apiService)),
        ChangeNotifierProvider(create: (_) => DebtProvider(apiService)),
        ChangeNotifierProvider(create: (_) => StockProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ReportProvider(apiService)),
        ChangeNotifierProvider(create: (_) => UserProvider(apiService)),
      ],
      child: const GrosirApp(),
    );
  }
}