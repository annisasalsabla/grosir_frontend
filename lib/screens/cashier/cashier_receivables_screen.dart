
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/receivable_provider.dart';
import '../../models/receivable_model.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/success_snackbar.dart';
import '../../shared/utils/formatters.dart';

class CashierReceivablesScreen extends StatefulWidget {
  const CashierReceivablesScreen({super.key});

  @override
  State<CashierReceivablesScreen> createState() => _CashierReceivablesScreenState();
}

class _CashierReceivablesScreenState extends State<CashierReceivablesScreen> {
  String _selectedStatus = 'pending';
  Receivable? _selectedReceivable;
  bool _showPaymentDialog = false;
  final TextEditingController _paymentAmountController = TextEditingController();
  String _selectedPaymentMethod = 'cash';
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _loadReceivables();
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadReceivables() async {
    final provider = Provider.of<ReceivableProvider>(context, listen: false);
    await provider.fetchReceivables(status: _selectedStatus, refresh: true);
  }

  Future<void> _makePayment() async {
    if (_selectedReceivable == null) return;

    final amount = double.tryParse(_paymentAmountController.text);
    if (amount == null || amount <= 0) {
      SuccessSnackbar.showError(context, 'Masukkan jumlah pembayaran yang valid');
      return;
    }

    if (amount > _selectedReceivable!.remainingAmount) {
      SuccessSnackbar.showError(context, 'Jumlah pembayaran melebihi sisa piutang');
      return;
    }

    setState(() => _isPaying = true);
    final provider = Provider.of<ReceivableProvider>(context, listen: false);
    final success = await provider.payReceivable(
      _selectedReceivable!.id,
      amount,
      _selectedPaymentMethod,
    );
    setState(() => _isPaying = false);

    if (success) {
      setState(() {
        _showPaymentDialog = false;
        _selectedReceivable = null;
        _paymentAmountController.clear();
      });
      SuccessSnackbar.show(context, 'Pembayaran berhasil');
      _loadReceivables();
    } else {
      SuccessSnackbar.showError(context, provider.error ?? 'Gagal memproses pembayaran');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Piutang Pelanggan'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'pending', label: Text('Belum Lunas')),
                        ButtonSegment(value: 'paid', label: Text('Lunas')),
                        ButtonSegment(value: 'overdue', label: Text('Jatuh Tempo')),
                      ],
                      selected: {_selectedStatus},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          _selectedStatus = selection.first;
                        });
                        _loadReceivables();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Consumer<ReceivableProvider>(
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
        if (_showPaymentDialog && _selectedReceivable != null)
    _buildPaymentDialog(),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
              if (receivable.remainingAmount > 0)
                SizedBox(
                  width: 100,
                  child: CustomButton(
                    text: 'Bayar',
                    onPressed: () {
                      setState(() {
                        _selectedReceivable = receivable;
                        _showPaymentDialog = true;
                      });
                    },
                    height: 36,
                  ),
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

  Widget _buildPaymentDialog() {
    final receivable = _selectedReceivable!;
    final maxPayment = receivable.remainingAmount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pembayaran Piutang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pelanggan: ${receivable.customerName}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Sisa Piutang: ${receivable.formattedRemainingAmount}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const Divider(),
            const SizedBox(height: 16),
            TextField(
              controller: _paymentAmountController,
              decoration: InputDecoration(
                labelText: 'Jumlah Pembayaran',
                hintText: 'Maksimal ${Formatters.formatCurrency(maxPayment)}',
                prefixIcon: const Icon(Icons.money),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodOption('cash', 'Tunai', Icons.money),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPaymentMethodOption('transfer', 'Transfer', Icons.credit_card),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPaymentMethodOption('qris', 'QRIS', Icons.qr_code),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Batal',
                    onPressed: () {
                      setState(() {
                        _showPaymentDialog = false;
                        _selectedReceivable = null;
                        _paymentAmountController.clear();
                      });
                    },
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Bayar',
                    onPressed: _makePayment,
                    isLoading: _isPaying,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}