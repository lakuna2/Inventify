// ignore_for_file: use_build_context_synchronously

import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/pages/masuk.dart';
import 'package:inventify/theme.dart';
import 'package:inventify/widgets/profil/all_sheets.dart';
import 'package:inventify/widgets/profil/printer_setup_sheet.dart';
import 'package:inventify/widgets/profil/profil_header.dart';
import 'package:inventify/widgets/profil/profil_menu_section.dart';
import 'package:inventify/widgets/profil/edit_profil_sheet.dart';
import 'package:inventify/services/printer_service.dart';
import 'package:inventify/services/user_service.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final _printer = PrinterService();
  final _userService = UserService();
  Map<String, int>? _stats;
  int _refreshKey = 0; // Key untuk force refresh

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _userService.getKasirStats();
    if (mounted) {
      setState(() => _stats = stats);
    }
  }

  Future<Map<String, dynamic>> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }

  Future<void> _logout(BuildContext context) async {
    CustomQuickAlert.confirm(
      title: 'Konfirmasi Logout',
      message: 'Yakin ingin Logout?',
      confirmBtnColor: AppColors.primary,
      onConfirm: () async {
        try {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Berhasil logout!'),
                backgroundColor: Color(0xFF1D9E75),
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MasukPage()),
              (route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal logout: $e'),
                backgroundColor: AppColors.habis,
              ),
            );
          }
        }
      },
    );
  }

  // Buka sheet printer dan rebuild setelah kembali agar status terupdate
  Future<void> _bukaSheetPrinter(BuildContext context) async {
    await PrinterSetupSheet.show(context);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          key: ValueKey(_refreshKey), // Force rebuild with refresh key
          future: _loadUserData(),
          builder: (context, snap) {
            // Tampilkan loading saat masih fetch data
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handle error
            if (snap.hasError) {
              return Center(
                child: Text('Error: ${snap.error}'),
              );
            }

            final user = snap.data ?? {};
            final nama = user['nama'] ??
                FirebaseAuth.instance.currentUser?.displayName ??
                'Kasir';
            final email = user['email'] ??
                FirebaseAuth.instance.currentUser?.email ??
                '';
            final joinDate =
                (user['createdAt'] as dynamic)?.toDate() as DateTime?;
            final avatar = user['avatar'] as String?;

            return ListView(
              children: [
                ProfilHeader(
                  nama: nama,
                  email: email,
                  joinDate: joinDate,
                  stats: _stats,
                  avatar: avatar,
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      // Seksi Akun
                      ProfilMenuSection(
                        label: 'Akun',
                        items: [
                          ProfilMenuItem(
                            icon: Icons.person_outline_rounded,
                            iconBg: const Color(0xFFEEEDFE),
                            iconColor: const Color(0xFF3C3489),
                            title: 'Edit Profil',
                            subtitle: 'Nama, email, foto',
                            onTap: () async {
                              // Tunggu sheet selesai dan cek hasilnya
                              final result = await EditProfilSheet.show(context, user: user);
                              // Jika berhasil (result == true), langsung refresh
                              if (result == true && mounted) {
                                setState(() {
                                  _refreshKey++;
                                });
                              }
                            },
                          ),
                          ProfilMenuItem(
                            icon: Icons.lock_outline_rounded,
                            iconBg: const Color(0xFFE1F5EE),
                            iconColor: const Color(0xFF085041),
                            title: 'Ubah Password',
                            subtitle: 'Keamanan akun',
                            onTap: () => UbahPasswordSheet.show(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Seksi Lainnya
                      ProfilMenuSection(
                        label: 'Lainnya',
                        items: [
                          // ── PRINTER BLUETOOTH ──
                          ProfilMenuItem(
                            icon: Icons.print_rounded,
                            iconBg: const Color(0xFFE6F1FB),
                            iconColor: const Color(0xFF185FA5),
                            title: 'Printer Bluetooth',
                            subtitle: _printer.isConnected
                                ? 'Terhubung: ${_printer.connectedDeviceName}'
                                : 'Belum terhubung — tap untuk setup',
                            badge: _printer.isConnected ? null : '!',
                            badgeColor: _printer.isConnected
                                ? null
                                : AppColors.stokTipis,
                            onTap: () => _bukaSheetPrinter(context),
                          ),
                          ProfilMenuItem(
                            icon: Icons.info_outline_rounded,
                            iconBg: const Color(0xFFFCEBEB),
                            iconColor: const Color(0xFF791F1F),
                            title: 'Tentang Aplikasi',
                            subtitle: 'Versi 1.0.0',
                            onTap: () => TentangSheet.show(context),
                          ),
                          ProfilMenuItem(
                            icon: Icons.help_outline_rounded,
                            iconBg: const Color(0xFFF1EFE8),
                            iconColor: const Color(0xFF444441),
                            title: 'Bantuan & FAQ',
                            subtitle: 'Panduan penggunaan',
                            onTap: () => BantuanSheet.show(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout_rounded, size: 17),
                          label: const Text(
                            'Keluar dari Akun',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: AppColors.habis,
                            side: const BorderSide(color: AppColors.habis),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}