import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_provider.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/utils/formatters.dart';

class OwnerStockScreen extends StatefulWidget {
  const OwnerStockScreen({super.key});

  @override
  State<OwnerStockScreen> createState() => _OwnerStockScreenState();
}

class _OwnerStockScreenState extends State<OwnerStockScreen> {
  String _selectedType = 'all';
  String _searchQuery = '';
  bool _showOnlyLowStock = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchProducts(refresh: true);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    await stockProvider.fetchStockSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemantauan Stok'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Consumer<StockProvider>(
            builder: (context, provider, child) {
              final summary = provider.stockSummary;
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomCard(
                        child: Column(
                          children: [
                            const Icon(Icons.inventory, size: 28, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text(
                              '${summary?['total_products'] ?? 0}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('Total Produk', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomCard(
                        child: Column(
                          children: [
                            const Icon(Icons.attach_money, size: 28, color: AppColors.success),
                            const SizedBox(height: 8),
                            Text(
                              Formatters.formatCurrency(summary?['total_stock_value']?.toDouble() ?? 0),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const Text('Nilai Stok', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomCard(
                        child: Column(
                          children: [
                            const Icon(Icons.warning_amber, size: 28, color: Colors.orange),
                            const SizedBox(height: 8),
                            Text(
                              '${summary?['low_stock_count'] ?? 0}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                            const Text('Stok Menipis', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'all', label: Text('Semua')),
                          ButtonSegment(value: 'egg', label: Text('Telur')),
                          ButtonSegment(value: 'rice', label: Text('Beras')),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() => _selectedType = selection.first);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('Stok Menipis'),
                      selected: _showOnlyLowStock,
                      onSelected: (value) {
                        setState(() => _showOnlyLowStock = value);
                      },
                      backgroundColor: Colors.transparent,
                      selectedColor: AppColors.primary.withOpacity(0.1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Products List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.products.isEmpty) {
                  return const LoadingWidget(fullScreen: false);
                }

                var products = provider.products;
                if (_selectedType != 'all') {
                  products = products.where((p) => p.productType == _selectedType).toList();
                }
                if (_showOnlyLowStock) {
                  products = products.where((p) => p.isLowStock).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  products = products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                }

                if (products.isEmpty) {
                  return EmptyStateWidget(
                    title: 'Tidak Ada Produk',
                    message: _showOnlyLowStock
                        ? 'Tidak ada produk dengan stok menipis'
                        : 'Tidak ada produk yang ditemukan',
                    icon: Icons.inventory,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final stockPercentage = (product.stock / product.minStock).clamp(0.0, 1.0);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.fullName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      product.productType == 'egg' ? 'Telur' : 'Beras',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  product.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: product.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stok Saat Ini', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(
                      '${Formatters.formatNumber(product.stock)} ${product.unit}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stok Minimum', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(
                      '${Formatters.formatNumber(product.minStock)} ${product.unit}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Harga Jual', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(
                      product.formattedSellingPrice,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stockPercentage,
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: stockPercentage > 0.5 ? Colors.green : (stockPercentage > 0.2 ? Colors.orange : Colors.red),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Persentase Stok',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                '${(stockPercentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: stockPercentage > 0.5 ? Colors.green : Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}