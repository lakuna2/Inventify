// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:inventify/theme.dart';

////////////////////////////////////////////////////////////
/// RIWAYAT SECTION
////////////////////////////////////////////////////////////
class RiwayatSection extends StatelessWidget {
  final List<Map<String, dynamic>> riwayat;
  final bool isLoading;
  final VoidCallback onLihatSemua;
  final String Function(int) formatRupiah;

  const RiwayatSection({
    super.key,
    required this.riwayat,
    required this.isLoading,
    required this.onLihatSemua,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 12),
        _body(),
      ],
    );
  }

  Widget _header() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          GestureDetector(
            onTap: onLihatSemua,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      );

  Widget _body() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(
            color: AppColors.primary, strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (riwayat.isEmpty) return const _EmptyRiwayat();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 16, offset: const Offset(0, 4),
          ),
        ],
      ),
      // Gunakan Column agar tidak conflict dengan SingleChildScrollView di parent
      child: Column(
        children: [
          for (int i = 0; i < riwayat.length; i++) ...[
            RiwayatTile(
              data: riwayat[i],
              index: i,
              formatRupiah: formatRupiah,
            ),
            if (i < riwayat.length - 1)
              const Divider(
                height: 1, indent: 64, endIndent: 16,
                color: Color(0xFFEEF2F7),
              ),
          ],
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// TILE SATU TRANSAKSI
////////////////////////////////////////////////////////////
class RiwayatTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final String Function(int) formatRupiah;

  const RiwayatTile({
    super.key,
    required this.data,
    required this.index,
    required this.formatRupiah,
  });

  static const _colors = [
    Color(0xFF1565C0),
    Color(0xFF00897B),
    Color(0xFF6949CD),
    Color(0xFFE65100),
    Color(0xFF00838F),
  ];

  String _formatWaktu(Timestamp? ts) {
  if (ts == null) return '-';

  try {
    return DateFormat('dd MMM, HH:mm', 'id_ID')
        .format(ts.toDate().toLocal());
  } catch (_) {
    return DateFormat('dd MMM, HH:mm')
        .format(ts.toDate().toLocal());
  }
}

  String _itemsLabel(List<dynamic> items) {
    if (items.isEmpty) return 'Tidak ada item';
    if (items.length == 1) return items[0]['name'] ?? 'Item';
    return '${items[0]['name'] ?? 'Item'} +${items.length - 1} lainnya';
  }

  @override
  Widget build(BuildContext context) {
    final items = data['items'] as List<dynamic>? ?? [];
    final total = data['total'] as int? ?? 0;
    final laba = data['totalLaba'] as int? ?? 0;
    final ts = data['createdAt'] as Timestamp?;
    final color = _colors[index % _colors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_bag_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _itemsLabel(items),
                  style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: AppColors.textGrey),
                    const SizedBox(width: 3),
                    Text(
                      _formatWaktu(ts),
                      style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3, height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.textGrey, shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${items.length} item',
                      style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiah(total),
                style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.arrow_upward_rounded,
                      size: 11, color: Color(0xFF00BFA5)),
                  const SizedBox(width: 2),
                  Text(
                    formatRupiah(laba),
                    style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: Color(0xFF00BFA5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// EMPTY STATE
////////////////////////////////////////////////////////////
class _EmptyRiwayat extends StatelessWidget {
  const _EmptyRiwayat();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 48, color: AppColors.textGrey.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 14, color: AppColors.textGrey, fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}