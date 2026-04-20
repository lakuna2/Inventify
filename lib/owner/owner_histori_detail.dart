import 'package:flutter/material.dart';
import 'package:inventify/widgets/owner/owner_helpers.dart';
import 'package:inventify/theme.dart';

class HistoriDetail {
  static void show(BuildContext context, {
    required Map<String, dynamic> tx,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistoriDetailSheet(tx: tx, onDelete: onDelete),
    );
  }
}

class _HistoriDetailSheet extends StatelessWidget {
  final Map<String, dynamic> tx;
  final VoidCallback onDelete;

  const _HistoriDetailSheet({required this.tx, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final items = tx['items'] as List<dynamic>? ?? [];
    final total = (tx['total'] as num).toDouble();
    final bayar = (tx['bayar'] as num?)?.toDouble() ?? total;
    final waktu = (tx['createdAt'] as dynamic)?.toDate() ?? DateTime.now();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(controller: ctrl, children: [
          // Handle
          Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),

          // Header
          Text('Detail Transaksi',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text('#${(tx['id'] as String).substring(0, 8).toUpperCase()}  ·  '
            '${waktu.day}/${waktu.month}/${waktu.year} '
            '${waktu.hour.toString().padLeft(2,'0')}:${waktu.minute.toString().padLeft(2,'0')}',
            style: TextStyle(fontSize: 11, color: AppColors.textGrey.withValues(alpha: 0.7))),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),

          // Items
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['nama'] ?? item['name'] ?? '',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                Text('${item['qty']} x ${rupiahFormat((item['hargaJual'] as num).toDouble())}',
                  style: TextStyle(fontSize: 11, color: AppColors.textGrey.withValues(alpha: 0.7))),
              ])),
              Text(rupiahFormat((item['subtotal'] as num).toDouble()),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ]),
          )),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          _row('Kasir', tx['kasir'] ?? '-'),
          _row('Total', rupiahFormat(total), bold: true),
          _row('Bayar', rupiahFormat(bayar)),
          _row('Kembalian', rupiahFormat(bayar - total), valueColor: AppColors.tersedia),
          const SizedBox(height: 20),

          // Actions
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () { Navigator.pop(context); onDelete(); },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: AppColors.habis),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Hapus', style: TextStyle(color: AppColors.habis, fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.textGrey.withValues(alpha: 0.8))),
        const Spacer(),
        Text(value, style: TextStyle(
          fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: valueColor ?? AppColors.textDark)),
      ]),
    );
  }
}