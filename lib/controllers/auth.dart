import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventify/services/encryption_helper.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> regis(
    String nama,
    String email,
    String password,
    String role,
    String namaToko,
    String alamatToko,
  ) async {
    UserCredential? userCredential;

    try {
      // 1. Buat akun
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Simpan ke Firestore DULU sebelum kirim verifikasi
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'nama': nama,
            'email': email,
            'password': EncryptionHelper.encrypt(password),
            'role': role,
            'namaToko': namaToko,
            'alamatToko': alamatToko,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // 3. Baru kirim verifikasi email
      await userCredential.user!.sendEmailVerification();

      // 4. Sign out — user harus verifikasi dulu
      await _auth.signOut();
    } catch (e) {
      // ✅ Rollback — hapus akun Auth jika ada yang gagal
      if (userCredential != null) {
        await userCredential.user!.delete();
      }
      rethrow;
    }
  }

  Future<void> masuk(String email, String password) async {
    try {
      // 1. Login Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Cek email sudah diverifikasi
      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();

        throw FirebaseAuthException(code: 'email-not-verified');
      }

      // 2. Ambil data user dari Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // 3. Cek apakah dokumen user ada
      if (!userDoc.exists) {
        throw Exception('Data pengguna tidak ditemukan di database.');
      }

      // 4. Auto-migrate password plain text → enkripsi
      final data = userDoc.data() as Map<String, dynamic>;
      final storedPass = data['password'] as String? ?? '';

      bool isEncrypted = true;
      try {
        EncryptionHelper.decrypt(storedPass);
      } catch (_) {
        isEncrypted = false;
      }

      if (!isEncrypted) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'password': EncryptionHelper.encrypt(password)});
      }
      
    } catch (e) {
      rethrow; // Biarkan error dilempar ke UI untuk ditangani
    }
  }
}
