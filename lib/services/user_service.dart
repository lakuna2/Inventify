import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service untuk operasi terkait user/kasir
class UserService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Mendapatkan nama kasir yang sedang login
  Future<String> getNamaKasir() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'Kasir';

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['nama'] ?? 'Kasir';
    } catch (e) {
      return 'Kasir';
    }
  }

  /// Mendapatkan data user lengkap
  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Mendapatkan UID user yang sedang login
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Check apakah user sudah login
  bool get isLoggedIn => _auth.currentUser != null;

  /// Update avatar user
  Future<bool> updateAvatar(String avatarFileName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      await _firestore.collection('users').doc(uid).update({
        'avatar': avatarFileName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get avatar user saat ini
  Future<String?> getCurrentAvatar() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['avatar'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Mendapatkan statistik kasir (transaksi, produk input, hari aktif)
  Future<Map<String, int>> getKasirStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return {'transaksi': 0, 'produkInput': 0, 'hariAktif': 0};
    }

    try {
      final userData = await _firestore.collection('users').doc(uid).get();
      final namaKasir = userData.data()?['nama'] ?? '';

      // Hitung total transaksi oleh kasir ini
      final transaksiSnap = await _firestore
          .collection('transaksi')
          .where('kasir', isEqualTo: namaKasir)
          .get();
      final totalTransaksi = transaksiSnap.docs.length;

      // Debug: cek semua transaksi
      final allTransaksi = await _firestore.collection('transaksi').get();
      if (allTransaksi.docs.isNotEmpty) {
      }

      // Hitung produk yang di-input oleh kasir ini
      // Karena produk tidak menyimpan createdBy, kita hitung semua produk
      final produkSnap = await _firestore.collection('produk').get();
      final totalProduk = produkSnap.docs.length;

      // Hitung hari aktif (hari unik dimana kasir melakukan transaksi)
      final hariSet = <String>{};
      for (final doc in transaksiSnap.docs) {
        final data = doc.data();
        final timestamp = data['createdAt'];
        if (timestamp != null) {
          try {
            final date = (timestamp as Timestamp).toDate();
            hariSet.add('${date.year}-${date.month}-${date.day}');
          // ignore: empty_catches
          } catch (e) {
          }
        }
      }
      final hariAktif = hariSet.length;

      return {
        'transaksi': totalTransaksi,
        'produkInput': totalProduk,
        'hariAktif': hariAktif,
      };
    } catch (e) {
      return {'transaksi': 0, 'produkInput': 0, 'hariAktif': 0};
    }
  }
}
