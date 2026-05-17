import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/receivable_provider.dart';
import '../../models/receivable_model.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/utils/formatters.dart';

class OwnerReceivablesScreen extends StatefulWidget {
  const OwnerReceivablesScreen({super.key});

  @override
  State<OwnerReceivablesScreen> createState() => _OwnerReceivablesScreenState();
}

class _OwnerReceivablesScreenState extends State<OwnerReceivablesScreen> {
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ReceivableProvider>(context, listen: false);
    await provider.fetchReceivables(status: _selectedStatus, refresh: true);
    await provider.fetchReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piutang Pelanggan'),
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
          Consumer<ReceivableProvider>(
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
                            const Icon(Icons.payment, size: 28, color: AppColors.error),
                            const SizedBox(height: 8),
                            Text(
                              Formatters.formatCurrency(report?['summary']?['total_receivable']?.toDouble() ?? 0),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.error),
                            ),
                            const Text('Total Piutang', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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

          // Status Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
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
          ),
          const SizedBox(height: 16),

          // Receivables List
          Expanded(
            child: Consumer<ReceivableProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.receivables.isEmpty) {
                  return const LoadingWidget(fullScreen: false);
                }

                if (provider.receivables.isEmpty) {
                  return EmptyStateWidget(
                    title: 'Tidak Ada Piutang',
                    message: _selectedStatus == 'pending'
                        ? 'Belum ada piutang yang tercatat'
                        : _selectedStatus == 'paid'
                        ? 'Belum ada piutang yang lunas'
                        : 'Tidak ada piutang yang jatuh tempo',
                    icon: Icons.receipt_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.receivables.length,
                  itemBuilder: (context, index) {
                    final receivable = provider.receivables[index];
                    return _buildReceivableCard(receivable);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivableCard(Receivable receivable) {
    final isOverdue = receivable.isOverdue;

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
                      receivable.customerName ?? 'Pelanggan',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      receivable.receivableNumber,
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
                      : receivable.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOverdue ? 'Overdue' : receivable.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? AppColors.error : receivable.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn('Total Piutang', receivable.formattedAmount),
              ),
              Expanded(
                child: _buildInfoColumn('Telah Dibayar', receivable.formattedPaidAmount),
              ),
              Expanded(
                child: _buildInfoColumn('Sisa', receivable.formattedRemainingAmount),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn(
                  'Jatuh Tempo',
                  Formatters.formatDate(receivable.dueDate),
                  isOverdue: isOverdue,
                ),
              ),
              if (receivable.customerPhone != null)
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