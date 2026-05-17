import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/success_snackbar.dart';
import '../../shared/widgets/confirmation_dialog.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      SuccessSnackbar.showError(context, 'Nama wajib diisi');
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile(
      _nameController.text,
      _phoneController.text.isNotEmpty ? _phoneController.text : null,
    );
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _isEditing = false);
      SuccessSnackbar.show(context, 'Profil berhasil diperbarui');
    } else {
      SuccessSnackbar.showError(context, authProvider.error ?? 'Gagal memperbarui profil');
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      SuccessSnackbar.showError(context, 'Password saat ini wajib diisi');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      SuccessSnackbar.showError(context, 'Password baru minimal 6 karakter');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      SuccessSnackbar.showError(context, 'Konfirmasi password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      setState(() {
        _isChangingPassword = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
      SuccessSnackbar.show(context, 'Password berhasil diubah');
    } else {
      SuccessSnackbar.showError(context, authProvider.error ?? 'Gagal mengubah password');
    }
  }

  Future<void> _logout() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Logout',
      message: 'Apakah Anda yakin ingin logout?',
      confirmText: 'Logout',
    );
    if (confirmed == true) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing && !_isChangingPassword)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
          if (_isChangingPassword)
            TextButton(
              onPressed: () => setState(() => _isChangingPassword = false),
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.roleLabel ?? 'OWNER',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Profil',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (_isEditing) ...[
                          CustomTextField(
                            controller: _nameController,
                            label: 'Nama',
                            hint: 'Masukkan nama lengkap',
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Nomor Telepon',
                            hint: 'Contoh: 081234567890',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Simpan Perubahan',
                            onPressed: _updateProfile,
                            isLoading: _isLoading,
                          ),
                        ] else ...[
                          _buildInfoRow('Nama', user?.name ?? '-'),
                          const Divider(),
                          _buildInfoRow('Email', user?.email ?? '-'),
                          const Divider(),
                          _buildInfoRow('Nomor Telepon', user?.phone ?? '-'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Change
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Keamanan',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (!_isChangingPassword)
                              TextButton(
                                onPressed: () => setState(() => _isChangingPassword = true),
                                child: const Text('Ubah Password'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isChangingPassword) ...[
                          CustomTextField(
                            controller: _currentPasswordController,
                            label: 'Password Saat Ini',
                            hint: 'Masukkan password lama',
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _newPasswordController,
                            label: 'Password Baru',
                            hint: 'Minimal 6 karakter',
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Konfirmasi Password Baru',
                            hint: 'Ketik ulang password baru',
                            obscureText: true,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Simpan Password',
                            onPressed: _changePassword,
                            isLoading: _isLoading,
                          ),
                        ] else ...[
                          _buildInfoRow('Password', '••••••••'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Logout Button
                CustomButton(
                  text: 'Logout',
                  onPressed: _logout,
                  isOutlined: true,
                  isDanger: true,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isLoading) const LoadingWidget(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}