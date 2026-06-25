import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

class ProfilMenuItem {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final String? badge;
  final Color? badgeColor; // opsional, default AppColors.habis
  final VoidCallback onTap;

  const ProfilMenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });
}

class ProfilMenuSection extends StatelessWidget {
  final String label;
  final List<ProfilMenuItem> items;
  const ProfilMenuSection(
      {super.key, required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey.withValues(alpha: 0.7),
              letterSpacing: 0.6),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.textGrey.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            return Column(children: [
              if (i > 0)
                Divider(
                    height: 1,
                    indent: 60,
                    color: AppColors.textGrey.withValues(alpha: 0.1)),
              _MenuTile(item: item),
            ]);
          }).toList(),
        ),
      ),
    ]);
  }
}

class _MenuTile extends StatelessWidget {
  final ProfilMenuItem item;
  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          // Icon
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, color: item.iconColor, size: 19),
          ),
          const SizedBox(width: 12),

          // Teks
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text(item.subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark.withValues(alpha: 0.45))),
            ]),
          ),

          // Badge
          if (item.badge != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: item.badgeColor ?? AppColors.habis,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(item.badge!,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            const SizedBox(width: 6),
          ],

          Icon(Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textGrey.withValues(alpha: 0.5)),
        ]),
      ),
    );
  }
}