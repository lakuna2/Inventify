import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';
import 'package:inventify/widgets/owner/owner_helpers.dart';

class RecentTxTile extends StatelessWidget {
  final String txId;
  final DateTime waktu;
  final double total;
  final int jumlahItem;
  final String kasir;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const RecentTxTile({
    super.key,
    required this.txId,
    required this.waktu,
    required this.total,
    required this.jumlahItem,
    required this.kasir,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 18),
        ),
        title: Row(children: [
          Text('#${txId.substring(0, 8).toUpperCase()}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
            child: Text('$jumlahItem item',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.secondary)),
          ),
        ]),
        subtitle: Text('${_formatWaktu(waktu)}  ·  $kasir',
          style: TextStyle(fontSize: 11, color: AppColors.textGrey.withValues(alpha: 0.7))),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(rupiahFormat(total),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
          if (onDelete != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.delete_outline_rounded, color: AppColors.habis.withValues(alpha: 0.5), size: 17),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  String _formatWaktu(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}