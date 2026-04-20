import 'package:flutter/material.dart';
import 'package:inventify/models/transaksi_model.dart';
import 'package:inventify/widgets/cart_item.dart'; // rupiahFormat
import 'package:inventify/theme.dart';

class TransactionDetailSheet {
  static void show(BuildContext context, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailContent(tx: tx),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final TransactionModel tx;
  const _DetailContent({required this.tx});

  String _fmt(DateTime d) {
    final hari = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    final bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    final jam = d.hour.toString().padLeft(2, '0');
    final mnt = d.minute.toString().padLeft(2, '0');
    return '${hari[d.weekday - 1]}, ${d.day} ${bulan[d.month - 1]} ${d.year}  $jam:$mnt';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle + header (fixed)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(children: [
              Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: Text('Detail Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark))),
                // Badge ID
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('#${tx.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                ),
              ]),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_fmt(tx.createdAt),
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey.withValues(alpha: 0.8))),
              ),
              const SizedBox(height: 12),
            ]),
          ),

          // Scrollable content
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                // Info kasir
                _InfoRow(icon: Icons.person_outline, label: 'Kasir', value: tx.kasir),
                const SizedBox(height: 6),
                _InfoRow(icon: Icons.shopping_bag_outlined, label: 'Total item',
                  value: '${tx.items.length} produk'),
                const SizedBox(height: 14),

                // List item
                const Text('Barang Dibeli',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 8),
                ...tx.items.map((item) => _ItemRow(item: item)),

                const SizedBox(height: 14),
                _dashed(),
                const SizedBox(height: 14),

                // Summary pembayaran
                _SummarySection(tx: tx),

                const SizedBox(height: 14),
                _dashed(),
                const SizedBox(height: 14),

                // Laba transaksi ini
                _LabaSection(tx: tx),
              ],
            ),
          ),

          // Tombol cetak (fixed di bawah)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {}, // TODO: sambungkan printer
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Cetak Ulang Resi'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.secondary),
                  foregroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _dashed() => Row(children: List.generate(28, (_) => Expanded(
    child: Container(margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 1, color: AppColors.textGrey.withValues(alpha: 0.2)),
  )));
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.textGrey),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontSize: 13, color: AppColors.textGrey.withValues(alpha: 0.8))),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
    ]);
  }
}

class _ItemRow extends StatelessWidget {
  final CartItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
          Text('${item.qty} x ${rupiahFormat(item.hargaJual)}',
            style: TextStyle(fontSize: 11, color: AppColors.textGrey.withValues(alpha: 0.8))),
        ])),
        Text(rupiahFormat(item.subtotal),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      ]),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final TransactionModel tx;
  const _SummarySection({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _row('Total Belanja', rupiahFormat(tx.total), bold: true, size: 15),
      const SizedBox(height: 6),
      _row('Dibayar', rupiahFormat(tx.bayar)),
      const SizedBox(height: 6),
      _row('Kembalian', rupiahFormat(tx.kembalian), color: AppColors.tersedia, bold: true),
    ]);
  }

  Widget _row(String label, String value, {bool bold = false, Color? color, double size = 13}) {
    return Row(children: [
      Text(label, style: TextStyle(fontSize: size, color: AppColors.textGrey.withValues(alpha: 0.8))),
      const Spacer(),
      Text(value, style: TextStyle(
        fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: color ?? AppColors.textDark)),
    ]);
  }
}

class _LabaSection extends StatelessWidget {
  final TransactionModel tx;
  const _LabaSection({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tersedia.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tersedia.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.trending_up_rounded, color: AppColors.tersedia, size: 20),
        const SizedBox(width: 10),
        const Text('Laba transaksi ini',
          style: TextStyle(fontSize: 13, color: AppColors.tersedia, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(rupiahFormat(tx.totalLaba),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.tersedia)),
      ]),
    );
  }
}