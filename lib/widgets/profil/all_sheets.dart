import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventify/theme.dart';

// ════════════════════════════════════════════════
// SHARED WIDGETS
// ════════════════════════════════════════════════

class SheetContainer extends StatelessWidget {
  final String title;
  final Widget child;
  const SheetContainer({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Align(alignment: Alignment.centerLeft,
          child: Text(title, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark))),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

class ActionRow extends StatelessWidget {
  final bool loading;
  final VoidCallback onCancel, onSubmit;
  const ActionRow({super.key, required this.loading, required this.onCancel, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: OutlinedButton(
        onPressed: onCancel,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Batal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
      )),
      const SizedBox(width: 12),
      Expanded(child: ElevatedButton(
        onPressed: loading ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0),
        child: loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
      )),
    ]);
  }
}

// ════════════════════════════════════════════════
// UBAH PASSWORD
// ════════════════════════════════════════════════

class UbahPasswordSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UbahPasswordContent(),
    );
  }
}

class _UbahPasswordContent extends StatefulWidget {
  const _UbahPasswordContent();
  @override
  State<_UbahPasswordContent> createState() => _UbahPasswordContentState();
}

class _UbahPasswordContentState extends State<_UbahPasswordContent> {
  final _lamaCtrl = TextEditingController();
  final _baruCtrl = TextEditingController();
  final _konfCtrl = TextEditingController();
  bool _loading = false;
  bool _showLama = false, _showBaru = false, _showKonf = false;

  Future<void> _ubah() async {
    if (_baruCtrl.text != _konfCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru tidak cocok'), backgroundColor: Colors.orange));
      return;
    }
    if (_baruCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(email: user.email!, password: _lamaCtrl.text);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_baruCtrl.text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah'), backgroundColor: Color(0xFF1D9E75)));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        final msg = e.code == 'wrong-password' ? 'Password lama salah' : 'Gagal: ${e.message}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.habis));
      }
    }
  }

  @override
  void dispose() { _lamaCtrl.dispose(); _baruCtrl.dispose(); _konfCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SheetContainer(
        title: 'Ubah Password',
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _passField(_lamaCtrl, 'Password Lama', _showLama, () => setState(() => _showLama = !_showLama)),
          const SizedBox(height: 10),
          _passField(_baruCtrl, 'Password Baru', _showBaru, () => setState(() => _showBaru = !_showBaru)),
          const SizedBox(height: 10),
          _passField(_konfCtrl, 'Konfirmasi Password', _showKonf, () => setState(() => _showKonf = !_showKonf)),
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerLeft,
            child: Text('Minimal 6 karakter',
              style: TextStyle(fontSize: 11, color: AppColors.textGrey.withValues(alpha: 0.7)))),
          const SizedBox(height: 20),
          ActionRow(loading: _loading, onCancel: () => Navigator.pop(context), onSubmit: _ubah),
        ]),
      ),
    );
  }

  Widget _passField(TextEditingController c, String label, bool show, VoidCallback toggle) {
    return TextField(
      controller: c,
      obscureText: !show,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.secondary),
        suffixIcon: GestureDetector(onTap: toggle,
          child: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textGrey, size: 20)),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary)),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// NOTIFIKASI
// ════════════════════════════════════════════════

class NotifikasiSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotifikasiContent(),
    );
  }
}

class _NotifikasiContent extends StatefulWidget {
  const _NotifikasiContent();
  @override
  State<_NotifikasiContent> createState() => _NotifikasiContentState();
}

class _NotifikasiContentState extends State<_NotifikasiContent> {
  bool _stokTipis = true;
  bool _transaksi = true;
  bool _laporan = false;

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      title: 'Notifikasi',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _switchTile('Peringatan Stok Tipis', 'Notif saat stok ≤ 5 pcs', _stokTipis,
          (v) => setState(() => _stokTipis = v)),
        const Divider(height: 1),
        _switchTile('Transaksi Selesai', 'Konfirmasi setiap transaksi', _transaksi,
          (v) => setState(() => _transaksi = v)),
        const Divider(height: 1),
        _switchTile('Laporan Harian', 'Ringkasan penjualan tiap hari', _laporan,
          (v) => setState(() => _laporan = v)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0),
          child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }

  Widget _switchTile(String title, String sub, bool val, void Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.45))),
        ])),
        Switch.adaptive(value: val, onChanged: onChanged,
          // ignore: deprecated_member_use
          activeColor: AppColors.secondary),
      ]),
    );
  }
}

