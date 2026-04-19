import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> regis(String nama, String email, String password, String role) async {
    try {
      // 1. Buat akun baru di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Simpan data user ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'nama': nama,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow; // Biarkan error dilempar ke UI untuk ditangani
    }
  }

  Future<void> masuk(String email, String password) async {
    try {
      // 1. Login Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Ambil data user dari Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // 3. Cek apakah dokumen user ada
      if (!userDoc.exists) {
        throw Exception('Data pengguna tidak ditemukan di database.');
      }

      // 4. Ambil role dengan aman
      String role = (userDoc['role'] ?? '').toString().toLowerCase();

      // 5. Navigasi berdasarkan role
      switch (role) {
        case 'owner':
          // Navigasi ke dashboard owner
          break;
        case 'kasir':
          // Navigasi ke dashboard kasir
          break;
        default:
          throw Exception('Role pengguna tidak dikenali.');
      }
    } catch (e) {
      rethrow; // Biarkan error dilempar ke UI untuk ditangani
    }
  }
}