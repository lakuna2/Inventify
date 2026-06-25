import 'package:flutter/material.dart';
import 'package:inventify/controllers/auth.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:inventify/pages/masuk.dart';
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

  final _namaPemilikCtrl = TextEditingController();
  final _namaTokoCtrl = TextEditingController();
  final _alamatTokoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();

  // Role sudah fixed — tidak perlu dipilih
  static const String _role = 'Pemilik';

  bool _showPassword = false;
  bool _showKonfirmasi = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaPemilikCtrl.dispose();
    _namaTokoCtrl.dispose();
    _alamatTokoCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Auth().regis(
        _namaPemilikCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _role,
        _namaTokoCtrl.text.trim(),
        _alamatTokoCtrl.text.trim(),
      );

      // Matikan loading dulu sebelum tampil alert
      if (mounted) setState(() => _isLoading = false);

      CustomQuickAlert.confirm(
        title: 'Registrasi Berhasil!',
        message:
            'Akun berhasil dibuat.\nLink verifikasi telah dikirim ke email Anda.\nJika belum ditemukan, silakan cek folder Spam atau Promosi.',
        confirmBtnColor: AppColors.primary,
        onConfirm: () {
          Future.microtask(() {
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (_) => const MasukPage()),
            );
          });
        },
      );
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);

      CustomQuickAlert.error(
        title: 'Registrasi Gagal',
        message: e.toString(),
        confirmText: 'Coba Lagi',
        confirmBtnColor: Colors.redAccent,
      );
    }
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
          // ── Judul + Badge Pemilik ──
          Row(
            children: [
              const Text(
                'Registrasi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.store_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Pemilik Toko',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          const Text(
            'Isi data di bawah untuk membuat akun toko Anda.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 20),

          // ── Section: Data Pemilik ──
          _buildSectionLabel('Data Pemilik'),
          const SizedBox(height: 10),

          _buildTextField(
            controller: _namaPemilikCtrl,
            hint: 'Nama Pemilik',
            icon: Icons.person_outline_rounded,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Nama pemilik tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 14),

          _buildTextField(
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
          const SizedBox(height: 14),

          _buildTextField(
            controller: _passwordCtrl,
            hint: 'Password',
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
                return 'Password tidak boleh kosong';
              }
              if (v.length < 6) return 'Minimal 6 karakter';
              return null;
            },
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _konfirmasiCtrl,
            hint: 'Konfirmasi Password',
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
              if (v == null || v.isEmpty) return 'Konfirmasi password';
              if (v != _passwordCtrl.text) return 'Password tidak sama';
              return null;
            },
          ),

          const SizedBox(height: 20),

          // ── Section: Data Toko ──
          _buildSectionLabel('Data Toko'),
          const SizedBox(height: 10),

          _buildTextField(
            controller: _namaTokoCtrl,
            hint: 'Nama Toko',
            icon: Icons.store_outlined,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Nama toko tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _alamatTokoCtrl,
            hint: 'Alamat Toko',
            icon: Icons.location_on_outlined,
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Alamat toko tidak boleh kosong'
                : null,
          ),

          const SizedBox(height: 24),

          _buildRegisterButton(),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SECTION LABEL
  // ----------------------------------------------------------
  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
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
                'Daftar Sekarang',
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
