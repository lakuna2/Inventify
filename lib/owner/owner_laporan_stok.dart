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

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: data.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.tersedia.withValues(alpha: 0.4)),
            const SizedBox(height: 10),
            const Text('Semua stok aman!',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.tersedia)),
            Text('Tidak ada produk stok ≤ 5',
              style: TextStyle(fontSize: 12, color: AppColors.textGrey.withValues(alpha: 0.6))),
          ]))
        : ListView(padding: const EdgeInsets.all(16), children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.habis.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.habis.withValues(alpha: 0.2))),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.habis, size: 16),
                const SizedBox(width: 8),
                Text('${data.length} produk perlu direstok',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.habis)),
              ]),
            ),
            const SizedBox(height: 12),
            ...data.map((item) {
              final stok = item['stok'] as int;
              final color = stok == 0 ? AppColors.habis : stok <= 2 ? Colors.orange : Colors.amber;
              return Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
                    child: Icon(Icons.inventory_2_outlined, color: color, size: 16)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item['nama'],
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text('$stok pcs',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color))),
                ]),
              );
            }),
          ]),
    );
  }
}