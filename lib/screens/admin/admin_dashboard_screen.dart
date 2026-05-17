import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/utils/formatters.dart';
import 'admin_products_screen.dart';
import 'admin_suppliers_screen.dart';
import 'admin_users_screen.dart';
import 'admin_debts_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_stock_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;

  final List<Widget> _screens = [
    const _AdminDashboardContent(),
    const AdminProductsScreen(),
    const AdminStockScreen(),
    const AdminSuppliersScreen(),
    const AdminDebtsScreen(),
    const AdminUsersScreen(),
    const AdminReportsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Produk',
    'Stok',
    'Supplier',
    'Hutang',
    'User',
    'Laporan',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.inventory,
    Icons.warehouse,
    Icons.local_shipping,
    Icons.credit_card,
    Icons.people,
    Icons.bar_chart,
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _dashboardData = {
      'today_sales': 2750000,
      'today_transactions': 18,
      'today_profit': 137500,
      'week_sales': 18500000,
      'total_receivable': 5200000,
      'total_debt': 4700000,
      'pending_receivables': 3,
      'overdue_receivables': 1,
      'low_stock_count': 2,
      'out_of_stock_count': 0,
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: List.generate(_titles.length, (index) {
          return NavigationDestination(
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

class _AdminDashboardContent extends StatefulWidget {
  const _AdminDashboardContent();

  @override
  State<_AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<_AdminDashboardContent> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _data = {
      'today_sales': 2750000,
      'today_transactions': 18,
      'today_profit': 137500,
      'week_sales': 18500000,
      'total_receivable': 5200000,
      'total_debt': 4700000,
      'pending_receivables': 3,
      'overdue_receivables': 1,
      'low_stock_count': 2,
      'out_of_stock_count': 0,
      'recent_transactions': [
        {'invoice': 'INV/20260516/001', 'customer': 'Budi Santoso', 'total': 520000, 'status': 'paid'},
        {'invoice': 'INV/20260516/002', 'customer': 'Siti Aisyah', 'total': 320000, 'status': 'partial'},
        {'invoice': 'INV/20260515/015', 'customer': 'Ahmad', 'total': 170000, 'status': 'paid'},
      ],
      'due_receivables': [
        {'customer': 'Siti Aisyah', 'remaining': 320000, 'due_date': '2026-06-15'},
        {'customer': 'Rudi', 'remaining': 150000, 'due_date': '2026-06-10'},
      ],
    };
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget();
    }

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
                  child: Icon(Icons.admin_panel_settings, size: 35, color: AppColors.primary),
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
                        Provider.of<AuthProvider>(context).user?.name ?? 'Administrator',
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
                    'ADMIN',
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
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text('Penjualan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text('Transaksi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text('Laba', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly Summary
          CustomCard(
            child: Column(
              children: [
                _buildSummaryRow('Penjualan Minggu Ini', _data!['week_sales'], isCurrency: true),
                const Divider(),
                _buildSummaryRow('Total Piutang', _data!['total_receivable'], isCurrency: true),
                const Divider(),
                _buildSummaryRow('Total Hutang', _data!['total_debt'], isCurrency: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Receivables Alert
          if (_data!['overdue_receivables'] > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Piutang Jatuh Tempo!',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
                        ),
                        Text(
                          'Ada ${_data!['overdue_receivables']} piutang yang sudah melewati jatuh tempo',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to receivables screen
                    },
                    child: const Text('Lihat'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Recent Transactions
          const Text(
            'Transaksi Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: (_data!['recent_transactions'] as List).map((transaction) {
                return Column(
                  children: [
                    _buildTransactionRow(
                      transaction['invoice'],
                      transaction['customer'],
                      transaction['total'],
                      transaction['status'],
                    ),
                    if (transaction != (_data!['recent_transactions'] as List).last) const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Due Receivables
          const Text(
            'Piutang Mendekati Jatuh Tempo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: (_data!['due_receivables'] as List).map((receivable) {
                return Column(
                  children: [
                    _buildReceivableRow(
                      receivable['customer'],
                      receivable['remaining'],
                      receivable['due_date'],
                    ),
                    if (receivable != (_data!['due_receivables'] as List).last) const Divider(),
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

  Widget _buildSummaryRow(String label, double value, {bool isCurrency = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            isCurrency ? Formatters.formatCurrency(value) : value.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String invoice, String customer, double total, String status) {
    final statusColor = status == 'paid' ? Colors.green : Colors.orange;
    final statusText = status == 'paid' ? 'Lunas' : 'Sebagian';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(customer, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceivableRow(String customer, double remaining, String dueDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('Jatuh tempo: $dueDate', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            Formatters.formatCurrency(remaining),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}