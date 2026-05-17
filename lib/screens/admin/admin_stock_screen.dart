import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_provider.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/success_snackbar.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/utils/formatters.dart';

class AdminStockScreen extends StatefulWidget {
  const AdminStockScreen({super.key});

  @override
  State<AdminStockScreen> createState() => _AdminStockScreenState();
}

class _AdminStockScreenState extends State<AdminStockScreen> {
  String _selectedType = 'all';
  String _searchQuery = '';
  bool _showOnlyLowStock = false;
  Product? _selectedProduct;
  bool _showStockDialog = false;
  final TextEditingController _stockQuantityController = TextEditingController();
  String _stockType = 'add';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _stockQuantityController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchProducts(refresh: true);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    await stockProvider.fetchStockSummary();
  }

  Future<void> _updateStock() async {
    if (_selectedProduct == null) return;

    final quantity = int.tryParse(_stockQuantityController.text);
    if (quantity == null || quantity <= 0) {
      SuccessSnackbar.showError(context, 'Masukkan jumlah yang valid');
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.updateStock(
      _selectedProduct!.id,
      quantity,
      _stockType,
      description: _stockType == 'add' ? 'Penambahan stok manual' : 'Pengurangan stok manual',
    );
    setState(() => _isSubmitting = false);

    if (success) {
      setState(() {
        _showStockDialog = false;
        _selectedProduct = null;
        _stockQuantityController.clear();
      });
      SuccessSnackbar.show(context, 'Stok berhasil diperbarui');
      _loadData();
    } else {
      SuccessSnackbar.showError(context, provider.error ?? 'Gagal memperbarui stok');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Stok'),
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
                              const Text('Total Produk', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                              const Text('Nilai Stok', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                              const Text('Stok Menipis', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                          _loadData();
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
        if (_showStockDialog && _selectedProduct != null)
    _buildStockDialog(),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                text: 'Tambah Stok',
                onPressed: () {
                  setState(() {
                    _selectedProduct = product;
                    _stockType = 'add';
                    _showStockDialog = true;
                  });
                },
                height: 36,
                width: 120,
              ),
              const SizedBox(width: 8),
              if (product.stock > 0)
                CustomButton(
                  text: 'Kurangi Stok',
                  onPressed: () {
                    setState(() {
                      _selectedProduct = product;
                      _stockType = 'subtract';
                      _showStockDialog = true;
                    });
                  },
                  height: 36,
                  width: 120,
                  isOutlined: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockDialog() {
    final product = _selectedProduct!;
    final maxSubtract = _stockType == 'subtract' ? product.stock : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _stockType == 'add' ? 'Tambah Stok' : 'Kurangi Stok',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Produk: ${product.fullName}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Stok Saat Ini: ${product.stock} ${product.unit}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const Divider(),
            const SizedBox(height: 16),
            TextField(
              controller: _stockQuantityController,
              decoration: InputDecoration(
                labelText: 'Jumlah (kg)',
                hintText: maxSubtract != null ? 'Maksimal ${product.stock} kg' : null,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.scale),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Batal',
                    onPressed: () {
                      setState(() {
                        _showStockDialog = false;
                        _selectedProduct = null;
                        _stockQuantityController.clear();
                      });
                    },
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: _stockType == 'add' ? 'Tambah' : 'Kurangi',
                    onPressed: _updateStock,
                    isLoading: _isSubmitting,
                    backgroundColor: _stockType == 'add' ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}