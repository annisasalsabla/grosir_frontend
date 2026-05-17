import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/chart_widget.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/utils/constants.dart';

class OwnerReportsScreen extends StatefulWidget {
  const OwnerReportsScreen({super.key});

  @override
  State<OwnerReportsScreen> createState() => _OwnerReportsScreenState();
}

class _OwnerReportsScreenState extends State<OwnerReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'monthly';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic>? _salesData;
  Map<String, dynamic>? _profitData;
  Map<String, dynamic>? _eggProfitData;
  Map<String, dynamic>? _riceProfitData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    await reportProvider.fetchSalesReport(_selectedPeriod, date: _selectedDate);
    _salesData = reportProvider.salesReport?.toJson();

    final startDate = _getStartDate();
    final endDate = _getEndDate();

    await reportProvider.fetchProfitReport(startDate, endDate);
    _profitData = reportProvider.profitReport?.toJson();

    await reportProvider.fetchEggProfitReport(startDate, endDate);
    _eggProfitData = reportProvider.eggProfitReport?.toJson();

    await reportProvider.fetchRiceProfitReport(startDate, endDate);
    _riceProfitData = reportProvider.riceProfitReport?.toJson();

    setState(() => _isLoading = false);
  }

  DateTime _getStartDate() {
    switch (_selectedPeriod) {
      case 'daily':
        return _selectedDate;
      case 'weekly':
        return _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      case 'monthly':
        return DateTime(_selectedDate.year, _selectedDate.month, 1);
      case 'yearly':
        return DateTime(_selectedDate.year, 1, 1);
      default:
        return _selectedDate;
    }
  }

  DateTime _getEndDate() {
    switch (_selectedPeriod) {
      case 'daily':
        return _selectedDate;
      case 'weekly':
        return _getStartDate().add(const Duration(days: 6));
      case 'monthly':
        return DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      case 'yearly':
        return DateTime(_selectedDate.year, 12, 31);
      default:
        return _selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Penjualan'),
            Tab(text: 'Laba'),
            Tab(text: 'Produk'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPeriod,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Harian')),
                          DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                          DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
                          DropdownMenuItem(value: 'yearly', child: Text('Tahunan')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedPeriod = value);
                            _loadReports();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                        _loadReports();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Text(Formatters.formatDate(_selectedDate)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadReports,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const LoadingWidget(fullScreen: false)
                : TabBarView(
              controller: _tabController,
              children: [
                _buildSalesReport(),
                _buildProfitReport(),
                _buildProductReport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesReport() {
    if (_salesData == null) {
      return const EmptyStateWidget(
        title: 'Tidak Ada Data',
        message: 'Tidak ada data penjualan untuk periode ini',
        icon: Icons.bar_chart,
      );
    }

    final totalSales = _salesData!['total_sales'] ?? 0;
    final totalTransactions = _salesData!['total_transactions'] ?? 0;
    final totalProfit = _salesData!['total_profit'] ?? 0;
    final productSales = _salesData!['product_sales'] as List? ?? [];
    final dailyBreakdown = _salesData!['daily_breakdown'] as Map<String, dynamic>? ?? {};

    final chartSpots = dailyBreakdown.entries.map((e) {
      return FlSpot(e.key.hashCode.toDouble(), e.value.toDouble());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.attach_money, size: 32, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(totalSales),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text('Total Penjualan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                        totalTransactions.toString(),
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
                        Formatters.formatCurrency(totalProfit),
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

          // Chart
          if (dailyBreakdown.isNotEmpty)
            LineChartWidget(
              spots: chartSpots,
              title: 'Tren Penjualan',
              lineColor: AppColors.primary,
            ),
          const SizedBox(height: 24),

          // Product Sales Detail
          const Text(
            'Detail Penjualan per Produk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: productSales.map((product) {
                return Column(
                  children: [
                    _buildProductSalesRow(
                      product['product_name'],
                      product['quantity'],
                      product['total'],
                    ),
                    if (product != productSales.last) const Divider(),
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

  Widget _buildProfitReport() {
    if (_profitData == null) {
      return const EmptyStateWidget(
        title: 'Tidak Ada Data',
        message: 'Tidak ada data laba untuk periode ini',
        icon: Icons.trending_up,
      );
    }

    final eggData = _profitData!['egg'] as Map<String, dynamic>? ?? {};
    final riceData = _profitData!['rice'] as Map<String, dynamic>? ?? {};
    final totalProfit = _profitData!['grand_total_profit'] ?? 0;
    final totalSales = _profitData!['grand_total_sales'] ?? 0;

    final eggDetails = eggData['details'] as List? ?? [];
    final riceDetails = riceData['details'] as List? ?? [];

    final pieData = {
      'Telur': eggData['total_profit']?.toDouble() ?? 0,
      'Beras': riceData['total_profit']?.toDouble() ?? 0,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.attach_money, size: 32, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(totalSales),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text('Total Penjualan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.trending_up, size: 32, color: AppColors.success),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(totalProfit),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                      const Text('Total Laba', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pie Chart
          PieChartWidget(data: pieData, title: 'Komposisi Laba'),
          const SizedBox(height: 24),

          // Egg Profit Detail
          const Text(
            'Laba Produk Telur',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                _buildProfitHeader(),
                ...eggDetails.map((detail) => _buildProfitRow(detail)),
                const Divider(),
                _buildProfitTotalRow(
                  'Total Telur',
                  eggData['total_sales']?.toDouble() ?? 0,
                  eggData['total_profit']?.toDouble() ?? 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rice Profit Detail
          const Text(
            'Laba Produk Beras',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                _buildProfitHeader(),
                ...riceDetails.map((detail) => _buildProfitRow(detail)),
                const Divider(),
                _buildProfitTotalRow(
                  'Total Beras',
                  riceData['total_sales']?.toDouble() ?? 0,
                  riceData['total_profit']?.toDouble() ?? 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProductReport() {
    if (_eggProfitData == null && _riceProfitData == null) {
      return const EmptyStateWidget(
        title: 'Tidak Ada Data',
        message: 'Tidak ada data produk untuk periode ini',
        icon: Icons.inventory,
      );
    }

    final eggDetails = (_eggProfitData?['details'] as List?) ?? [];
    final riceDetails = (_riceProfitData?['details'] as List?) ?? [];
    final allProducts = [...eggDetails, ...riceDetails];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Detail per Produk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                _buildProductDetailHeader(),
                ...allProducts.map((product) => _buildProductDetailRow(product)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProductSalesRow(String name, int quantity, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${Formatters.formatNumber(quantity)} kg', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            Formatters.formatCurrency(total),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          Expanded(child: Text('Produk', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 80, child: Text('Penjualan', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 80, child: Text('Laba', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 60, child: Text('Margin', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildProfitRow(Map<String, dynamic> detail) {
    final product = detail['product'] ?? '';
    final sales = (detail['sales'] ?? 0).toDouble();
    final profit = (detail['profit'] ?? 0).toDouble();
    final margin = profit / sales * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(product, style: const TextStyle(fontSize: 13))),
          SizedBox(
            width: 80,
            child: Text(
              Formatters.formatCurrency(sales),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              Formatters.formatCurrency(profit),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${margin.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitTotalRow(String label, double sales, double profit) {
    final margin = profit / sales * 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
            width: 80,
            child: Text(
              Formatters.formatCurrency(sales),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              Formatters.formatCurrency(profit),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${margin.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          Expanded(child: Text('Produk', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 60, child: Text('Terjual', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 80, child: Text('Penjualan', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 80, child: Text('Laba', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildProductDetailRow(Map<String, dynamic> detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(detail['product_name'] ?? '', style: const TextStyle(fontSize: 13))),
          SizedBox(
            width: 60,
            child: Text(
              '${detail['quantity_sold'] ?? 0} kg',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              Formatters.formatCurrency((detail['total_sales'] ?? 0).toDouble()),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              Formatters.formatCurrency((detail['total_profit'] ?? 0).toDouble()),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}