// ════════════════════════════════════════════════
// TAMPILAN (TEMA)
// ════════════════════════════════════════════════

class TampilanSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TampilanContent(),
    );
  }
}

class _TampilanContent extends StatefulWidget {
  const _TampilanContent();
  @override
  State<_TampilanContent> createState() => _TampilanContentState();
}

class _TampilanContentState extends State<_TampilanContent> {
  int _selected = 0; // 0=sistem, 1=terang, 2=gelap

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      title: 'Tampilan',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ...['Ikuti sistem', 'Mode Terang', 'Mode Gelap']
            .asMap()
            .entries
            .map((e) => Column(children: [
                  if (e.key > 0) const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.value,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                    trailing: _selected == e.key
                        ? const Icon(Icons.check_rounded, color: AppColors.secondary)
                        : null,
                    onTap: () => setState(() => _selected = e.key),
                  ),
                ])),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0),
          child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }
}

// ════════════════════════════════════════════════
// TENTANG APLIKASI
// ════════════════════════════════════════════════

class TentangSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SheetContainer(
        title: 'Tentang Aplikasi',
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.storefront_rounded, color: Color(0xFF534AB7), size: 36),
          ),
          const SizedBox(height: 12),
          const Text('Inventify', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('Versi 1.0.0', style: TextStyle(fontSize: 13, color: AppColors.textGrey.withValues(alpha: 0.8))),
          const SizedBox(height: 20),
          ...[
            ('Pengembang', 'Tim Inventify'),
            ('Platform', 'Flutter & Firebase'),
            ('Lisensi', 'MIT License'),
          ].map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Text(r.$1, style: TextStyle(fontSize: 13, color: AppColors.textGrey.withValues(alpha: 0.8))),
              const Spacer(),
              Text(r.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ]),
          )),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Tutup', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          )),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// BANTUAN & FAQ
// ════════════════════════════════════════════════

class BantuanSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 20, 20, 32), children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Bantuan & FAQ', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 16),
            ..._faqs.map((f) => _FaqTile(q: f.$1, a: f.$2)),
          ]),
        ),
      ),
    );
  }

  static const _faqs = [
    ('Bagaimana cara menambah barang?', 'Buka halaman Produk, lalu tap tombol + di pojok kanan atas. Scan barcode barang terlebih dahulu, kemudian isi data produk.'),
    ('Bagaimana cara melakukan transaksi?', 'Buka halaman Transaksi, tap tombol Scan lalu arahkan ke barcode barang. Setelah semua barang masuk keranjang, tap Bayar.'),
    ('Apa yang terjadi jika barcode tidak terbaca?', 'Kamu bisa memasukkan nomor barcode secara manual pada kolom yang tersedia di bawah area scanner.'),
    ('Bagaimana cara melihat riwayat transaksi?', 'Buka halaman Riwayat. Kamu bisa mencari berdasarkan ID transaksi atau filter berdasarkan tanggal.'),
    ('Bagaimana cara mengubah password?', 'Buka Profil → Ubah Password. Masukkan password lama dan password baru minimal 6 karakter.'),
  ];
}

class _FaqTile extends StatefulWidget {
  final String q, a;
  const _FaqTile({required this.q, required this.a});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _open
            ? AppColors.secondary.withValues(alpha: 0.4)
            : AppColors.textGrey.withValues(alpha: 0.15)),
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Expanded(child: Text(widget.q,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: _open ? AppColors.secondary : AppColors.textDark))),
              Icon(_open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: _open ? AppColors.secondary : AppColors.textGrey, size: 20),
            ]),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(widget.a,
              style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.6), height: 1.5)),
          ),
      ]),
    );
  }
}