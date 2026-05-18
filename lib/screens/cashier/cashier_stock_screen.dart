import 'package:flutter/material.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/utils/formatters.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/empty_state_widget.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';


class CashierStockScreen extends StatefulWidget {
  const CashierStockScreen({super.key});

  @override
  State<CashierStockScreen> createState() => _CashierStockScreenState();
}

class _CashierStockScreenState extends State<CashierStockScreen> {
  String _selectedType = 'all';
  String _searchQuery = '';
  bool _showOnlyLowStock = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.fetchProducts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Stok'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
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
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _loadProducts();
                      },
                    )
                        : null,
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
          const SizedBox(height: 8),

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

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Icon
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: product.productType == 'egg'
                  ? AppColors.warning.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                product.productType == 'egg' ? Icons.egg : Icons.grass,
                size: 50,
                color: product.productType == 'egg' ? AppColors.warning : AppColors.success,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.productType == 'egg' ? 'Telur' : 'Beras',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Stok', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        Text(
                          '${Formatters.formatNumber(product.stock)} ${product.unit}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Harga', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        Text(
                          product.formattedSellingPrice,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stockPercentage,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    color: stockPercentage > 0.5 ? Colors.green : (stockPercentage > 0.2 ? Colors.orange : Colors.red),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: ${product.statusLabel}',
                      style: TextStyle(
                        fontSize: 10,
                        color: product.statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Min: ${product.minStock} ${product.unit}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}