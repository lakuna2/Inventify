import 'package:flutter/material.dart';
import 'package:inventify/models/transaksi_model.dart';
import 'package:inventify/controllers/cart_controller.dart';
import 'package:inventify/theme.dart';

String rupiahFormat(double v) {
  final s = v.toStringAsFixed(0);
  final buf = StringBuffer();
  int c = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    buf.write(s[i]);
    if (++c % 3 == 0 && i != 0) buf.write('.');
  }
  return 'Rp ${buf.toString().split('').reversed.join()}';
}

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final CartController cart;
  const CartItemTile({super.key, required this.item, required this.cart});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        // Nama & harga satuan
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(rupiahFormat(item.hargaJual),
            style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.5))),
          // Indikator stok maks
          if (item.isMaxQty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('Maks stok (${item.maxStock})',
                style: const TextStyle(fontSize: 11, color: AppColors.stokTipis, fontWeight: FontWeight.w500)),
            ),
        ])),
 
        // Kontrol qty
        Row(children: [
          _qtyBtn(
            icon: Icons.remove,
            onTap: () => cart.decrement(item.productId),
            bg: AppColors.habis.withValues(alpha: 0.1),
            fg: AppColors.habis,
            enabled: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${item.qty}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
          ),
          _qtyBtn(
            icon: Icons.add,
            onTap: () {
              final ok = cart.increment(item.productId);
              if (!ok) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text('${item.name} — stok hanya ${item.maxStock} pcs'),
                    backgroundColor: AppColors.stokTipis,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
              }
            },
            bg: item.isMaxQty
                ? AppColors.textGrey.withValues(alpha: 0.08)
                : AppColors.secondary.withValues(alpha: 0.1),
            fg: item.isMaxQty ? AppColors.textGrey.withValues(alpha: 0.4) : AppColors.secondary,
            enabled: !item.isMaxQty,
          ),
        ]),
 
        // Subtotal
        const SizedBox(width: 12),
        Text(rupiahFormat(item.subtotal),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
      ]),
    );
  }
 
  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color fg,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: fg),
      ),
    );
  }
}
 