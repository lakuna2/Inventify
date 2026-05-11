// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:inventify/owner/owner_beranda.dart';
import 'package:inventify/owner/owner_histori.dart';
import 'package:inventify/owner/owner_laporan.dart';
import 'package:inventify/owner/owner_pengaturan.dart';
import 'package:inventify/theme.dart';

////////////////////////////////////////////////////////////
/// NAVBAR OWNER — Custom Style (sama dengan kasir, tanpa floating)
////////////////////////////////////////////////////////////
class OwnerBottomNavbar extends StatefulWidget {
  const OwnerBottomNavbar({super.key});

  @override
  State<OwnerBottomNavbar> createState() => _OwnerBottomNavbarState();
}

class _OwnerBottomNavbarState extends State<OwnerBottomNavbar> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      OwnerDashboard(onNavigate: (index) => setState(() => _selectedIndex = index)),
      const OwnerHistori(),
      const OwnerLaporan(),
      const OwnerPengaturan(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _OwnerNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// CUSTOM NAVBAR OWNER
////////////////////////////////////////////////////////////
class _OwnerNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _OwnerNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      _NavItemData(icon: Icons.receipt_long_rounded, label: 'Histori'),
      _NavItemData(icon: Icons.bar_chart_rounded, label: 'Laporan'),
      _NavItemData(icon: Icons.settings_rounded, label: 'Pengaturan'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              return Expanded(
                child: _NavItem(
                  icon: items[i].icon,
                  label: items[i].label,
                  isSelected: selectedIndex == i,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}

////////////////////////////////////////////////////////////
/// NAV ITEM
////////////////////////////////////////////////////////////
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textGrey;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}