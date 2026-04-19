import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

// Pages
import 'package:inventify/pages/splash.dart';
import 'package:inventify/pages/masuk.dart';

// Kasir
import 'package:inventify/kasir/kasir_beranda.dart';
import 'package:inventify/kasir/produk.dart';
import 'package:inventify/kasir/profil.dart';
import 'package:inventify/kasir/riwayat.dart';
import 'package:inventify/kasir/transaksi.dart';

// Owner
import 'package:inventify/pemilik/owner_beranda.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

////////////////////////////////////////////////////////////
/// APP ROOT
////////////////////////////////////////////////////////////
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashGate(),
    );
  }
}

////////////////////////////////////////////////////////////
/// SPLASH GATE
/// Menampilkan SplashScreen selama durasi minimum,
/// lalu baru mengecek status auth — sehingga splash
/// selalu berjalan penuh dan tidak stuck.
////////////////////////////////////////////////////////////
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    // Tunggu splash selesai (misal 2 detik), baru lanjut ke auth
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) return const SplashScreen();
    return const AuthWrapper();
  }
}

////////////////////////////////////////////////////////////
/// AUTH WRAPPER
/// Hanya dijalankan SETELAH splash selesai.
/// StreamBuilder di sini tidak akan menyebabkan splash
/// muncul lagi karena SplashGate sudah melewatinya.
////////////////////////////////////////////////////////////
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Masih menunggu status auth dari Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Belum login → ke halaman masuk
        if (!snapshot.hasData || snapshot.data == null) {
          return const MasukPage();
        }

        // Sudah login → cek role dari Firestore
        return RoleChecker(uid: snapshot.data!.uid);
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// ROLE CHECKER
/// Menggunakan uid yang sudah pasti ada (diteruskan dari
/// AuthWrapper), dengan error handling yang benar.
////////////////////////////////////////////////////////////
class RoleChecker extends StatelessWidget {
  final String uid;
  const RoleChecker({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(),
      builder: (context, snapshot) {

        // Menunggu data Firestore
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error saat mengambil data
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat data pengguna.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text('Kembali ke Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = (data['role'] ?? '').toString().toLowerCase().trim();

        if (role == 'kasir') {
          return const BottomNavigationKasir();
        } else if (role == 'pemilik') {
          return const OwnerBottomNavbar();
        }

        // Role tidak dikenali
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Role "$role" tidak dikenali.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text('Keluar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// NAVBAR KASIR
////////////////////////////////////////////////////////////
class BottomNavigationKasir extends StatefulWidget {
  const BottomNavigationKasir({super.key});

  @override
  State<BottomNavigationKasir> createState() => _BottomNavigationKasirState();
}

class _BottomNavigationKasirState extends State<BottomNavigationKasir> {
  int _selectedIndex = 0;

  // Gunakan IndexedStack agar state halaman tidak hilang
  // saat berpindah tab (scroll position, form input, dll)
  final List<Widget> _pages = const [
    Beranda(),
    Produk(),
    ScanPage(),
    Riwayat(),
    Profil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mempertahankan state semua halaman
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// NAVBAR OWNER
////////////////////////////////////////////////////////////
class OwnerBottomNavbar extends StatefulWidget {
  const OwnerBottomNavbar({super.key});

  @override
  State<OwnerBottomNavbar> createState() => _OwnerBottomNavbarState();
}

class _OwnerBottomNavbarState extends State<OwnerBottomNavbar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    OwnerDashboard(),
    Center(child: Text('Histori')),
    Center(child: Text('Laporan')),
    Center(child: Text('Pengaturan')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Histori'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}