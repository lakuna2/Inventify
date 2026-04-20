import 'package:flutter/material.dart';
import 'package:inventify/widgets/owner/summary_card.dart';
import 'package:inventify/widgets/owner/owner_helpers.dart';
import 'package:inventify/theme.dart';

class LaporanMinggu extends StatelessWidget {
  final bool loading;
  final List<Map<String, dynamic>> data;
  final VoidCallback onRefresh;

  const LaporanMinggu({super.key, required this.loading, required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final maxVal = data.isEmpty ? 1.0
        : data.map((e) => (e['total'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
    final totalPendapatan = data.fold(0.0, (s, e) => s + (e['total'] as num).toDouble());
    final totalTx = data.fold(0, (s, e) => s + (e['jumlah'] as num).toInt());

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: ListView(padding: const EdgeInsets.all(16), children: [

        // Bar chart
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Penjualan 7 Hari Terakhir',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((item) {
                  final val = (item['total'] as num).toDouble();
                  final ratio = maxVal > 0 ? val / maxVal : 0.0;
                  final isToday = item == data.last;
                  return Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      if (val > 0) Text(_shortVal(val),
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600,
                          color: isToday ? AppColors.primary : AppColors.textGrey)),
                      const SizedBox(height: 3),
                      Container(
                        height: (ratio * 90).clamp(4, 90),
                        decoration: BoxDecoration(
                          color: isToday ? AppColors.primary : AppColors.primary.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(5)),
                      ),
                      const SizedBox(height: 5),
                      Text(item['label'],
                        style: TextStyle(fontSize: 10,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          color: isToday ? AppColors.primary : AppColors.textGrey)),
                    ]),
                  ));
                }).toList(),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // Summary cards
        GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
          childAspectRatio: 1.5, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SummaryCard(label: 'Total Pendapatan', value: rupiahFormat(totalPendapatan),
              icon: Icons.trending_up_rounded, color: AppColors.primary),
            SummaryCard(label: 'Total Transaksi', value: '$totalTx',
              icon: Icons.receipt_long_rounded, color: AppColors.secondary),
          ],
        ),
        const SizedBox(height: 14),

        // Detail per hari
        const Text('Detail Per Hari',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 8),
        ...data.reversed.map((item) {
          final tgl = item['tanggal'] as DateTime;
          return Container(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(7)),
                child: Text(item['label'],
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('${tgl.day}/${tgl.month}/${tgl.year}',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey.withValues(alpha: 0.7)))),
              Text('${item['jumlah']} tx',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
              const SizedBox(width: 10),
              Text(rupiahFormat((item['total'] as num).toDouble()),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ]),
          );
        }),
      ]),
    );
  }

  String _shortVal(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}rb';
    return v.toStringAsFixed(0);
  }
}