// lib/pages/owner/kasir/widgets/tambah_kasir_sheet.dart

import 'package:flutter/material.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:inventify/services/kasir_services.dart';
import 'package:inventify/theme.dart';
import 'package:inventify/widgets/owner/kelola_kasir/kasir_shared_widget.dart';

class TambahKasirSheet extends StatefulWidget {
  const TambahKasirSheet({super.key});

  @override
  State<TambahKasirSheet> createState() => _TambahKasirSheetState();
}

class _TambahKasirSheetState extends State<TambahKasirSheet> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();

  bool _showPassword = false;
  bool _showKonfirmasi = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTambah() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await KasirService.instance.tambahKasir(
        nama: _namaCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (mounted) Navigator.pop(context);

      CustomQuickAlert.success(
        title: 'Kasir Ditambahkan!',
        message:
            'Akun kasir berhasil dibuat.\nLink verifikasi telah dikirim ke email kasir.',
        confirmBtnColor: AppColors.primary,
      );
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      CustomQuickAlert.error(
        title: 'Gagal Menambahkan Kasir',
        message: e.toString(),
        confirmText: 'Coba Lagi',
        confirmBtnColor: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const KasirSheetHandle(),
                  const SizedBox(height: 12),
                  _buildTitle(),
                  const SizedBox(height: 4),
                  const Text(
                    'Isi data di bawah untuk membuat akun kasir baru.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  const KasirSectionLabel(label: 'Informasi Akun'),
                  const SizedBox(height: 10),
                  _KasirTextField(
                    controller: _namaCtrl,
                    hint: 'Nama Kasir',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama kasir tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _KasirTextField(
                    controller: _emailCtrl,
                    hint: 'E-mail',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const KasirSectionLabel(label: 'Keamanan'),
                  const SizedBox(height: 10),
                  _KasirTextField(
                    controller: _passwordCtrl,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: !_showPassword,
                    suffixIcon: _VisibilityToggle(
                      visible: _showPassword,
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (v.length < 6) return 'Minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _KasirTextField(
                    controller: _konfirmasiCtrl,
                    hint: 'Konfirmasi Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: !_showKonfirmasi,
                    suffixIcon: _VisibilityToggle(
                      visible: _showKonfirmasi,
                      onPressed: () =>
                          setState(() => _showKonfirmasi = !_showKonfirmasi),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Konfirmasi password';
                      if (v != _passwordCtrl.text) return 'Password tidak sama';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _TambahButton(
                    isLoading: _isLoading,
                    onPressed: _handleTambah,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        const Text(
          'Tambah Kasir',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        const KasirRoleBadge(),
      ],
    );
  }
}

// ── TextField khusus form kasir ──
class _KasirTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _KasirTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}

// ── Toggle ikon tampilkan / sembunyikan password ──
class _VisibilityToggle extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;

  const _VisibilityToggle({required this.visible, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onPressed: onPressed,
    );
  }
}

// ── Tombol submit tambah kasir ──
class _TambahButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _TambahButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.buttonDisabled,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Kasir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}