// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

////////////////////////////////////////////////////////////
/// AKSES CEPAT
////////////////////////////////////////////////////////////
class AksesCepat extends StatelessWidget {
  const AksesCepat({super.key, required this.onNavigate});
  final void Function(int) onNavigate;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickItem(
        icon: Icons.point_of_sale_rounded,
        label: 'Transaksi',
        gradientColors: const [Color(0xFF1565C0), Color(0xFF00ACC1)],
        shadowColor: const Color(0xFF1565C0),
        onTap: () => onNavigate(2),
      ),
      _QuickItem(
        icon: Icons.store_rounded,
        label: 'Produk',
        gradientColors: const [Color(0xFF00897B), Color(0xFF4DB6AC)],
        shadowColor: const Color(0xFF00897B),
        onTap: () => onNavigate(1),
      ),
      _QuickItem(
        icon: Icons.history_rounded,
        label: 'Riwayat',
        gradientColors: const [Color(0xFF6949CD), Color(0xFF9C82E0)],
        shadowColor: const Color(0xFF6949CD),
        onTap: () => onNavigate(3),
      ),
      _QuickItem(
        icon: Icons.person_rounded,
        label: 'Profil',
        gradientColors: const [Color(0xFFE65100), Color(0xFFFF8A65)],
        shadowColor: const Color(0xFFE65100),
        onTap: () => onNavigate(4),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Akses Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((item) => _buildItem(item)).toList(),
        ),
      ],
    );
  }

  Widget _buildItem(_QuickItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: item.shadowColor.withOpacity(0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _QuickItem({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.shadowColor,
    required this.onTap,
  });
}
