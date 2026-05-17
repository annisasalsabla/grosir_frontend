import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/debt_model.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/success_snackbar.dart';
import '../../shared/utils/validators.dart';
import '../../shared/utils/formatters.dart';

class AdminDebtFormScreen extends StatefulWidget {
  final Debt? debt;
  const AdminDebtFormScreen({super.key, this.debt});

  @override
  State<AdminDebtFormScreen> createState() => _AdminDebtFormScreenState();
}

class _AdminDebtFormScreenState extends State<AdminDebtFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedSupplierId;
  int? _selectedProductId;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));

  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.debt != null) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    await supplierProvider.fetchSuppliers();

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchProducts(refresh: true);

    setState(() => _isLoading = false);
  }

  void _populateForm() {
    final debt = widget.debt!;
    _selectedSupplierId = debt.supplierId;
    _selectedProductId = debt.productId;
    _quantityController.text = debt.quantity.toString();
    _priceController.text = debt.pricePerUnit.toString();
    _selectedDueDate = debt.dueDate;
    _notesController.text = debt.notes ?? '';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplierId == null) {
      SuccessSnackbar.showError(context, 'Pilih supplier terlebih dahulu');
      return;
    }
    if (_selectedProductId == null) {
      SuccessSnackbar.showError(context, 'Pilih produk terlebih dahulu');
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = Provider.of<DebtProvider>(context, listen: false);

    final request = DebtRequest(
      supplierId: _selectedSupplierId!,
      productId: _selectedProductId!,
      quantity: int.parse(_quantityController.text),
      pricePerUnit: double.parse(_priceController.text),
      dueDate: _selectedDueDate,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    final success = await provider.createDebt(request);
    setState(() => _isSubmitting = false);

    if (success) {
      SuccessSnackbar.show(context, 'Hutang berhasil dicatat');
      Navigator.pop(context, true);
    } else {
      SuccessSnackbar.showError(context, provider.error ?? 'Gagal mencatat hutang');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.debt != null ? 'Edit Hutang' : 'Tambah Hutang'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const LoadingWidget()
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Supplier
                    Consumer<SupplierProvider>(
                      builder: (context, provider, child) {
                        return DropdownButtonFormField<int>(
                          value: _selectedSupplierId,
                          decoration: const InputDecoration(
                            labelText: 'Supplier *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_shipping),
                          ),
                          items: provider.suppliers.map((supplier) {
                            return DropdownMenuItem(
                              value: supplier.id,
                              child: Text(supplier.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSupplierId = value;
                              _selectedProductId = null;
                              _priceController.clear();
                            });
                          },
                          validator: (value) => value == null ? 'Pilih supplier' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Product
                    Consumer<ProductProvider>(
                      builder: (context, provider, child) {
                        final availableProducts = _selectedSupplierId != null
                            ? provider.products.where((p) => p.supplierId == _selectedSupplierId).toList()
                            : [];

                        return DropdownButtonFormField<int>(
                          value: _selectedProductId,
                          decoration: const InputDecoration(
                            labelText: 'Produk *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          items: availableProducts.map((product) {
                            return DropdownMenuItem(
                              value: product.id,
                              child: Text('${product.fullName} - ${product.formattedPurchasePrice}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProductId = value;
                              if (value != null) {
                                final product = provider.products.firstWhere((p) => p.id == value);
                                _priceController.text = product.purchasePrice.toString();
                              }
                            });
                          },
                          validator: (value) => value == null ? 'Pilih produk' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quantity
                    CustomTextField(
                      controller: _quantityController,
                      label: 'Jumlah (kg) *',
                      hint: 'Masukkan jumlah',
                      prefixIcon: const Icon(Icons.scale),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.number(value, min: 1),
                    ),
                    const SizedBox(height: 16),

                    // Price
                    CustomTextField(
                      controller: _priceController,
                      label: 'Harga per kg *',
                      hint: 'Masukkan harga beli',
                      prefixIcon: const Icon(Icons.attach_money),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.numeric(value, min: 0),
                    ),
                    const SizedBox(height: 16),

                    // Total Amount (Read-only)
                    if (_quantityController.text.isNotEmpty && _priceController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Hutang:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              Formatters.formatCurrency(
                                  int.parse(_quantityController.text) * double.parse(_priceController.text)
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Due Date
                    ListTile(
                      title: const Text('Jatuh Tempo *'),
                      subtitle: Text(Formatters.formatDate(_selectedDueDate)),
                      leading: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _selectedDueDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    CustomTextField(
                      controller: _notesController,
                      label: 'Catatan',
                      hint: 'Catatan tambahan (opsional)',
                      prefixIcon: const Icon(Icons.description),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    CustomButton(
                      text: widget.debt != null ? 'Update Hutang' : 'Simpan Hutang',
                      onPressed: _submitForm,
                      isLoading: _isSubmitting,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          if (_isSubmitting) const LoadingWidget(),
        ],
      ),
    );
  }
}