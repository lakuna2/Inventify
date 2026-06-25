import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/kasir/kasir_navbar.dart';
import 'package:inventify/owner/owner_navbar.dart';
import 'package:inventify/pages/masuk.dart';
import 'package:inventify/theme.dart';

/// AuthWrapper untuk mengecek status login dan mengarahkan ke halaman yang sesuai
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getInitialPage() async {
    final user = FirebaseAuth.instance.currentUser;

    // Jika tidak ada user yang login, ke halaman login
    if (user == null) {
      return const MasukPage();
    }

    // Jika ada user, cek role dari Firestore
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        // Jika data tidak ada, logout dan ke halaman login
        await FirebaseAuth.instance.signOut();
        return const MasukPage();
      }

      final role = (doc.data()!['role'] ?? '').toString().toLowerCase().trim();

      // Arahkan ke halaman sesuai role
      if (role == 'kasir') {
        return const BottomNavigationKasir();
      } else if (role == 'pemilik') {
        return const OwnerBottomNavbar();
      } else {
        // Role tidak dikenali, logout dan ke halaman login
        await FirebaseAuth.instance.signOut();
        return const MasukPage();
      }
    } catch (e) {
      // Jika ada error, logout dan ke halaman login
      await FirebaseAuth.instance.signOut();
      return const MasukPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialPage(),
      builder: (context, snapshot) {
        // Tampilkan loading saat mengecek status login
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        // Tampilkan halaman yang sesuai
        return snapshot.data ?? const MasukPage();
      },
    );
  }
}