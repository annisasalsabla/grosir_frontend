import 'package:flutter/material.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/utils/constants.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/utils/formatters.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/custom_button.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/custom_card.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/empty_state_widget.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/success_snackbar.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_provider.dart';
import '../../models/product_model.dart';
import '../../models/damaged_good_model.dart';
import '../../theme/app_colors.dart';


class CashierDamagedGoodsScreen extends StatefulWidget {
  const CashierDamagedGoodsScreen({super.key});

  @override
  State<CashierDamagedGoodsScreen> createState() => _CashierDamagedGoodsScreenState();
}

class _CashierDamagedGoodsScreenState extends State<CashierDamagedGoodsScreen> {
  bool _showForm = false;
  int? _selectedProductId;
  final TextEditingController _quantityController = TextEditingController();
  String _selectedDamageType = 'cracked';
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  List<DamagedGood> _damagedGoods = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchProducts(isActive: true, refresh: true);

    // TODO: Load damaged goods from API
  }

  Future<void> _submitDamagedGood() async {
    if (_selectedProductId == null) {
      SuccessSnackbar.showError(context, 'Pilih produk terlebih dahulu');
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      SuccessSnackbar.showError(context, 'Masukkan jumlah yang valid');
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Call API to create damaged good

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSubmitting = false;
      _showForm = false;
      _selectedProductId = null;
      _quantityController.clear();
      _selectedDamageType = 'cracked';
      _descriptionController.clear();
    });

    SuccessSnackbar.show(context, 'Barang rusak berhasil dicatat');
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Rusak'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _showForm = true),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // List of damaged goods
              Expanded(
                child: _damagedGoods.isEmpty
                    ? EmptyStateWidget(
                  title: 'Belum Ada Catatan Barang Rusak',
                  message: 'Klik tombol + untuk mencatat barang rusak',
                  icon: Icons.warning_amber,
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _damagedGoods.length,
                  itemBuilder: (context, index) {
                    final item = _damagedGoods[index];
                    return _buildDamagedGoodCard(item);
                  },
                ),
              ),
            ],
          ),
          if (_showForm) _buildForm(productProvider.products),
        ],
      ),
    );
  }

  Widget _buildDamagedGoodCard(DamagedGood item) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.damageTypeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDamageIcon(item.damageType),
              color: item.damageTypeColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Produk',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} kg - ${item.damageTypeLabel}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  'Dicatat: ${Formatters.formatDate(item.recordedDate)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.reportedStatusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.reportedStatusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: item.reportedStatusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(List<Product> products) {
    final availableProducts = products.where((p) => p.stock > 0).toList();
    final selectedProduct = _selectedProductId != null
        ? products.firstWhere((p) => p.id == _selectedProductId, orElse: () => products.first)
        : null;

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Catat Barang Rusak',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _showForm = false),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Selector
                      const Text('Pilih Produk', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedProductId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: availableProducts.map((product) {
                          return DropdownMenuItem(
                            value: product.id,
                            child: Text('${product.fullName} (Stok: ${product.stock} ${product.unit})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedProductId = value);
                        },
                        hint: const Text('Pilih produk'),
                      ),
                      const SizedBox(height: 16),

                      // Quantity
                      TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah (kg)',
                          hintText: 'Masukkan jumlah barang rusak',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.scale),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Damage Type
                      const Text('Jenis Kerusakan', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: AppConstants.damageTypes.map((type) {
                          final isSelected = _selectedDamageType == type;
                          return FilterChip(
                            label: Text(AppConstants.damageTypeLabels[type]!),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedDamageType = type);
                              }
                            },
                            backgroundColor: Colors.grey.withOpacity(0.1),
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi (Opsional)',
                          hintText: 'Keterangan tambahan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Batal',
                              onPressed: () => setState(() => _showForm = false),
                              isOutlined: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Simpan',
                              onPressed: _submitDamagedGood,
                              isLoading: _isSubmitting,
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
        ),
      ),
    );
  }

  IconData _getDamageIcon(String damageType) {
    switch (damageType) {
      case 'cracked':
        return Icons.broken_image;
      case 'rotten':
        return Icons.warning_amber;
      case 'broken':
        return Icons.cancel;
      case 'expired':
        return Icons.hourglass_empty;
      case 'wet':
        return Icons.water_drop;
      default:
        return Icons.warning;
    }
  }
}