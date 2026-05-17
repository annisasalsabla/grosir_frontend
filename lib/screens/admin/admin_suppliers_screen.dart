import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/supplier_provider.dart';
import '../../models/supplier_model.dart';
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

class AdminSuppliersScreen extends StatefulWidget {
  const AdminSuppliersScreen({super.key});

  @override
  State<AdminSuppliersScreen> createState() => _AdminSuppliersScreenState();
}

class _AdminSuppliersScreenState extends State<AdminSuppliersScreen> {
  String _selectedType = 'all';
  bool _showForm = false;
  bool _isEditing = false;
  int? _editingId;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedProductType = 'egg';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    final provider = Provider.of<SupplierProvider>(context, listen: false);
    await provider.fetchSuppliers(
      productType: _selectedType == 'all' ? null : _selectedType,
      refresh: true,
    );
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _selectedProductType = 'egg';
    _isEditing = false;
    _editingId = null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = Provider.of<SupplierProvider>(context, listen: false);
    bool success;

    if (_isEditing && _editingId != null) {
      final request = SupplierUpdateRequest(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        productType: _selectedProductType,
      );
      success = await provider.updateSupplier(_editingId!, request);
    } else {
      final request = SupplierRequest(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        productType: _selectedProductType,
      );
      success = await provider.createSupplier(request);
    }

    setState(() => _isSubmitting = false);

    if (success) {
      setState(() {
        _showForm = false;
        _resetForm();
      });
      SuccessSnackbar.show(context, _isEditing ? 'Supplier berhasil diupdate' : 'Supplier berhasil ditambahkan');
      _loadSuppliers();
    } else {
      SuccessSnackbar.showError(context, provider.error ?? 'Gagal menyimpan supplier');
    }
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Hapus Supplier',
      message: 'Apakah Anda yakin ingin menghapus supplier "${supplier.name}"?',
      confirmText: 'Hapus',
    );

    if (confirmed == true) {
      final provider = Provider.of<SupplierProvider>(context, listen: false);
      final success = await provider.deleteSupplier(supplier.id);
      if (success) {
        SuccessSnackbar.show(context, 'Supplier berhasil dihapus');
        _loadSuppliers();
      } else {
        SuccessSnackbar.showError(context, provider.error ?? 'Gagal menghapus supplier');
      }
    }
  }

  void _editSupplier(Supplier supplier) {
    _nameController.text = supplier.name;
    _phoneController.text = supplier.phone ?? '';
    _emailController.text = supplier.email ?? '';
    _addressController.text = supplier.address ?? '';
    _selectedProductType = supplier.productType;
    _isEditing = true;
    _editingId = supplier.id;
    setState(() => _showForm = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Supplier'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _resetForm();
              setState(() => _showForm = true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSuppliers,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('Semua')),
                    ButtonSegment(value: 'egg', label: Text('Telur')),
                    ButtonSegment(value: 'rice', label: Text('Beras')),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() => _selectedType = selection.first);
                    _loadSuppliers();
                  },
                ),
              ),

              // Suppliers List
              Expanded(
                child: Consumer<SupplierProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.suppliers.isEmpty) {
                      return const LoadingWidget(fullScreen: false);
                    }

                    if (provider.suppliers.isEmpty) {
                      return EmptyStateWidget(
                        title: 'Belum Ada Supplier',
                        message: 'Klik tombol + untuk menambahkan supplier baru',
                        icon: Icons.local_shipping_outlined,
                        onAction: () {
                          _resetForm();
                          setState(() => _showForm = true);
                        },
                        actionText: 'Tambah Supplier',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = provider.suppliers[index];
                        return _buildSupplierCard(supplier);
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

  Widget _buildSupplierCard(Supplier supplier) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: supplier.productType == 'egg'
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  supplier.productType == 'egg' ? Icons.egg : Icons.grass,
                  size: 30,
                  color: supplier.productType == 'egg' ? AppColors.warning : AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      supplier.productTypeLabel,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (!supplier.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(height: 12),
          if (supplier.phone != null && supplier.phone!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(supplier.formattedPhone),
                ],
              ),
            ),
          if (supplier.email != null && supplier.email!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(supplier.email!),
                ],
              ),
            ),
          if (supplier.address != null && supplier.address!.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(child: Text(supplier.address!)),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                onPressed: () => _editSupplier(supplier),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                label: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                onPressed: () => _deleteSupplier(supplier),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
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
                      Text(
                        _isEditing ? 'Edit Supplier' : 'Tambah Supplier',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        CustomTextField(
                          controller: _nameController,
                          label: 'Nama Supplier *',
                          hint: 'Masukkan nama supplier',
                          prefixIcon: const Icon(Icons.business),
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Nomor Telepon *',
                          hint: 'Contoh: 081234567890',
                          prefixIcon: const Icon(Icons.phone),
                          keyboardType: TextInputType.phone,
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Masukkan email supplier',
                          prefixIcon: const Icon(Icons.email),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _addressController,
                          label: 'Alamat',
                          hint: 'Masukkan alamat supplier',
                          prefixIcon: const Icon(Icons.location_on),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 24),
                        CustomButton(
                          text: _isEditing ? 'Update Supplier' : 'Simpan Supplier',
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