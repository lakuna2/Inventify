// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

////////////////////////////////////////////////////////////
/// TOTAL CARD
////////////////////////////////////////////////////////////
class TotalCard extends StatelessWidget {
  final int totalPenjualan;
  final int totalLaba;
  final int jumlahTransaksi;
  final bool isHidden;
  final bool isLoading;
  final VoidCallback onToggle;
  final String Function(int) formatRupiah;

  const TotalCard({
    super.key,
    required this.totalPenjualan,
    required this.totalLaba,
    required this.jumlahTransaksi,
    required this.isHidden,
    required this.isLoading,
    required this.onToggle,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.10),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isLoading
          ? const SizedBox(
              height: 80,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2.5,
                ),
              ),
            )
          : _content(),
    );
  }

  Widget _content() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Penjualan Hari Ini',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13, fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  isHidden
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.textSecondary, size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isHidden ? '••••••••' : formatRupiah(totalPenjualan),
              key: ValueKey(isHidden),
              style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800,
                color: AppColors.textDark, letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFEEF2F7)),
          const SizedBox(height: 12),
          Row(
            children: [
              StatChip(
                icon: Icons.receipt_long_rounded,
                label: '$jumlahTransaksi Transaksi',
                color: AppColors.accent,
              ),
              const SizedBox(width: 10),
              StatChip(
                icon: Icons.trending_up_rounded,
                label: isHidden ? 'Laba ••••' : 'Laba ${formatRupiah(totalLaba)}',
                color: const Color(0xFF00BFA5),
              ),
            ],
          ),
        ],
      );
}

class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w600, color: color,
            ),
          ),
        ],
      ),
    );
  }
}