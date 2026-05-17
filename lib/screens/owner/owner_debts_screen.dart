import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../models/debt_model.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/utils/formatters.dart';

class OwnerDebtsScreen extends StatefulWidget {
  const OwnerDebtsScreen({super.key});

  @override
  State<OwnerDebtsScreen> createState() => _OwnerDebtsScreenState();
}

class _OwnerDebtsScreenState extends State<OwnerDebtsScreen> {
  String _selectedStatus = 'pending';
  int? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    _loadData();
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
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
                // Supplier Filter
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
              if (debt.supplierPhone != null)
                TextButton.icon(
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Hubungi'),
                  onPressed: () {
                    // Launch phone dialer
                  },
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
}