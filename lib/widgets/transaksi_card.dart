import 'package:flutter/material.dart';
import 'package:inventify/models/transaksi_model.dart';
import 'package:inventify/widgets/cart_item.dart'; // rupiahFormat
import 'package:inventify/theme.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onTap;
  const TransactionCard({super.key, required this.tx, required this.onTap});

  String _waktu(DateTime d) {
    final jam = d.hour.toString().padLeft(2, '0');
    final mnt = d.minute.toString().padLeft(2, '0');
    return '$jam:$mnt';
  }

  String _tanggal(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          // Icon transaksi
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_outlined, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 12),

          // Info transaksi
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#${tx.id.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
            const SizedBox(height: 3),
            Text('${tx.items.length} item  •  ${_tanggal(tx.createdAt)}  ${_waktu(tx.createdAt)}',
              style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.5))),
          ])),

          // Total
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(rupiahFormat(tx.total),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
            const SizedBox(height: 3),
            Text('Laba ${rupiahFormat(tx.totalLaba)}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.tersedia)),
          ]),
        ]),
      ),
    );
  }
}