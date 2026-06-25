import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventify/models/kasir_model.dart';
import 'package:inventify/services/encryption_helper.dart';

class KasirService {
  KasirService._();
  static final KasirService instance = KasirService._();

  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  // ──────────────────────────────────────────────────────────
  // READ
  // ──────────────────────────────────────────────────────────
  Stream<List<KasirModel>> streamKasir() {
    final ownerUid = _auth.currentUser?.uid;
    if (ownerUid == null) return const Stream.empty();

    return _usersRef
        .where('role', isEqualTo: 'Kasir')
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => KasirModel.fromMap(doc.id, doc.data()))
            .toList());
  }

String _safeDecrypt(String encrypted) {
  if (encrypted.isEmpty) return encrypted;
  try {
    return EncryptionHelper.decrypt(encrypted);
  } catch (_) {
    return encrypted; // fallback untuk data lama (plain text)
  }
}

  // ──────────────────────────────────────────────────────────
  // CREATE — Password dienkripsi sebelum disimpan ke Firestore
  // ──────────────────────────────────────────────────────────
  Future<void> tambahKasir({
    required String nama,
    required String email,
    required String password,
    String namaToko  = '',
    String alamatToko = '',
  }) async {
    final owner = _auth.currentUser;
    if (owner == null) throw Exception('Sesi pemilik tidak ditemukan.');

    final ownerUid   = owner.uid;
    final ownerEmail = owner.email!;

    // Ambil password pemilik (terenkripsi) untuk re-login nanti
    final ownerDoc      = await _usersRef.doc(ownerUid).get();
    final ownerPassEnc  = ownerDoc.data()?['password'] as String? ?? '';
    final ownerPassword = _safeDecrypt(ownerPassEnc);

    // Buat akun kasir di Firebase Auth
    final cred     = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final kasirUid = cred.user!.uid;

    // Simpan ke Firestore — password dienkripsi dengan AES
    await _usersRef.doc(kasirUid).set({
      'nama'      : nama,
      'email'     : email,
      'password'  : EncryptionHelper.encrypt(password), // ← terenkripsi
      'role'      : 'Kasir',
      'ownerUid'  : ownerUid,
      'namaToko'  : namaToko,
      'alamatToko': alamatToko,
      'createdAt' : FieldValue.serverTimestamp(),
    });

    await cred.user!.sendEmailVerification();

    // Kembali login sebagai pemilik
    await _auth.signInWithEmailAndPassword(
      email   : ownerEmail,
      password: ownerPassword,
    );
  }

  // ──────────────────────────────────────────────────────────
  // DELETE — Dekripsi password kasir → login → hapus Auth → 
  //          login balik pemilik → hapus Firestore
  // ──────────────────────────────────────────────────────────
  Future<void> hapusKasir(String kasirUid) async {
    final owner = _auth.currentUser;
    if (owner == null) throw Exception('Sesi pemilik tidak ditemukan.');

    final ownerEmail = owner.email!;

    // Ambil password pemilik untuk re-login
    final ownerDoc      = await _usersRef.doc(owner.uid).get();
    final ownerPassEnc  = ownerDoc.data()?['password'] as String? ?? '';
    final ownerPassword = _safeDecrypt(ownerPassEnc);

    // Ambil data kasir
    final kasirDoc = await _usersRef.doc(kasirUid).get();
    if (!kasirDoc.exists) throw Exception('Data kasir tidak ditemukan.');

    final kasirEmail   = kasirDoc.data()?['email']    as String? ?? '';
    final kasirPassEnc = kasirDoc.data()?['password'] as String? ?? '';
    final kasirPassword = _safeDecrypt(kasirPassEnc); // ← dekripsi

    // Login sementara sebagai kasir
    final kasirCred = await _auth.signInWithEmailAndPassword(
      email   : kasirEmail,
      password: kasirPassword,
    );

    // Hapus akun Auth kasir
    await kasirCred.user!.delete();

    // Login kembali sebagai pemilik
    await _auth.signInWithEmailAndPassword(
      email   : ownerEmail,
      password: ownerPassword,
    );

    // Hapus dokumen Firestore kasir
    await _usersRef.doc(kasirUid).delete();
  }
}