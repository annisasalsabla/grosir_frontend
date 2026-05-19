import 'package:flutter/material.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/utils/formatters.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/confirmation_dialog.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/custom_card.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/empty_state_widget.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/loading_widget.dart';
import 'package:grosir_tiga_bersaudara/screens/shared/widgets/success_snackbar.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';

import '../admin/admin_user_form_screen.dart';

class OwnerUsersScreen extends StatefulWidget {
  const OwnerUsersScreen({super.key});

  @override
  State<OwnerUsersScreen> createState() => _OwnerUsersScreenState();
}

class _OwnerUsersScreenState extends State<OwnerUsersScreen> {
  String _selectedRole = 'all';
  String _searchQuery = '';
  bool _showOnlyActive = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    await provider.fetchUsers(
      role: _selectedRole == 'all' ? null : _selectedRole,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      refresh: true,
    );
    await provider.fetchStats();
  }

  Future<void> _toggleUserStatus(User user) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    bool success;

    if (user.isActive) {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: 'Nonaktifkan User',
        message: 'Apakah Anda yakin ingin menonaktifkan user "${user.name}"?',
        confirmText: 'Nonaktifkan',
      );
      if (confirmed != true) return;
      success = await provider.deactivateUser(user.id);
    } else {
      success = await provider.activateUser(user.id);
    }

    if (success) {
      SuccessSnackbar.show(context, user.isActive ? 'User dinonaktifkan' : 'User diaktifkan');
      _loadUsers();
    } else {
      SuccessSnackbar.showError(context, provider.error ?? 'Gagal mengubah status user');
    }
  }

  Future<void> _resetPassword(User user) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Reset Password',
      message: 'Password baru akan dikirim ke email ${user.email}. Lanjutkan?',
      confirmText: 'Reset',
    );

    if (confirmed == true) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      final success = await provider.resetUserPassword(user.id);
      if (success) {
        SuccessSnackbar.show(context, 'Password baru telah dikirim ke email');
      } else {
        SuccessSnackbar.showError(context, provider.error ?? 'Gagal reset password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUserFormScreen()),
              );
              if (result == true) _loadUsers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats
          Consumer<UserProvider>(
            builder: (context, provider, child) {
              final stats = provider.stats;
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomCard(
                        child: Column(
                          children: [
                            const Icon(Icons.people, size: 28, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text(
                              '${stats?['total_users'] ?? 0}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('Total User', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomCard(
                        child: Column(
                          children: [
                            const Icon(Icons.admin_panel_settings, size: 28, color: AppColors.secondary),
                            const SizedBox(height: 8),
                            Text(
                              '${stats?['total_admins'] ?? 0}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('Administrator', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomCard(
                        child: Column(
                          children: [
                            const Icon(Icons.person, size: 28, color: AppColors.warning),
                            const SizedBox(height: 8),
                            Text(
                              '${stats?['total_cashiers'] ?? 0}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('Kasir', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                    hintText: 'Cari user...',
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
                        _loadUsers();
                      },
                    )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _loadUsers();
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'all', label: Text('Semua')),
                          ButtonSegment(value: 'administrator', label: Text('Admin')),
                          ButtonSegment(value: 'cashier', label: Text('Kasir')),
                        ],
                        selected: {_selectedRole},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() => _selectedRole = selection.first);
                          _loadUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('Aktif'),
                      selected: _showOnlyActive,
                      onSelected: (value) {
                        setState(() => _showOnlyActive = value);
                        _loadUsers();
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

          // Users List
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.users.isEmpty) {
                  return const LoadingWidget(fullScreen: false);
                }

                var users = provider.users;
                if (_showOnlyActive) {
                  users = users.where((u) => u.isActive).toList();
                }

                if (users.isEmpty) {
                  return EmptyStateWidget(
                    title: 'Tidak Ada User',
                    message: 'Klik tombol + untuk menambahkan user baru',
                    icon: Icons.people_outline,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
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
                  color: user.isAdministrator ? AppColors.secondary.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  user.isAdministrator ? Icons.admin_panel_settings : Icons.person,
                  size: 30,
                  color: user.isAdministrator ? AppColors.secondary : AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        if (!user.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isAdministrator ? AppColors.secondary.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.roleLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: user.isAdministrator ? AppColors.secondary : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn('Telepon', user.phone ?? '-'),
              ),
              Expanded(
                child: _buildInfoColumn('Terdaftar', Formatters.formatDate(user.createdAt)),
              ),
              if (user.lastLoginAt != null)
                Expanded(
                  child: _buildInfoColumn('Login Terakhir', Formatters.formatDate(user.lastLoginAt!)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: Icon(
                  user.isActive ? Icons.block : Icons.check_circle,
                  size: 18,
                  color: user.isActive ? AppColors.error : AppColors.success,
                ),
                label: Text(
                  user.isActive ? 'Nonaktifkan' : 'Aktifkan',
                  style: TextStyle(color: user.isActive ? AppColors.error : AppColors.success),
                ),
                onPressed: () => _toggleUserStatus(user),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.password, size: 18),
                label: const Text('Reset Password'),
                onPressed: () => _resetPassword(user),
              ),
              if (user.role != 'owner')
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                  label: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                  onPressed: () async {
                    final confirmed = await ConfirmationDialog.show(
                      context: context,
                      title: 'Hapus User',
                      message: 'Apakah Anda yakin ingin menghapus user "${user.name}"?',
                      confirmText: 'Hapus',
                    );
                    if (confirmed == true) {
                      final provider = Provider.of<UserProvider>(context, listen: false);
                      final success = await provider.deleteUser(user.id);
                      if (success) {
                        SuccessSnackbar.show(context, 'User berhasil dihapus');
                        _loadUsers();
                      } else {
                        SuccessSnackbar.showError(context, provider.error ?? 'Gagal menghapus user');
                      }
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}