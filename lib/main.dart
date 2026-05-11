import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';

// Pages
import 'package:inventify/pages/splash.dart';
import 'package:inventify/pages/masuk.dart';

// Kasir Navbar (custom floating button)
import 'package:inventify/kasir/kasir_navbar.dart';

// Owner Navbar (custom style, tanpa floating)
import 'package:inventify/owner/owner_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
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
////////////////////////////////////////////////////////////
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const MasukPage();
        }
        return RoleChecker(uid: snapshot.data!.uid);
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// ROLE CHECKER
////////////////////////////////////////////////////////////
class RoleChecker extends StatelessWidget {
  final String uid;
  const RoleChecker({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat data pengguna.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async => FirebaseAuth.instance.signOut(),
                    child: const Text('Kembali ke Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = (data['role'] ?? '').toString().toLowerCase().trim();

        if (role == 'kasir') return const BottomNavigationKasir();
        if (role == 'pemilik') return const OwnerBottomNavbar();

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Role "$role" tidak dikenali.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async => FirebaseAuth.instance.signOut(),
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
