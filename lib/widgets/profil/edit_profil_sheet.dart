import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/widgets/profil/all_sheets.dart';
import 'package:inventify/theme.dart';

class EditProfilSheet {
  static void show(BuildContext context, {required Map<String, dynamic> user}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfilContent(user: user),
    );
  }
}

class _EditProfilContent extends StatefulWidget {
  final Map<String, dynamic> user;
  const _EditProfilContent({required this.user});
  @override
  State<_EditProfilContent> createState() => _EditProfilContentState();
}

class _EditProfilContentState extends State<_EditProfilContent> {
  late final _namaCtrl = TextEditingController(text: widget.user['nama'] ?? '');
  late final _emailCtrl = TextEditingController(
    text: widget.user['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '');
  late final _telpCtrl = TextEditingController(text: widget.user['telepon'] ?? '');
  bool _loading = false;

  Future<void> _simpan() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _namaCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'nama': _namaCtrl.text.trim(),
        'telepon': _telpCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Color(0xFF1D9E75)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.habis));
      }
    }
  }

  @override
  void dispose() { _namaCtrl.dispose(); _emailCtrl.dispose(); _telpCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SheetContainer(
        title: 'Edit Profil',
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Avatar besar dengan tombol ganti
          Center(child: Stack(children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEEEDFE),
                border: Border.all(color: const Color(0xFF7F77DD), width: 2),
              ),
              child: Center(child: Text(
                _namaCtrl.text.isNotEmpty ? _namaCtrl.text[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF3C3489)))),
            ),
            Positioned(bottom: 0, right: 0,
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF7F77DD), shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
              )),
          ])),
          const SizedBox(height: 20),

          _field(_namaCtrl, 'Nama Lengkap', Icons.person_outline_rounded),
          const SizedBox(height: 10),
          _field(_emailCtrl, 'Email', Icons.email_outlined, enabled: false,
            hint: 'Email tidak dapat diubah'),
          const SizedBox(height: 10),
          _field(_telpCtrl, 'Nomor Telepon', Icons.phone_outlined, numeric: true),
          const SizedBox(height: 20),

          ActionRow(loading: _loading, onCancel: () => Navigator.pop(context), onSubmit: _simpan),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool numeric = false, bool enabled = true, String? hint}) {
    return TextField(
      controller: c,
      enabled: enabled,
      keyboardType: numeric ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: enabled ? AppColors.secondary : AppColors.textGrey),
        filled: true,
        fillColor: enabled ? AppColors.background : AppColors.background.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary)),
      ),
    );
  }
}