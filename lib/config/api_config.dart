class ApiConfig {
  // Development
  static const String baseUrl = 'http://localhost:8000';
  // static const String baseUrl = 'https://api.grosirtiga.com'; // Production

  static const String login = '/api/login';
  static const String logout = '/api/logout';
  static const String me = '/api/me';
  static const String forgotPassword = '/api/forgot-password';
  static const String resetPassword = '/api/reset-password';
  static const String changePassword = '/api/change-password';
  static const String profile = '/api/profile';
  static const String dashboard = '/api/dashboard';

  // Users
  static const String users = '/api/users';
  static const String usersStats = '/api/users/stats';

  // Products
  static const String products = '/api/products';
  static const String productsLowStock = '/api/products/low-stock';
  static const String productsCategories = '/api/products/categories';
  static const String productsStock = '/api/products/';

  // Suppliers
  static const String suppliers = '/api/suppliers';

  // Transactions
  static const String transactions = '/api/transactions';
  static const String transactionsDailyReport = '/api/transactions/daily-report';

  // Receivables
  static const String receivables = '/api/receivables';
  static const String receivablesOverdue = '/api/receivables/overdue';
  static const String receivablesReport = '/api/receivables/report';

  // Debts
  static const String debts = '/api/debts';
  static const String debtsOverdue = '/api/debts/overdue';
  static const String debtsReport = '/api/debts/report';

  // Damaged Goods
  static const String damagedGoods = '/api/damaged-goods';
  static const String damagedGoodsReport = '/api/damaged-goods/report';

  // Stock
  static const String stockMutations = '/api/stock/mutations';
  static const String stockSummary = '/api/stock/summary';

  // Reports
  static const String reportsSales = '/api/reports/sales';
  static const String reportsProfit = '/api/reports/profit';
  static const String reportsEggProfit = '/api/reports/egg-profit';
  static const String reportsRiceProfit = '/api/reports/rice-profit';
  static const String reportsStock = '/api/reports/stock';

  // Exports
  static const String exportSalesExcel = '/api/reports/sales/export-excel';
  static const String exportSalesPdf = '/api/reports/sales/export-pdf';
  static const String exportProfitExcel = '/api/reports/profit/export-excel';
  static const String exportProfitPdf = '/api/reports/profit/export-pdf';
  static const String exportReceivableExcel = '/api/reports/receivables/export-excel';
  static const String exportReceivablePdf = '/api/reports/receivables/export-pdf';
  static const String exportDebtExcel = '/api/reports/debts/export-excel';
  static const String exportDebtPdf = '/api/reports/debts/export-pdf';
  static const String exportStockExcel = '/api/reports/stock/export-excel';
  static const String exportStockPdf = '/api/reports/stock/export-pdf';
}