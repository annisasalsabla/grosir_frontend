import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/debt_model.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/success_snackbar.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/utils/validators.dart';

class AdminDebtsScreen extends StatefulWidget {
  const AdminDebtsScreen({super.key});

  @override
  State<AdminDebtsScreen> createState() => _AdminDebtsScreenState();
}

class _AdminDebtsScreenState extends State<AdminDebtsScreen> {
  String _selectedStatus = 'pending';
  int? _selectedSupplierId;
  bool _showForm = false;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
  int? _selectedProductId;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final debtProvider = Provider.of<DebtProvider>(context, listen: false);
    await debtProvider.fetchDebts(
      status: _selectedStatus,
      supplierId: _selectedSupplierId,
      refresh: true,
    );
    await debtProvider.fetchReport();

    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    await supplierProvider.fetchSuppliers();

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchProducts(refresh: true);
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
      setState(() {
        _showForm = false;
        _resetForm();
      });
      SuccessSnackbar.show(context, 'Hutang berhasil dicatat');
      _loadData();
    } else {
      SuccessSnackbar.showError(context, provider.error ?? 'Gagal mencatat hutang');
    }
  }

  void _resetForm() {
    _selectedSupplierId = null;
    _selectedProductId = null;
    _quantityController.clear();
    _priceController.clear();
    _selectedDueDate = DateTime.now().add(const Duration(days: 30));
    _notesController.clear();
  }

  Future<void> _payDebt(Debt debt) async {
    final amountController = TextEditingController();
    String paymentMethod = 'transfer';
    bool isPaying = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Pembayaran Hutang'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Supplier: ${debt.supplierName}'),
                const SizedBox(height: 8),
                Text('Sisa Hutang: ${debt.formattedRemainingAmount}'),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Pembayaran',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                const Text('Metode Pembayaran'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentMethodOption(
                          'cash', 'Tunai', Icons.money, paymentMethod, setStateDialog
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPaymentMethodOption(
                          'transfer', 'Transfer', Icons.credit_card, paymentMethod, setStateDialog
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    SuccessSnackbar.showError(context, 'Masukkan jumlah yang valid');
                    return;
                  }
                  if (amount > debt.remainingAmount) {
                    SuccessSnackbar.showError(context, 'Jumlah melebihi sisa hutang');
                    return;
                  }
                  Navigator.pop(context);
                  setStateDialog(() => isPaying = true);
                  final provider = Provider.of<DebtProvider>(context, listen: false);
                  final success = await provider.payDebt(debt.id, amount, paymentMethod);
                  if (success) {
                    SuccessSnackbar.show(context, 'Pembayaran hutang berhasil');
                    _loadData();
                  } else {
                    SuccessSnackbar.showError(context, provider.error ?? 'Gagal membayar hutang');
                  }
                },
                child: const Text('Bayar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String label, IconData icon, String selected, Function setStateDialog) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => setStateDialog(() => selected = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: isSelected ? AppColors.primary : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hutang Supplier'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _showForm = true),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Summary Cards
              Consumer<DebtProvider>(
                builder: (context, provider, child) {
                  final report = provider.report;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomCard(
                            child: Column(
                              children: [
                                const Icon(Icons.credit_card, size: 28, color: AppColors.warning),
                                const SizedBox(height: 8),
                                Text(
                                  Formatters.formatCurrency(report?['summary']?['total_debt']?.toDouble() ?? 0),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.warning),
                                ),
                                const Text('Total Hutang', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomCard(
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle, size: 28, color: AppColors.success),
                                const SizedBox(height: 8),
                                Text(
                                  Formatters.formatCurrency(report?['summary']?['total_paid']?.toDouble() ?? 0),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const Text('Telah Dibayar', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                                  '${report?['summary']?['total_overdue'] ?? 0}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                                const Text('Overdue', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                    Consumer<SupplierProvider>(
                      builder: (context, provider, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: _selectedSupplierId,
                              isExpanded: true,
                              hint: const Text('Semua Supplier'),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Semua Supplier')),
                                ...provider.suppliers.map((supplier) {
                                  return DropdownMenuItem(
                                    value: supplier.id,
                                    child: Text(supplier.name),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedSupplierId = value);
                                _loadData();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'pending', label: Text('Belum Lunas')),
                        ButtonSegment(value: 'partial', label: Text('Sebagian')),
                        ButtonSegment(value: 'paid', label: Text('Lunas')),
                        ButtonSegment(value: 'overdue', label: Text('Overdue')),
                      ],
                      selected: {_selectedStatus},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() => _selectedStatus = selection.first);
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Debts List
              Expanded(
                child: Consumer<DebtProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.debts.isEmpty) {
                      return const LoadingWidget(fullScreen: false);
                    }

                    if (provider.debts.isEmpty) {
                      return EmptyStateWidget(
                        title: 'Tidak Ada Hutang',
                        message: _selectedStatus == 'pending'
                            ? 'Belum ada hutang yang tercatat'
                            : _selectedStatus == 'paid'
                            ? 'Belum ada hutang yang lunas'
                            : 'Tidak ada hutang yang jatuh tempo',
                        icon: Icons.credit_card_outlined,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.debts.length,
                      itemBuilder: (context, index) {
                        final debt = provider.debts[index];
                        return _buildDebtCard(debt);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_showForm) _buildForm(),
        ],
      ),
    );
  }

  Widget _buildDebtCard(Debt debt) {
    final isOverdue = debt.isOverdue;

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
                      debt.supplierName ?? 'Supplier',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      debt.debtNumber,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? AppColors.error.withOpacity(0.1)
                      : debt.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOverdue ? 'Overdue' : debt.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? AppColors.error : debt.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn('Produk', debt.productName ?? '-'),
              ),
              Expanded(
                child: _buildInfoColumn('Jumlah', '${debt.quantity} kg'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn('Total Hutang', debt.formattedTotalAmount),
              ),
              Expanded(
                child: _buildInfoColumn('Telah Dibayar', debt.formattedPaidAmount),
              ),
              Expanded(
                child: _buildInfoColumn('Sisa', debt.formattedRemainingAmount),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn(
                  'Jatuh Tempo',
                  Formatters.formatDate(debt.dueDate),
                  isOverdue: isOverdue,
                ),
              ),
              if (debt.remainingAmount > 0)
                CustomButton(
                  text: 'Bayar',
                  onPressed: () => _payDebt(debt),
                  height: 36,
                  width: 80,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isOverdue = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isOverdue ? AppColors.error : null,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final supplierProvider = Provider.of<SupplierProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final availableProducts = _selectedSupplierId != null
        ? productProvider.products.where((p) => p.supplierId == _selectedSupplierId).toList()
        : [];

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
                        'Tambah Hutang',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showForm = false;
                            _resetForm();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Supplier
                        DropdownButtonFormField<int>(
                          value: _selectedSupplierId,
                          decoration: const InputDecoration(
                            labelText: 'Supplier *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_shipping),
                          ),
                          items: supplierProvider.suppliers.map((supplier) {
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
                        ),
                        const SizedBox(height: 16),

                        // Product
                        DropdownButtonFormField<int>(
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
                            setState(() => _selectedProductId = value);
                            if (value != null) {
                              final product = productProvider.products.firstWhere((p) => p.id == value);
                              _priceController.text = product.purchasePrice.toString();
                            }
                          },
                          validator: (value) => value == null ? 'Pilih produk' : null,
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
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Simpan Hutang',
                          onPressed: _submitForm,
                          isLoading: _isSubmitting,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}