import 'package:flutter/material.dart';
import 'package:inventify/controllers/cart_controller.dart';
import 'package:inventify/services/transaksi_service.dart';
import 'package:inventify/widgets/cart_item.dart';
import 'package:inventify/theme.dart';

class PaymentSheet {
  static void show(BuildContext context, CartController cart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheetContent(cart: cart),
    );
  }
}

class _PaymentSheetContent extends StatefulWidget {
  final CartController cart;
  const _PaymentSheetContent({required this.cart});
  @override
  State<_PaymentSheetContent> createState() => _PaymentSheetContentState();
}

class _PaymentSheetContentState extends State<_PaymentSheetContent> {
  final _bayarCtrl = TextEditingController();
  bool _loading = false;

  double get _total => widget.cart.total;
  double get _bayar => double.tryParse(_bayarCtrl.text.replaceAll('.', '')) ?? 0;
  double get _kembalian => _bayar - _total;
  bool get _cukup => _bayar >= _total;

  // Quick-pay buttons
  List<int> get _quickPay {
    final rounded = (_total / 1000).ceil() * 1000;
    return [rounded, rounded + 5000, rounded + 10000, rounded + 20000]
        .where((v) => v >= _total)
        .toList()
        .take(4)
        .toList();
  }

  Future<void> _bayarSekarang() async {
    if (!_cukup) return;
    setState(() => _loading = true);
    try {
      final id = await TransactionService().simpan(
        items: widget.cart.items,
        total: _total,
        bayar: _bayar,
        kasir: 'Kasir', // Ganti dengan nama kasir dari auth
      );
      if (!mounted) return;
      Navigator.pop(context); // tutup payment sheet
      // Buka resi
      ReceiptSheet.show(context, txId: id, cart: widget.cart, bayar: _bayar);
      widget.cart.clear();
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.habis));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
          const SizedBox(height: 16),

          // Total
          _summaryRow('Total', _total, big: true),
          const SizedBox(height: 16),

          // Input bayar
          TextField(
            controller: _bayarCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            decoration: InputDecoration(
              labelText: 'Jumlah Bayar',
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
              prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.secondary),
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 10),

          // Quick pay chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _quickPay.map((v) => GestureDetector(
              onTap: () {
                _bayarCtrl.text = v.toString(); // ← input parsing pakai replaceAll('.','')
                setState(() {});
              },
               child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  rupiahFormat(v.toDouble()), // ← toDouble() bukan as double
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                ),
              ),
            )).toList()),
          ),
          const SizedBox(height: 16),

          // Kembalian
          if (_bayar > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _cukup ? AppColors.tersedia.withValues(alpha: 0.08) : AppColors.habis.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _cukup ? AppColors.tersedia.withValues(alpha: 0.3) : AppColors.habis.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                Icon(_cukup ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                  color: _cukup ? AppColors.tersedia : AppColors.habis, size: 18),
                const SizedBox(width: 10),
                Text(_cukup ? 'Kembalian' : 'Kurang',
                  style: TextStyle(fontSize: 13, color: _cukup ? AppColors.tersedia : AppColors.habis)),
                const Spacer(),
                Text(rupiahFormat(_cukup ? _kembalian : _total - _bayar),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: _cukup ? AppColors.tersedia : AppColors.habis)),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          // Tombol bayar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cukup && !_loading ? _bayarSekarang : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Bayar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _summaryRow(String label, double val, {bool big = false}) {
    return Row(children: [
      Text(label, style: TextStyle(
        fontSize: big ? 15 : 13,
        color: big ? AppColors.textDark : AppColors.textGrey,
        fontWeight: big ? FontWeight.w600 : FontWeight.w400,
      )),
      const Spacer(),
      Text(rupiahFormat(val), style: TextStyle(
        fontSize: big ? 20 : 14,
        fontWeight: FontWeight.w700,
        color: big ? AppColors.primary : AppColors.textDark,
      )),
    ]);
  }
}

// ── Receipt Sheet ─────────────────────────────────────────────────────────

class ReceiptSheet {
  static void show(BuildContext context, {required String txId, required CartController cart, required double bayar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReceiptContent(txId: txId, items: cart.items, total: cart.total, bayar: bayar),
    );
  }
}

class _ReceiptContent extends StatelessWidget {
  final String txId;
  final List items;
  final double total, bayar;
  const _ReceiptContent({required this.txId, required this.items, required this.total, required this.bayar});

  double get _kembalian => bayar - total;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),

        // Header resi
        const Icon(Icons.check_circle_rounded, color: AppColors.tersedia, size: 48),
        const SizedBox(height: 8),
        const Text('Transaksi Berhasil!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text('#${txId.substring(0, 8).toUpperCase()}',
          style: TextStyle(fontSize: 12, color: AppColors.textGrey.withValues(alpha: 0.8))),
        Text('${now.day}/${now.month}/${now.year}  ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}',
          style: TextStyle(fontSize: 12, color: AppColors.textGrey.withValues(alpha: 0.8))),
        const SizedBox(height: 16),

        // Garis putus-putus
        _dashed(),
        const SizedBox(height: 12),

        // Item list
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
              Text('${item.qty} x ${rupiahFormat(item.hargaJual)}',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey.withValues(alpha: 0.8))),
            ])),
            Text(rupiahFormat(item.subtotal),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ]),
        )),

        const SizedBox(height: 12),
        _dashed(),
        const SizedBox(height: 12),

        // Summary
        _receiptRow('Total', rupiahFormat(total), bold: true),
        const SizedBox(height: 4),
        _receiptRow('Bayar', rupiahFormat(bayar)),
        const SizedBox(height: 4),
        _receiptRow('Kembalian', rupiahFormat(_kembalian),
          valueColor: AppColors.tersedia, bold: true),

        const SizedBox(height: 16),
        _dashed(),
        const SizedBox(height: 12),
        Text('Terima kasih telah berbelanja!',
          style: TextStyle(fontSize: 12, color: AppColors.textGrey.withValues(alpha: 0.7)),
          textAlign: TextAlign.center),
        const SizedBox(height: 20),

        // Tombol aksi
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () {}, // TODO: implementasi print
            icon: const Icon(Icons.print_outlined, size: 18),
            label: const Text('Cetak'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.secondary),
              foregroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: const Text('Selesai'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          )),
        ]),
      ]),
    );
  }

  Widget _receiptRow(String label, String value, {bool bold = false, Color? valueColor}) {
    return Row(children: [
      Text(label, style: TextStyle(fontSize: 13, color: AppColors.textGrey.withValues(alpha: 0.8))),
      const Spacer(),
      Text(value, style: TextStyle(
        fontSize: bold ? 15 : 13,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: valueColor ?? AppColors.textDark,
      )),
    ]);
  }

  Widget _dashed() {
    return Row(children: List.generate(30, (_) => Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 1,
        color: AppColors.textGrey.withValues(alpha: 0.2),
      ),
    )));
  }
}