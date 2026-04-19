import 'package:flutter/material.dart';
import 'package:splash_master/core/splash_master.dart';
import 'package:inventify/splash.dart';

// Kasir Pages
import 'package:inventify/kasir/kasir_beranda.dart';
import 'package:inventify/kasir/produk.dart';
import 'package:inventify/kasir/profil.dart';
import 'package:inventify/kasir/riwayat.dart';
import 'package:inventify/kasir/transaksi.dart';

// Owner Pages
import 'package:inventify/pemilik/owner_beranda.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SplashMaster.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

////////////////////////////////////////////////////////////
/// NAVBAR KASIR
////////////////////////////////////////////////////////////
class BottomNavigationKasir extends StatefulWidget {
  const BottomNavigationKasir({super.key});

  @override
  State<BottomNavigationKasir> createState() =>
      _BottomNavigationKasirState();
}

class _BottomNavigationKasirState extends State<BottomNavigationKasir> {
  int _selectedIndex = 0;

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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
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
    Center(child: Text("Histori")),
    Center(child: Text("Laporan")),
    Center(child: Text("Pengaturan")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Histori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}