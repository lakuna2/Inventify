import 'package:flutter/material.dart';
import 'package:inventify/controllers/cart_controller.dart';
import 'package:inventify/services/produk_service.dart';
import 'package:inventify/widgets/barcode_scanner.dart';
import 'package:inventify/widgets/cart_item.dart';
import 'package:inventify/widgets/payment_sheet.dart';
import 'package:inventify/theme.dart';

class Transaksi extends StatefulWidget {
  const Transaksi({super.key});
  @override
  State<Transaksi> createState() => _TransaksiState();
}

class _TransaksiState extends State<Transaksi> {
  final _cart = CartController();
  final _svc = ProductService();
  bool _loadingBarcode = false;
  String? _lastScanned; // feedback nama barang terakhir di-scan

  Future<void> _onBarcode(String code) async {
    if (_loadingBarcode) return;
    setState(() {
      _loadingBarcode = true;
      _lastScanned = null;
    });

    final product = await _svc.getByBarcode(code);
    if (!mounted) return;

    setState(() => _loadingBarcode = false);

    if (product == null) {
      _showFeedback('Barang tidak ditemukan', isError: true);
      return;
    }

    // Cek stok — hitung yang sudah di keranjang
    final inCart = _cart.items
        .where((i) => i.productId == product.id)
        .fold(0, (s, i) => s + i.qty);

    if (product.stock <= 0) {
      _showFeedback('${product.name} — stok habis', isError: true);
      return;
    }

    if (inCart >= product.stock) {
      _showFeedback(
        '${product.name} — stok hanya ${product.stock} pcs',
        isError: true,
      );
      return;
    }

    _cart.addProduct(product);
    setState(() => _lastScanned = product.name);
  }

  void _showFeedback(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? AppColors.habis : AppColors.tersedia,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ← tambah ini
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            SingleChildScrollView(
              // ✅ wrap scanner saja
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: _ScannerArea(
                    onDetected: _onBarcode,
                    loading: _loadingBarcode,
                    lastScanned: _lastScanned,
                  ),
                ),
              ),
            ),
            
            // ── Keranjang ──
            Expanded(
              child: ListenableBuilder(
                listenable: _cart,
                builder: (context, _) =>
                    _cart.isEmpty ? const _EmptyCart() : _CartList(cart: _cart),
              ),
            ),

            // ── Footer bayar ──
            ListenableBuilder(
              listenable: _cart,
              builder: (context, _) =>
                  _cart.isEmpty ? const SizedBox() : _Footer(cart: _cart),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Transaksi',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class _ScannerArea extends StatelessWidget {
  final void Function(String) onDetected;
  final bool loading;
  final String? lastScanned;
  const _ScannerArea({
    required this.onDetected,
    required this.loading,
    this.lastScanned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kamera
        loading
            ? Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            : BarcodeScanner(onDetected: onDetected),

        // Feedback barang terakhir di-scan
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: lastScanned != null
              ? Container(
                  key: ValueKey(lastScanned),
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tersedia.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.tersedia.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.tersedia,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ditambahkan: $lastScanned',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.tersedia,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(key: ValueKey('empty'), height: 8),
        ),
        const SizedBox(height: 4),
        _ManualBarcodeInput(onSubmit: onDetected),
      ],
    );
  }
}

class _CartList extends StatelessWidget {
  final CartController cart;
  const _CartList({required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      itemCount: cart.items.length,
      itemBuilder: (_, i) => CartItemTile(item: cart.items[i], cart: cart),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 56,
            color: AppColors.textGrey.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Arahkan kamera ke barcode barang',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDark.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final CartController cart;
  const _Footer({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '${cart.totalQty} item',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              const Text(
                'Total ',
                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
              Text(
                rupiahFormat(cart.total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Hapus semua
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Bersihkan keranjang?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          cart.clear();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.habis,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.habis.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.habis,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => PaymentSheet.show(context, cart),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Bayar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManualBarcodeInput extends StatelessWidget {
  final void Function(String) onSubmit;
  _ManualBarcodeInput({required this.onSubmit});
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: 'Atau input barcode manual...',
              hintStyle: TextStyle(
                color: AppColors.textDark.withValues(alpha: 0.4),
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (_ctrl.text.trim().isNotEmpty) onSubmit(_ctrl.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'OK',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
