import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/receivable_provider.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/utils/formatters.dart';
import 'cashier_transaction_screen.dart';
import 'cashier_receivables_screen.dart';
import 'cashier_damaged_goods_screen.dart';
import 'cashier_stock_screen.dart';
import 'cashier_profile_screen.dart';

class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;

  final List<Widget> _screens = [
    const _CashierDashboardContent(),
    const CashierTransactionScreen(),
    const CashierReceivablesScreen(),
    const CashierDamagedGoodsScreen(),
    const CashierStockScreen(),
    const CashierProfileScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Transaksi',
    'Piutang',
    'Barang Rusak',
    'Stok',
    'Profil',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.shopping_cart,
    Icons.receipt,
    Icons.warning_amber,
    Icons.inventory,
    Icons.person,
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
      'pending_receivables': 3,
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
              ),
              body: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _CashierDashboardContent extends StatefulWidget {
  const _CashierDashboardContent();

  @override
  State<_CashierDashboardContent> createState() => _CashierDashboardContentState();
}

class _CashierDashboardContentState extends State<_CashierDashboardContent> {
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
      'pending_receivables': 3,
      'low_stock_count': 2,
      'recent_transactions': [
        {'invoice': 'INV/20260516/001', 'customer': 'Budi Santoso', 'total': 520000, 'status': 'paid'},
        {'invoice': 'INV/20260516/002', 'customer': 'Siti Aisyah', 'total': 320000, 'status': 'partial'},
        {'invoice': 'INV/20260515/015', 'customer': 'Ahmad', 'total': 170000, 'status': 'paid'},
      ],
      'low_stock_products': [
        {'name': 'Telur Kecil', 'stock': 15, 'min_stock': 20},
        {'name': 'Telur Super', 'stock': 12, 'min_stock': 20},
      ],
    };
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

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
                  child: Icon(Icons.person, size: 35, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Bertugas,',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        user?.name ?? 'Kasir',
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
                    'KASIR',
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

          // Quick Actions
          const Text(
            'Aksi Cepat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.shopping_cart,
                  label: 'Transaksi Baru',
                  color: AppColors.primary,
                  onTap: () {
                    // Navigate to transaction screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CashierTransactionScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.receipt,
                  label: 'Piutang',
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CashierReceivablesScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.warning_amber,
                  label: 'Barang Rusak',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CashierDamagedGoodsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Low Stock Alert
          if ((_data!['low_stock_products'] as List).isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Stok Menipis!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...(_data!['low_stock_products'] as List).map((product) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(product['name']),
                          Text(
                            'Stok: ${product['stock']} kg',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

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
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
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
}