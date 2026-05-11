// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/controllers/auth.dart';
import 'package:inventify/kasir/kasir_navbar.dart';
import 'package:inventify/owner/owner_navbar.dart';
import 'package:inventify/theme.dart';
import 'package:inventify/widgets/auth_link.dart';

// ============================================================
// MASUK PAGE
// ============================================================
class MasukPage extends StatefulWidget {
  const MasukPage({super.key});

  @override
  State<MasukPage> createState() => _MasukPageState();
}

class _MasukPageState extends State<MasukPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── LOGIN HANDLER ──
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Auth()
        .masuk(_emailCtrl.text, _passwordCtrl.text)
        .then((_) async {
          // Ambil data user dari Firestore
          User? user = FirebaseAuth.instance.currentUser;
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

          String role = (userDoc['role'] ?? '').toString().toLowerCase();

          // Navigasi berdasarkan role
          if (role == 'pemilik') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OwnerBottomNavbar()),
            );
          } else if (role == 'kasir') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationKasir(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Role pengguna tidak dikenali')),
            );
          }
        })
        .catchError((e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        })
        .whenComplete(() => setState(() => _isLoading = false));
  }

  // ── FORGOT PASSWORD ──
  void _handleForgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      _showSnackbar('Masukkan email terlebih dahulu');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailCtrl.text.trim(),
      );
      _showSnackbar('Link reset kata sandi telah dikirim ke email');
    } on FirebaseAuthException catch (e) {
      _showSnackbar(_pesanError(e.code));
    }
  }

  // ── ERROR MESSAGES ──
  String _pesanError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Kata sandi salah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'invalid-credential':
        return 'Email atau kata sandi salah';
      case 'user-disabled':
        return 'Akun dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return 'Terjadi kesalahan, coba lagi';
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

                // ── Link Registrasi ──
                AuthLink(mode: AuthMode.login),

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
    return Image.asset('assets/logo.jpg', width: 180);
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
            'Masuk',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Email
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

          // Password
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
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Kata sandi tidak boleh kosong';
              }
              return null;
            },
          ),

          // Lupa Kata Sandi
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              ),
              child: const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Tombol Masuk
          _buildLoginButton(),
        ],
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
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
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

  // ----------------------------------------------------------
  // TOMBOL LOGIN
  // ----------------------------------------------------------
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
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
                'Masuk',
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
