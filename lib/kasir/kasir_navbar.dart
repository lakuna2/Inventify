// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:inventify/kasir/beranda/beranda_kasir.dart';
import 'package:inventify/kasir/produk.dart';
import 'package:inventify/kasir/profil.dart';
import 'package:inventify/kasir/riwayat.dart';
import 'package:inventify/kasir/transaksi.dart';
import 'package:inventify/theme.dart';

////////////////////////////////////////////////////////////
/// NAVBAR KASIR — Floating Center Button + Label
////////////////////////////////////////////////////////////
class BottomNavigationKasir extends StatefulWidget {
  const BottomNavigationKasir({super.key});

  @override
  State<BottomNavigationKasir> createState() => _BottomNavigationKasirState();
}

class _BottomNavigationKasirState extends State<BottomNavigationKasir> {
  int _selectedIndex = 0;
  int _berandaKey = 0; // Key untuk force rebuild Beranda
  int _profilKey = 0; // Key untuk force rebuild Profil

  List<Widget> get _pages => [
    Beranda(
      key: ValueKey(_berandaKey),
      onNavigate: (i) => setState(() => _selectedIndex = i),
    ),
    const Produk(),
    const Transaksi(),
    const Riwayat(),
    Profil(key: ValueKey(_profilKey)),
  ];

  @override
  Widget build(BuildContext context) {
    // Keyboard terbuka jika viewInsets.bottom > 0
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      // Wajib true agar body naik saat keyboard muncul
      resizeToAvoidBottomInset: true,
      extendBody: !keyboardOpen, // Matikan extendBody saat keyboard terbuka
      body: IndexedStack(index: _selectedIndex, children: _pages),

      // Sembunyikan FAB saat keyboard terbuka
      floatingActionButton: keyboardOpen
          ? null
          : _FloatingTransaksiButton(
              isSelected: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Sembunyikan navbar saat keyboard terbuka
      bottomNavigationBar: keyboardOpen
          ? null
          : _CustomNavBar(
              selectedIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  // Force rebuild Beranda saat tab Beranda dipilih
                  if (index == 0) _berandaKey++;
                  // Force rebuild Profil saat tab Profil dipilih
                  if (index == 4) _profilKey++;
                });
              },
            ),
    );
  }
}

////////////////////////////////////////////////////////////
/// FLOATING TRANSAKSI BUTTON (FAB)
////////////////////////////////////////////////////////////
class _FloatingTransaksiButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _FloatingTransaksiButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [const Color(0xFF1A237E), const Color(0xFF00ACC1)]
                : [const Color(0xFF1565C0), const Color(0xFF26C6DA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isSelected ? 0.45 : 0.28),
              blurRadius: isSelected ? 18 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.point_of_sale_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// BOTTOM NAVBAR — Stack: BottomAppBar + label "Transaksi"
////////////////////////////////////////////////////////////
class _CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _CustomNavBar({required this.selectedIndex, required this.onTap});

  int _toPageIndex(int navSlot) => navSlot >= 2 ? navSlot + 1 : navSlot;

  @override
  Widget build(BuildContext context) {
    int navSelected = selectedIndex;
    if (selectedIndex > 2) navSelected = selectedIndex - 1;
    if (selectedIndex == 2) navSelected = -1;

    final bool transaksiActive = selectedIndex == 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ── BottomAppBar dengan notch ──────────────────────
        BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.white,
          elevation: 12,
          shadowColor: AppColors.primary.withOpacity(0.15),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  isSelected: navSelected == 0,
                  onTap: () => onTap(_toPageIndex(0)),
                ),
                _NavItem(
                  icon: Icons.store_rounded,
                  label: 'Produk',
                  isSelected: navSelected == 1,
                  onTap: () => onTap(_toPageIndex(1)),
                ),

                // Ruang kosong untuk FAB + label di bawahnya
                const SizedBox(width: 72),

                _NavItem(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  isSelected: navSelected == 2,
                  onTap: () => onTap(_toPageIndex(2)),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  isSelected: navSelected == 3,
                  onTap: () => onTap(_toPageIndex(3)),
                ),
              ],
            ),
          ),
        ),

        // ── Label "Transaksi" di bawah FAB ────────────────
        Positioned(
          bottom: 6,
          child: GestureDetector(
            onTap: () => onTap(2),
            behavior: HitTestBehavior.translucent,
            child: SizedBox(
              height: 25,
              width: 72,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: transaksiActive
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: transaksiActive
                      ? AppColors.primary
                      : AppColors.textGrey,
                ),
                child: const Text('Transaksi', textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
      ],
    );
  }
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
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
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
      ),
    );
  }
}