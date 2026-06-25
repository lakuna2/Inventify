// lib/pages/owner/kasir/widgets/kasir_shared_widgets.dart

import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

// ── Handle garis abu di atas bottom sheet ──
class KasirSheetHandle extends StatelessWidget {
  const KasirSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// ── Label section dengan garis vertikal di kiri ──
class KasirSectionLabel extends StatelessWidget {
  final String label;
  const KasirSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Badge "Kasir" di pojok kanan ──
class KasirRoleBadge extends StatelessWidget {
  const KasirRoleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.badge_rounded, size: 14, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            'Kasir',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar inisial dengan warna otomatis ──
class KasirAvatar extends StatelessWidget {
  final String initials;
  const KasirAvatar({super.key, required this.initials});

  static const _palette = [
    Color(0xFF6C63FF),
    Color(0xFF43B97F),
    Color(0xFFE05C5C),
    Color(0xFFF4A261),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
  ];

  Color get _color => _palette[initials.codeUnitAt(0) % _palette.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: _color,
        ),
      ),
    );
  }
}

// ── Tile aksi di dalam bottom sheet (hapus, batal, dsb.) ──
class KasirActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const KasirActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}