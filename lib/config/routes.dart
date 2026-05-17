import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/owner/owner_dashboard_screen.dart';
import '../screens/owner/owner_reports_screen.dart';
import '../screens/owner/owner_stock_screen.dart';
import '../screens/owner/owner_receivables_screen.dart';
import '../screens/owner/owner_debts_screen.dart';
import '../screens/owner/owner_users_screen.dart';
import '../screens/owner/owner_profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_products_screen.dart';
import '../screens/admin/admin_product_form_screen.dart';
import '../screens/admin/admin_stock_screen.dart';
import '../screens/admin/admin_suppliers_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_user_form_screen.dart';
import '../screens/admin/admin_debts_screen.dart';
import '../screens/admin/admin_debt_form_screen.dart';
import '../screens/admin/admin_reports_screen.dart';
import '../screens/cashier/cashier_dashboard_screen.dart';
import '../screens/cashier/cashier_transaction_screen.dart';
import '../screens/cashier/cashier_cart_screen.dart';
import '../screens/cashier/cashier_receivables_screen.dart';
import '../screens/cashier/cashier_damaged_goods_screen.dart';
import '../screens/cashier/cashier_stock_screen.dart';
import '../screens/cashier/cashier_profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Owner Routes
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerReports = '/owner/reports';
  static const String ownerStock = '/owner/stock';
  static const String ownerReceivables = '/owner/receivables';
  static const String ownerDebts = '/owner/debts';
  static const String ownerUsers = '/owner/users';
  static const String ownerProfile = '/owner/profile';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminProductForm = '/admin/products/form';
  static const String adminStock = '/admin/stock';
  static const String adminSuppliers = '/admin/suppliers';
  static const String adminUsers = '/admin/users';
  static const String adminUserForm = '/admin/users/form';
  static const String adminDebts = '/admin/debts';
  static const String adminDebtForm = '/admin/debts/form';
  static const String adminReports = '/admin/reports';

  // Cashier Routes
  static const String cashierDashboard = '/cashier/dashboard';
  static const String cashierTransaction = '/cashier/transaction';
  static const String cashierCart = '/cashier/cart';
  static const String cashierReceivables = '/cashier/receivables';
  static const String cashierDamagedGoods = '/cashier/damaged-goods';
  static const String cashierStock = '/cashier/stock';
  static const String cashierProfile = '/cashier/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // Auth
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

    // Owner
      case ownerDashboard:
        return MaterialPageRoute(builder: (_) => const OwnerDashboardScreen());
      case ownerReports:
        return MaterialPageRoute(builder: (_) => const OwnerReportsScreen());
      case ownerStock:
        return MaterialPageRoute(builder: (_) => const OwnerStockScreen());
      case ownerReceivables:
        return MaterialPageRoute(builder: (_) => const OwnerReceivablesScreen());
      case ownerDebts:
        return MaterialPageRoute(builder: (_) => const OwnerDebtsScreen());
      case ownerUsers:
        return MaterialPageRoute(builder: (_) => const OwnerUsersScreen());
      case ownerProfile:
        return MaterialPageRoute(builder: (_) => const OwnerProfileScreen());

    // Admin
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminProducts:
        return MaterialPageRoute(builder: (_) => const AdminProductsScreen());
      case adminProductForm:
        return MaterialPageRoute(builder: (_) => const AdminProductFormScreen());
      case adminStock:
        return MaterialPageRoute(builder: (_) => const AdminStockScreen());
      case adminSuppliers:
        return MaterialPageRoute(builder: (_) => const AdminSuppliersScreen());
      case adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUsersScreen());
      case adminUserForm:
        return MaterialPageRoute(builder: (_) => const AdminUserFormScreen());
      case adminDebts:
        return MaterialPageRoute(builder: (_) => const AdminDebtsScreen());
      case adminDebtForm:
        return MaterialPageRoute(builder: (_) => const AdminDebtFormScreen());
      case adminReports:
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());

    // Cashier
      case cashierDashboard:
        return MaterialPageRoute(builder: (_) => const CashierDashboardScreen());
      case cashierTransaction:
        return MaterialPageRoute(builder: (_) => const CashierTransactionScreen());
      case cashierCart:
        return MaterialPageRoute(builder: (_) => const CashierCartScreen());
      case cashierReceivables:
        return MaterialPageRoute(builder: (_) => const CashierReceivablesScreen());
      case cashierDamagedGoods:
        return MaterialPageRoute(builder: (_) => const CashierDamagedGoodsScreen());
      case cashierStock:
        return MaterialPageRoute(builder: (_) => const CashierStockScreen());
      case cashierProfile:
        return MaterialPageRoute(builder: (_) => const CashierProfileScreen());

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}