import 'package:flutter/material.dart';
import 'package:inventify/widgets/owner/summary_card.dart';
import 'package:inventify/widgets/owner/owner_helpers.dart';
import 'package:inventify/theme.dart';

class LaporanBulan extends StatelessWidget {
  final bool loading;
  final Map<String, dynamic> data;
  final VoidCallback onRefresh;

  const LaporanBulan({super.key, required this.loading, required this.data, required this.onRefresh});

  static const _bulanLabel = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
  static const _rankColor = [Color(0xFFFFB800), Color(0xFF9E9E9E), Color(0xFFCD7F32), AppColors.primary, AppColors.secondary];

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final now = DateTime.now();
    final topProduk = (data['topProduk'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>).toList() ?? [];
    final maxProduk = topProduk.isEmpty ? 1.0
        : topProduk.map((e) => (e['total'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
    final pendapatan = (data['pendapatan'] as num?)?.toDouble() ?? 0;
    final transaksi = (data['transaksi'] as int?) ?? 0;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Text('${_bulanLabel[now.month]} ${now.year}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
          childAspectRatio: 1.45, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SummaryCard(label: 'Total Pendapatan', value: rupiahFormat(pendapatan),
              icon: Icons.account_balance_wallet_outlined, color: AppColors.primary),
            SummaryCard(label: 'Total Transaksi', value: '$transaksi',
              icon: Icons.receipt_long_rounded, color: AppColors.secondary),
            SummaryCard(label: 'Item Terjual', value: '${data['itemTerjual'] ?? 0}',
              icon: Icons.shopping_bag_outlined, color: const Color(0xFF1D9E75)),
            SummaryCard(
              label: 'Rata-rata/Transaksi',
              value: transaksi > 0 ? rupiahFormat(pendapatan / transaksi) : 'Rp 0',
              icon: Icons.bar_chart_rounded, color: Colors.orange),
          ],
        ),

        if (topProduk.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Produk Terlaris',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 8),
          ...topProduk.asMap().entries.map((e) {
            final i = e.key;
            final p = e.value;
            final ratio = maxProduk > 0 ? (p['total'] as num).toDouble() / maxProduk : 0.0;
            final color = _rankColor[i % _rankColor.length];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
              child: Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Center(child: Text('${i + 1}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 5),
                  ClipRRect(borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 4)),
                ])),
                const SizedBox(width: 10),
                Text(rupiahFormat((p['total'] as num).toDouble()),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ]),
            );
          }),
        ],
      ]),
    );
  }
}