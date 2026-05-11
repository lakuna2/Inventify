import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

class LaporanStok extends StatelessWidget {
  final bool loading;
  final List<Map<String, dynamic>> data;
  final VoidCallback onRefresh;

  const LaporanStok({super.key, required this.loading, required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    // Pisah produk stok tipis (≤ 5) dan stok aman (> 5)
    final stokTipis = data.where((item) => (item['stok'] as int) <= 5).toList();
    final stokAman  = data.where((item) => (item['stok'] as int) >  5).toList();

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: data.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textGrey.withValues(alpha: 0.3)),
                const SizedBox(height: 10),
                const Text('Belum ada produk',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text('Tambahkan produk terlebih dahulu',
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey.withValues(alpha: 0.6))),
              ]),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // ── SECTION 1: Stok Tipis ─────────────────────────────
                if (stokTipis.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.habis.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.habis.withValues(alpha: 0.2))),
                    child: Row(children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.habis, size: 16),
                      const SizedBox(width: 8),
                      Text('${stokTipis.length} produk perlu direstok',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.habis)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  ...stokTipis.map((item) => _buildItem(item, isWarning: true)),
                ],

                // ── SECTION 2: Stok Aman ──────────────────────────────
                if (stokAman.isNotEmpty) ...[
                  if (stokTipis.isNotEmpty) const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 14, color: AppColors.tersedia.withValues(alpha: 0.8)),
                          const SizedBox(width: 6),
                          Text('Stok Aman',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.tersedia.withValues(alpha: 0.8))),
                        ]),
                        Text('${stokAman.length} produk',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                  ...stokAman.map((item) => _buildItem(item, isWarning: false)),
                ],
              ],
            ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item, {required bool isWarning}) {
    final stok = item['stok'] as int;

    final Color warnaStok = stok == 0
        ? AppColors.habis
        : stok <= 2
            ? Colors.orange
            : stok <= 5
                ? Colors.amber
                : AppColors.tersedia;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isWarning
            ? Border.all(color: warnaStok.withValues(alpha: 0.2))
            : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: warnaStok.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9)),
          child: Icon(Icons.inventory_2_outlined, color: warnaStok, size: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['nama'],
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              if (isWarning)
                Text(
                  stok == 0 ? 'Stok habis' : 'Stok menipis',
                  style: TextStyle(fontSize: 10, color: warnaStok),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: warnaStok.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text('$stok pcs',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: warnaStok))),
        if (isWarning) ...[
          const SizedBox(width: 6),
          Icon(Icons.warning_amber_rounded, color: warnaStok, size: 13),
        ],
      ]),
    );
  }
}