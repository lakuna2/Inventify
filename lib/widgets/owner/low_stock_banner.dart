import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

class LowStockBanner extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback? onTap;

  const LowStockBanner({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.habis.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.habis.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: AppColors.habis.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.habis, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${items.length} produk stok tipis',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.habis)),
            Text(items.take(3).map((e) => e['nama']).join(', ') + (items.length > 3 ? '...' : ''),
              style: TextStyle(fontSize: 10, color: AppColors.habis.withValues(alpha: 0.7)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Icon(Icons.chevron_right_rounded, color: AppColors.habis.withValues(alpha: 0.4), size: 16),
        ]),
      ),
    );
  }
}