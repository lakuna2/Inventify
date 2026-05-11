import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/theme.dart';
import 'package:inventify/widgets/profil/all_sheets.dart';
import 'package:inventify/widgets/profil/profil_header.dart';
import 'package:inventify/widgets/profil/profil_menu_section.dart';
import 'package:inventify/widgets/profil/edit_profil_sheet.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

  Future<Map<String, dynamic>> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data() ?? {};
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        content: const Text(
          'Kamu akan keluar dari akun ini.',
          style: TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.habis,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadUserData(),
          builder: (context, snap) {
            final user = snap.data ?? {};
            final nama =
                user['nama'] ??
                FirebaseAuth.instance.currentUser?.displayName ??
                'Kasir';
            final email =
                user['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
            final joinDate =
                (user['createdAt'] as dynamic)?.toDate() as DateTime?;

            return ListView(
              children: [
                // Header profil + statistik
                ProfilHeader(nama: nama, email: email, joinDate: joinDate),
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
                            onTap: () =>
                                EditProfilSheet.show(context, user: user),
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

                      // Seksi Preferensi
                      ProfilMenuSection(
                        label: 'Preferensi',
                        items: [
                          ProfilMenuItem(
                            icon: Icons.notifications_none_rounded,
                            iconBg: const Color(0xFFFAEEDA),
                            iconColor: const Color(0xFF633806),
                            title: 'Notifikasi',
                            subtitle: 'Stok tipis & peringatan',
                            badge: '3',
                            onTap: () => NotifikasiSheet.show(context),
                          ),
                          ProfilMenuItem(
                            icon: Icons.language_rounded,
                            iconBg: const Color(0xFFF1EFE8),
                            iconColor: const Color(0xFF444441),
                            title: 'Bahasa',
                            subtitle: 'Indonesia',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Seksi Lainnya
                      ProfilMenuSection(
                        label: 'Lainnya',
                        items: [
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

                      // Tombol Keluar
                      _LogoutButton(onTap: () => _logout(context)),
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

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.habis.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.habis.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.habis.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.habis,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.habis,
                  ),
                ),
                Text(
                  'Logout dari akun ini',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.habis.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
