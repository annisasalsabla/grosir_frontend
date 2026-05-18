import 'package:flutter/material.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/utils/validators.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/custom_button.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/custom_text_field.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/loading_widget.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/success_snackbar.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';


class AdminUserFormScreen extends StatefulWidget {
  final User? user;
  const AdminUserFormScreen({super.key, this.user});

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedRole = 'cashier';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final user = widget.user!;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
    _selectedRole = user.role;
    _isActive = user.isActive;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<UserProvider>(context, listen: false);
    bool success;

    final request = UserCreateRequest(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      role: _selectedRole,
      isActive: _isActive,
    );

    success = await provider.createUser(request);

    setState(() => _isLoading = false);

    if (success) {
      SuccessSnackbar.show(context, 'Kasir berhasil ditambahkan. Password akan dikirim ke email.');
      Navigator.pop(context, true);
    } else {
      SuccessSnackbar.showError(context, provider.error ?? 'Gagal menambahkan kasir');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user != null ? 'Edit Kasir' : 'Tambah Kasir'),
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
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nama Lengkap *',
                    hint: 'Masukkan nama lengkap',
                    prefixIcon: const Icon(Icons.person),
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email *',
                    hint: 'Masukkan email',
                    prefixIcon: const Icon(Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
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
                  const Text('Role *', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'cashier', label: Text('Kasir')),
                    ],
                    selected: {_selectedRole},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() => _selectedRole = selection.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Aktif'),
                    subtitle: const Text('Nonaktifkan jika kasir tidak boleh login'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() => _isActive = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: widget.user != null ? 'Update Kasir' : 'Tambah Kasir',
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