// lib/models/kasir_model.dart

class KasirModel {
  final String uid;
  final String nama;
  final String email;
  final String role;

  const KasirModel({
    required this.uid,
    required this.nama,
    required this.email,
    this.role = 'Kasir',
  });

  // ── Dari Firestore document ──
  factory KasirModel.fromMap(String uid, Map<String, dynamic> map) {
    return KasirModel(
      uid: uid,
      nama: map['nama'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'Kasir',
    );
  }

  // ── Ke Firestore document ──
  Map<String, dynamic> toMap() => {
        'nama': nama,
        'email': email,
        'role': role,
      };

  // ── Inisial untuk avatar (maks. 2 huruf) ──
  String get initials {
    final parts = nama.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }
}