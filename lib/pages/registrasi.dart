// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:inventify/controllers/auth.dart';

// import 'package:inventify/pages/masuk.dart';
import 'package:inventify/theme.dart';
import 'package:inventify/widgets/auth_link.dart';

// ============================================================
// REGISTER PAGE
// ============================================================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();

  String? _selectedRole;
  bool _showPassword = false;
  bool _showKonfirmasi = false;
  bool _isLoading = false;

  final List<String> _roles = ['Kasir', 'Pemilik'];

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  // ── REGISTER HANDLER ──
void _handleRegister() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedRole == null) {
    _showSnackbar('Pilih jenis pengguna terlebih dahulu');
    return;
  }

  setState(() => _isLoading = true);

  try {
    await Auth().regis(
      _namaCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _selectedRole!,
    );
    _showSnackbar('Registrasi berhasil sebagai $_selectedRole!');
  } catch (e) {
    _showSnackbar('Registrasi gagal: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // ── Logo ──
                _buildLogo(),

                const SizedBox(height: 32),

                // ── Card Form ──
                _buildFormCard(),

                const SizedBox(height: 24),

                // ── Link Masuk ──
                AuthLink(mode: AuthMode.register),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // LOGO
  // ----------------------------------------------------------
  Widget _buildLogo() {
    return Image.asset(
      'assets/logo.jpg',
      width: 180,
    );
  }

  // ----------------------------------------------------------
  // FORM CARD
  // ----------------------------------------------------------
  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registrasi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          _buildDropdownRole(),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _namaCtrl,
            hint: 'Masukkan Nama',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _emailCtrl,
            hint: 'Masukkan Email',
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
          const SizedBox(height: 14),

          _buildTextField(
            controller: _passwordCtrl,
            hint: 'Masukkan Kata Sandi',
            icon: Icons.lock_outline_rounded,
            obscure: !_showPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _showPassword = !_showPassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Kata sandi tidak boleh kosong';
              }
              if (v.length < 6) return 'Minimal 6 karakter';
              return null;
            },
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _konfirmasiCtrl,
            hint: 'Konfirmasi Kata Sandi',
            icon: Icons.lock_outline_rounded,
            obscure: !_showKonfirmasi,
            suffixIcon: IconButton(
              icon: Icon(
                _showKonfirmasi
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _showKonfirmasi = !_showKonfirmasi),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Konfirmasi kata sandi';
              if (v != _passwordCtrl.text) return 'Kata sandi tidak sama';
              return null;
            },
          ),
          const SizedBox(height: 24),

          _buildRegisterButton(),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // DROPDOWN ROLE
  // ----------------------------------------------------------
  Widget _buildDropdownRole() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          hint: Row(
            children: [
              const Icon(Icons.badge_outlined,
                  color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 10),
              Text(
                'Jenis Pengguna',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: _roles
              .map((role) => DropdownMenuItem(
                    value: role,
                    child: Row(
                      children: [
                        const Icon(Icons.badge_outlined,
                            color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 10),
                        Text(role),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedRole = val),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TEXT FIELD
  // ----------------------------------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
        hintStyle: const TextStyle(
          color: AppColors.textHint,
          fontSize: 14,
        ),
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
          borderSide:
              const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11),
      ),
    );
  }

  // ----------------------------------------------------------
  // TOMBOL REGISTRASI
  // ----------------------------------------------------------
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.buttonDisabled,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Registrasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}