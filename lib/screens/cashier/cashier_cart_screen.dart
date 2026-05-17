import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/success_snackbar.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/utils/validators.dart';

class CashierCartScreen extends StatefulWidget {
  const CashierCartScreen({super.key});

  @override
  State<CashierCartScreen> createState() => _CashierCartScreenState();
}

class _CashierCartScreenState extends State<CashierCartScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _downPaymentController = TextEditingController();

  String _selectedPaymentType = 'cash';
  int _dueDays = 30;
  bool _isProcessing = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _discountController.dispose();
    _downPaymentController.dispose();
    super.dispose();
  }

  Future<void> _processTransaction() async {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    if (_selectedPaymentType == 'receivable') {
      if (_customerNameController.text.isEmpty) {
        SuccessSnackbar.showError(context, 'Nama pelanggan wajib diisi untuk transaksi piutang');
        return;
      }
      if (_customerPhoneController.text.isEmpty) {
        SuccessSnackbar.showError(context, 'Nomor telepon pelanggan wajib diisi untuk transaksi piutang');
        return;
      }
    }

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Konfirmasi Transaksi',
      message: 'Apakah Anda yakin dengan transaksi ini?',
      confirmText: 'Ya, Proses',
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    transactionProvider.setPaymentType(_selectedPaymentType);
    transactionProvider.setCustomer(
      _customerNameController.text.isNotEmpty ? _customerNameController.text : null,
      _customerPhoneController.text.isNotEmpty ? _customerPhoneController.text : null,
      _customerAddressController.text.isNotEmpty ? _customerAddressController.text : null,
    );

    if (_discountController.text.isNotEmpty) {
      transactionProvider.setDiscount(double.parse(_discountController.text));
    }

    if (_selectedPaymentType == 'receivable') {
      transactionProvider.setDueDays(_dueDays);
    }

    final success = await transactionProvider.createTransaction();
    setState(() => _isProcessing = false);

    if (success) {
      SuccessSnackbar.show(context, 'Transaksi berhasil!');
      Navigator.pop(context, true);
    } else {
      SuccessSnackbar.showError(context, transactionProvider.error ?? 'Gagal memproses transaksi');
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final cart = transactionProvider.cart;

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Keranjang Belanja'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text(
                'Keranjang Belanja Kosong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan tambahkan produk dari halaman transaksi',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali ke Transaksi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context: context,
                title: 'Kosongkan Keranjang',
                message: 'Apakah Anda yakin ingin mengosongkan keranjang?',
                confirmText: 'Ya, Kosongkan',
              );
              if (confirmed == true) {
                transactionProvider.clearCart();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    return _buildCartItem(item, transactionProvider);
                  },
                ),
              ),
              // Payment Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', transactionProvider.subtotal),
                    if (transactionProvider.discount > 0)
                      _buildSummaryRow('Diskon', -transactionProvider.discount),
                    const Divider(),
                    _buildSummaryRow('Total', transactionProvider.total, isBold: true),
                    const SizedBox(height: 16),

                    // Discount Field
                    TextField(
                      controller: _discountController,
                      decoration: InputDecoration(
                        labelText: 'Diskon (Opsional)',
                        hintText: 'Masukkan nominal diskon',
                        prefixIcon: const Icon(Icons.discount),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixText: 'Rp',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          transactionProvider.setDiscount(double.tryParse(value) ?? 0);
                        } else {
                          transactionProvider.setDiscount(0);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Payment Method
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaymentOption('cash', 'Tunai', Icons.money),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPaymentOption('transfer', 'Transfer', Icons.credit_card),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPaymentOption('qris', 'QRIS', Icons.qr_code),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPaymentOption('receivable', 'Piutang', Icons.receipt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Customer Info for Receivable
                    if (_selectedPaymentType == 'receivable') ...[
                      const Divider(),
                      const Text(
                        'Data Pelanggan',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan *',
                          hintText: 'Masukkan nama pelanggan',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _customerPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon *',
                          hintText: 'Contoh: 081234567890',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _customerAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat',
                          hintText: 'Masukkan alamat pelanggan',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Jatuh Tempo: '),
                          Expanded(
                            child: Slider(
                              value: _dueDays.toDouble(),
                              min: 7,
                              max: 30,
                              divisions: 23,
                              label: '$_dueDays hari',
                              onChanged: (value) {
                                setState(() {
                                  _dueDays = value.toInt();
                                });
                              },
                            ),
                          ),
                          Text('$_dueDays hari'),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    CustomButton(
                      text: 'Proses Transaksi',
                      onPressed: _processTransaction,
                      isLoading: _isProcessing,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, TransactionProvider provider) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag, size: 30, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '@ ${Formatters.formatCurrency(item.price)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 24),
                    onPressed: () {
                      if (item.quantity > 1) {
                        provider.updateCartQuantity(item.productId, item.quantity - 1);
                        setState(() {});
                      } else {
                        provider.removeFromCart(item.productId);
                        setState(() {});
                      }
                    },
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      item.quantity.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 24),
                    onPressed: () {
                      if (item.quantity < item.stock) {
                        provider.updateCartQuantity(item.productId, item.quantity + 1);
                        setState(() {});
                      } else {
                        SuccessSnackbar.showError(context, 'Stok tidak mencukupi');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.formatCurrency(item.totalPrice),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = _selectedPaymentType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}