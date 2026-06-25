import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/widgets/profil/all_sheets.dart';
import 'package:inventify/widgets/profil/avatar_picker_sheet.dart';
import 'package:inventify/theme.dart';
import 'package:inventify/services/user_service.dart';

class EditProfilSheet {
  static Future<bool?> show(
    BuildContext context, {
    required Map<String, dynamic> user,
  }) {
    return showModalBottomSheet<bool>(
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
  String? _selectedAvatar;
  // ignore: unused_field
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.user['avatar'] as String?;
  }

  Future<void> _pilihAvatar() async {
    final result = await AvatarPickerSheet.show(context, currentAvatar: _selectedAvatar);
    if (result != null && mounted) {
      setState(() => _selectedAvatar = result);
    }
  }

  Future<void> _simpan() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _namaCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final updateData = <String, dynamic>{
        'nama': _namaCtrl.text.trim(),
        'telepon': _telpCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (_selectedAvatar != null) {
        updateData['avatar'] = _selectedAvatar!;
      }
      
      await FirebaseFirestore.instance.collection('users').doc(uid).update(updateData);
      if (mounted) {
        Navigator.pop(context, true); // Return true untuk signal berhasil
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
          Center(
            child: Column(
              children: [
                InkWell(
                  onTap: _pilihAvatar,
                  borderRadius: BorderRadius.circular(50),
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEEEDFE),
                          border: Border.all(color: const Color(0xFF7F77DD), width: 2),
                        ),
                        child: _selectedAvatar != null
                            ? ClipOval(
                                child: Image.asset(
                                  'assets/avatar/$_selectedAvatar',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  _namaCtrl.text.isNotEmpty
                                      ? _namaCtrl.text[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3C3489)),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F77DD),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap untuk pilih avatar',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
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