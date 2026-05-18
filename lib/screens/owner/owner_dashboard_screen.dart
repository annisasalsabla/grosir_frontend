import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grosir_tiga_bersaudara/providers/debt_provider.dart.dart';
import 'package:grosir_tiga_bersaudara/screens/owner/owner_reports_screen.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/utils/formatters.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/chart_widget.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/custom_card.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/receivable_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'owner_stock_screen.dart';
import 'owner_receivables_screen.dart';
import 'owner_debts_screen.dart';
import 'owner_users_screen.dart';
import 'owner_profile_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;

  final List<Widget> _screens = [
    const _DashboardContent(),
    const OwnerReportsScreen(),
    const OwnerStockScreen(),
    const OwnerReceivablesScreen(),
    const OwnerDebtsScreen(),
    const OwnerUsersScreen(),
    const OwnerProfileScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Laporan',
    'Stok',
    'Piutang',
    'Hutang',
    'User',
    'Profil',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.bar_chart,
    Icons.inventory,
    Icons.receipt,
    Icons.credit_card,
    Icons.people,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    await reportProvider.fetchSalesReport('daily');
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchLowStockProducts();
    final receivableProvider = Provider.of<ReceivableProvider>(context, listen: false);
    await receivableProvider.fetchReceivables(status: 'pending');
    final debtProvider = Provider.of<DebtProvider>(context, listen: false);
    await debtProvider.fetchDebts(status: 'pending');

    // Simulate dashboard data
    _dashboardData = {
      'today_sales': 2750000,
      'today_transactions': 18,
      'today_profit': 137500,
      'monthly_sales': 87500000,
      'monthly_profit': 4375000,
      'sales_growth': 12.5,
      'total_receivable': 5200000,
      'total_debt': 4700000,
      'low_stock_count': 2,
    };
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    if (isTablet) {
      return _buildTabletLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: List.generate(_titles.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _titles[index],
          );
        }),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: List.generate(_titles.length, (index) {
              return NavigationRailDestination(
                icon: Icon(_icons[index]),
                label: Text(_titles[index]),
              );
            }),
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(_titles[_selectedIndex]),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadDashboard,
                  ),
                ],
              ),
              body: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    _data = {
      'today_sales': 2750000,
      'today_transactions': 18,
      'today_profit': 137500,
      'monthly_sales': 87500000,
      'monthly_profit': 4375000,
      'sales_growth': 12.5,
      'total_receivable': 5200000,
      'total_debt': 4700000,
      'low_stock_count': 2,
      'chart_data': [
        {'date': '10/05', 'sales': 2100000},
        {'date': '11/05', 'sales': 2350000},
        {'date': '12/05', 'sales': 1980000},
        {'date': '13/05', 'sales': 2670000},
        {'date': '14/05', 'sales': 2890000},
        {'date': '15/05', 'sales': 3120000},
        {'date': '16/05', 'sales': 2750000},
      ],
      'top_products': [
        {'name': 'Telur Super', 'quantity': 245, 'total': 13475000},
        {'name': 'Beras iR42', 'quantity': 180, 'total': 30600000},
        {'name': 'Telur Jumbo', 'quantity': 156, 'total': 9360000},
      ],
    };
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget();
    }

    final chartSpots = (_data!['chart_data'] as List).asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value['sales'].toDouble());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, size: 35, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang,',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        Provider.of<AuthProvider>(context).user?.name ?? 'Owner',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'OWNER',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today Stats
          const Text(
            'Statistik Hari Ini',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.attach_money, size: 32, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(_data!['today_sales']),
                        style: AppTextStyles.statValue,
                      ),
                      const Text('Penjualan', style: AppTextStyles.statLabel),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.receipt, size: 32, color: AppColors.secondary),
                      const SizedBox(height: 8),
                      Text(
                        '${_data!['today_transactions']}',
                        style: AppTextStyles.statValue,
                      ),
                      const Text('Transaksi', style: AppTextStyles.statLabel),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.trending_up, size: 32, color: AppColors.warning),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(_data!['today_profit']),
                        style: AppTextStyles.statValue,
                      ),
                      const Text('Laba', style: AppTextStyles.statLabel),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart
          LineChartWidget(
            spots: chartSpots,
            title: 'Penjualan 7 Hari Terakhir',
            lineColor: AppColors.primary,
            unit: '',
          ),
          const SizedBox(height: 24),

          // Monthly Summary
          const Text(
            'Ringkasan Bulan Ini',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                _buildSummaryRow('Total Penjualan', _data!['monthly_sales'], isCurrency: true),
                const Divider(),
                _buildSummaryRow('Total Laba', _data!['monthly_profit'], isCurrency: true),
                const Divider(),
                _buildSummaryRow('Pertumbuhan', _data!['sales_growth'], suffix: '%'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Financial Status
          const Text(
            'Status Keuangan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.payment, size: 32, color: AppColors.error),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(_data!['total_receivable']),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                      const Text('Piutang', style: AppTextStyles.statLabel),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.credit_card, size: 32, color: AppColors.warning),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(_data!['total_debt']),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.warning),
                      ),
                      const Text('Hutang', style: AppTextStyles.statLabel),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.warning_amber, size: 32, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        '${_data!['low_stock_count']}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text('Stok Menipis', style: AppTextStyles.statLabel),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top Products
          const Text(
            'Produk Terlaris',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: (_data!['top_products'] as List).map((product) {
                return Column(
                  children: [
                    _buildProductRow(
                      product['name'],
                      product['quantity'],
                      product['total'],
                    ),
                    if (product != (_data!['top_products'] as List).last) const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isCurrency = false, String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            isCurrency ? Formatters.formatCurrency(value) : '$value$suffix',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(String name, int quantity, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${Formatters.formatNumber(quantity)} kg', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Text(Formatters.formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}