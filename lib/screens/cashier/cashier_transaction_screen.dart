import 'package:flutter/material.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/utils/formatters.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/loading_widget.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/success_snackbar.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import 'cashier_cart_screen.dart';

class CashierTransactionScreen extends StatefulWidget {
  const CashierTransactionScreen({super.key});

  @override
  State<CashierTransactionScreen> createState() => _CashierTransactionScreenState();
}

class _CashierTransactionScreenState extends State<CashierTransactionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.fetchProducts(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      isActive: true,
      refresh: true,
    );
    setState(() => _isLoading = false);
  }

  void _addToCart(Product product) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    transactionProvider.addToCart(CartItem(
      productId: product.id,
      productName: product.fullName,
      price: product.sellingPrice,
      quantity: 1,
      stock: product.stock,
    ));
    SuccessSnackbar.show(context, '${product.fullName} ditambahkan ke keranjang');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Penjualan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CashierCartScreen()),
                  ).then((_) => _loadProducts());
                },
              ),
              Consumer<TransactionProvider>(
                builder: (context, provider, _) {
                  if (provider.cart.isEmpty) return const SizedBox();
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${provider.cart.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _loadProducts();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadProducts();
              },
            ),
          ),
          // Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'all', label: Text('Semua')),
                      ButtonSegment(value: 'egg', label: Text('Telur')),
                      ButtonSegment(value: 'rice', label: Text('Beras')),
                    ],
                    selected: {_selectedCategory},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() => _selectedCategory = selection.first);
                      _loadProducts();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Products Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (_isLoading && provider.products.isEmpty) {
                  return const LoadingWidget(fullScreen: false);
                }

                final products = _selectedCategory == 'all'
                    ? provider.products
                    : provider.products.where((p) => p.productType == _selectedCategory).toList();

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
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
    return GestureDetector(
      onTap: () => _addToCart(product),
      child: Container(
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  product.productType == 'egg' ? Icons.egg : Icons.grass,
                  size: 50,
                  color: AppColors.primary,
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
                    'Stok: ${Formatters.formatNumber(product.stock)} ${product.unit}',
                    style: TextStyle(
                      fontSize: 11,
                      color: product.isLowStock ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedSellingPrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}