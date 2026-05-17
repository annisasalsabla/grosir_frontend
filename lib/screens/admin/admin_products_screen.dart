import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/success_snackbar.dart';
import '../../shared/utils/formatters.dart';
import 'admin_product_form_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _searchQuery = '';
  String _selectedType = 'all';
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.fetchProducts(
      productType: _selectedType == 'all' ? null : _selectedType,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      isActive: _showInactive ? null : true,
      refresh: true,
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Hapus Produk',
      message: 'Apakah Anda yakin ingin menghapus produk "${product.name}"?',
      confirmText: 'Hapus',
      confirmColor: AppColors.error,
    );

    if (confirmed == true) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final success = await provider.deleteProduct(product.id);
      if (success) {
        SuccessSnackbar.show(context, 'Produk berhasil dihapus');
        _loadProducts();
      } else {
        SuccessSnackbar.showError(context, provider.error ?? 'Gagal menghapus produk');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProductFormScreen()),
              );
              if (result == true) {
                _loadProducts();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
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
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _loadProducts();
                  },
                ),
                const SizedBox(height: 12),
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
                          setState(() {
                            _selectedType = selection.first;
                          });
                          _loadProducts();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('Nonaktif'),
                      selected: _showInactive,
                      onSelected: (value) {
                        setState(() {
                          _showInactive = value;
                        });
                        _loadProducts();
                      },
                      backgroundColor: Colors.transparent,
                      selectedColor: AppColors.primary.withOpacity(0.1),
                      checkmarkColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Products List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.products.isEmpty) {
                  return const LoadingWidget(fullScreen: false);
                }

                if (provider.products.isEmpty) {
                  return EmptyStateWidget(
                    title: 'Belum Ada Produk',
                    message: 'Klik tombol + untuk menambahkan produk baru',
                    icon: Icons.inventory,
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminProductFormScreen()),
                      ).then((result) {
                        if (result == true) _loadProducts();
                      });
                    },
                    actionText: 'Tambah Produk',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
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
                                    Row(
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (!product.isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Nonaktif',
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.productType == 'egg' ? 'Telur' : 'Beras',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
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
                                    const Text('Stok', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text(
                                      '${Formatters.formatNumber(product.stock)} ${product.unit}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Harga Beli', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text(
                                      product.formattedPurchasePrice,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  // Navigate to stock update
                                },
                                icon: const Icon(Icons.inventory, size: 18),
                                label: const Text('Stok'),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminProductFormScreen(product: product),
                                    ),
                                  );
                                  if (result == true) _loadProducts();
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                              ),
                              TextButton.icon(
                                onPressed: () => _deleteProduct(product),
                                icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                                label: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}