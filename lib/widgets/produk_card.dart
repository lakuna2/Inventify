import 'package:flutter/material.dart';
import 'package:inventify/models/produk_model.dart';
import 'package:inventify/services/produk_service.dart';
import 'package:inventify/widgets/produk_form.dart';
import 'package:inventify/theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  static String rupiah(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      if (++c % 3 == 0 && i != 0) buf.write('.');
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductActions(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showActions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Baris atas: avatar + nama + status stok
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: product.avatarBg, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(product.initials,
                style: TextStyle(color: product.avatarFg, fontWeight: FontWeight.w700, fontSize: 14))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name,
                style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 15)),
              Text('Stok: ${product.stock} pcs  •  ${product.stockStatus}',
                style: TextStyle(color: product.stockColor, fontSize: 12, fontWeight: FontWeight.w500)),
            ])),
          ]),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Baris bawah: harga beli | harga jual | laba
          Row(children: [
            _priceInfo('Harga Beli', product.hargaBeli, AppColors.textGrey),
            _divider(),
            _priceInfo('Harga Jual', product.hargaJual, AppColors.textDark),
            _divider(),
            _labaInfo(product),
          ]),
        ]),
      ),
    );
  }

  Widget _priceInfo(String label, double value, Color color) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, color: AppColors.textGrey.withValues(alpha: 0.8))),
      const SizedBox(height: 2),
      Text(rupiah(value), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]));
  }

  Widget _labaInfo(Product p) {
    final isPositive = p.laba >= 0;
    final color = isPositive ? AppColors.tersedia : AppColors.habis;
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Laba/unit', style: TextStyle(fontSize: 10, color: AppColors.textGrey.withValues(alpha: 0.8))),
      const SizedBox(height: 2),
      Text(rupiah(p.laba),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      Text('${p.marginPersen.toStringAsFixed(1)}%',
        style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8))),
    ]));
  }

  Widget _divider() => Container(
    height: 32, width: 0.5,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: AppColors.textGrey.withValues(alpha: 0.3),
  );
}

// ── Action sheet saat produk diklik ──────────────────────────────────────

class _ProductActions extends StatelessWidget {
  final Product product;
  const _ProductActions({required this.product});

  void _hapus(BuildContext context) async {
    Navigator.pop(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Barang?',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin menghapus "${product.name}"?',
          style: TextStyle(color: AppColors.textDark.withValues(alpha: 0.6))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.habis, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) await ProductService().hapus(product.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        // Info singkat produk
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: product.avatarBg, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(product.initials,
              style: TextStyle(color: product.avatarFg, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text('Laba: ${ProductCard.rupiah(product.laba)} (${product.marginPersen.toStringAsFixed(1)}%)',
              style: TextStyle(fontSize: 12, color: AppColors.tersedia, fontWeight: FontWeight.w500)),
          ])),
        ]),
        const SizedBox(height: 14),
        const Divider(height: 1),
        const SizedBox(height: 12),
        _actionTile(Icons.edit_outlined, AppColors.secondary, 'Edit Barang', () {
          Navigator.pop(context);
          ProductForm.show(context, product: product);
        }),
        const SizedBox(height: 8),
        _actionTile(Icons.delete_outline, AppColors.habis, 'Hapus Barang', () => _hapus(context)),
        const SizedBox(height: 8),
        _actionTile(Icons.close, AppColors.textGrey, 'Batal', () => Navigator.pop(context)),
      ]),
    );
  }

  Widget _actionTile(IconData icon, Color color, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
        ]),
      ),
    );
  }
}