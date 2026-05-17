class AppConstants {
  static const String appName = 'Grosir Tiga Bersaudara';
  static const String appVersion = '1.0.0';

  // Product types
  static const List<String> productTypes = ['egg', 'rice'];
  static const List<String> eggSizes = ['kecil', 'super', 'jumbo'];
  static const List<String> riceVariants = ['iR42'];

  // Payment types
  static const List<String> paymentTypes = ['cash', 'transfer', 'qris', 'receivable'];
  static const List<String> paymentTypeLabels = ['Tunai', 'Transfer', 'QRIS', 'Piutang'];

  // Damage types
  static const List<String> damageTypes = ['cracked', 'rotten', 'broken', 'expired', 'wet'];
  static const Map<String, String> damageTypeLabels = {
    'cracked': 'Retak/Pecah',
    'rotten': 'Busuk',
    'broken': 'Hancur',
    'expired': 'Kadaluarsa',
    'wet': 'Basah',
  };

  // Report periods
  static const List<String> reportPeriods = ['daily', 'weekly', 'monthly', 'yearly'];
  static const List<String> reportPeriodLabels = ['Harian', 'Mingguan', 'Bulanan', 'Tahunan'];

  // User roles
  static const List<String> userRoles = ['administrator', 'cashier'];
  static const Map<String, String> userRoleLabels = {
    'owner': 'Pemilik',
    'administrator': 'Administrator',
    'cashier': 'Kasir',
  };

  // Pagination
  static const int defaultPageSize = 15;

  // Cache keys
  static const String cacheProducts = 'products';
  static const String cacheCategories = 'categories';
  static const String cacheDashboard = 'dashboard';

  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
}