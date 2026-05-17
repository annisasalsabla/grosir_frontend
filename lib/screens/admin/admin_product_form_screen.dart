import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/success_snackbar.dart';
import '../../shared/utils/validators.dart';
import '../../shared/utils/constants.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;
  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedProductType = 'egg';
  String? _selectedEggSize;
  String? _selectedRiceVariant;
  int? _selectedSupplierId;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.product != null) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);

    await productProvider.fetchCategories();
    await supplierProvider.fetchSuppliers();

    if (widget.product == null && supplierProvider.suppliers.isNotEmpty) {
      setState(() {
        _selectedSupplierId = supplierProvider.suppliers.first.id;
      });
    }
  }

  void _populateForm() {
    final product = widget.product!;
    _nameController.text = product.name;
    _purchasePriceController.text = product.purchasePrice.toString();
    _sellingPriceController.text = product.sellingPrice.toString();
    _stockController.text = product.stock.toString();
    _minStockController.text = product.minStock.toString();
    _selectedProductType = product.productType;
    _selectedEggSize = product.eggSize;
    _selectedRiceVariant = product.riceVariant;
    _selectedSupplierId = product.supplierId;
    _isActive = product.isActive;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductType == 'egg' && _selectedEggSize == null) {
      SuccessSnackbar.showError(context, 'Pilih ukuran telur');
      return;
    }

    if (_selectedProductType == 'rice' && _selectedRiceVariant == null) {
      SuccessSnackbar.showError(context, 'Pilih varian beras');
      return;
    }

    if (_selectedSupplierId == null) {
      SuccessSnackbar.showError(context, 'Pilih supplier');
      return;
    }

    setState(() => _isLoading = true);

    final request = ProductCreateRequest(
      name: _nameController.text,
      categoryId: _selectedProductType == 'egg' ? 1 : 2,
      productType: _selectedProductType,
      eggSize: _selectedEggSize,
      riceVariant: _selectedRiceVariant,
      purchasePrice: double.parse(_purchasePriceController.text),
      sellingPrice: double.parse(_sellingPriceController.text),
      stock: int.parse(_stockController.text),
      minStock: int.parse(_minStockController.text),
      unit: 'kg',
      supplierId: _selectedSupplierId!,
      isActive: _isActive,
    );

    final provider = Provider.of<ProductProvider>(context, listen: false);
    bool success;

    if (widget.product != null) {
      success = await provider.updateProduct(widget.product!.id, request.toJson());
    } else {
      success = await provider.createProduct(request);
    }

    setState(() => _isLoading = false);

    if (success) {
      SuccessSnackbar.show(context, widget.product != null ? 'Produk berhasil diupdate' : 'Produk berhasil ditambahkan');
      Navigator.pop(context, true);
    } else {
      SuccessSnackbar.showError(context, provider.error ?? 'Gagal menyimpan produk');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Produk' : 'Tambah Produk'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.production_quantity_limits),
                    ),
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 16),

                  // Product Type
                  const Text('Jenis Produk *', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'egg', label: Text('Telur')),
                      ButtonSegment(value: 'rice', label: Text('Beras')),
                    ],
                    selected: {_selectedProductType},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() => _selectedProductType = selection.first);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Egg Size or Rice Variant
                  if (_selectedProductType == 'egg') ...[
                    const Text('Ukuran Telur *', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.eggSizes.map((size) {
                        final isSelected = _selectedEggSize == size;
                        return FilterChip(
                          label: Text(size.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedEggSize = selected ? size : null);
                          },
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    const Text('Varian Beras *', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.riceVariants.map((variant) {
                        final isSelected = _selectedRiceVariant == variant;
                        return FilterChip(
                          label: Text(variant.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedRiceVariant = selected ? variant : null);
                          },
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Prices
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _purchasePriceController,
                          decoration: const InputDecoration(
                            labelText: 'Harga Beli (Rp) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shopping_cart),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.numeric(value, min: 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _sellingPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Harga Jual (Rp) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.numeric(value, min: 0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stock
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stok Awal (kg) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.number(value, min: 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _minStockController,
                          decoration: const InputDecoration(
                            labelText: 'Stok Minimum (kg) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.warning_amber),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.number(value, min: 0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Supplier
                  Consumer<SupplierProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return DropdownButtonFormField<int>(
                        value: _selectedSupplierId,
                        decoration: const InputDecoration(
                          labelText: 'Supplier *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_shipping),
                        ),
                        items: provider.suppliers
                            .where((s) => s.productType == _selectedProductType)
                            .map((supplier) {
                          return DropdownMenuItem(
                            value: supplier.id,
                            child: Text(supplier.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSupplierId = value);
                        },
                        validator: (value) => value == null ? 'Pilih supplier' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Active Status
                  SwitchListTile(
                    title: const Text('Produk Aktif'),
                    subtitle: const Text('Nonaktifkan jika produk tidak dijual sementara'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() => _isActive = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: widget.product != null ? 'Update Produk' : 'Simpan Produk',
                    onPressed: _submitForm,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isLoading) const LoadingWidget(),
        ],
      ),
    );
  }
}