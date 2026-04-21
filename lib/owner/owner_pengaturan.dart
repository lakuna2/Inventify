import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/services/owner_report_service.dart';
import 'package:inventify/widgets/owner/owner_helpers.dart';
import 'package:inventify/theme.dart';

class OwnerPengaturan extends StatefulWidget {
  const OwnerPengaturan({super.key});

  @override
  State<OwnerPengaturan> createState() => _OwnerPengaturanState();
}

class _OwnerPengaturanState extends State<OwnerPengaturan> {
  final _svc = OwnerReportService();
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) setState(() { _user = doc.data(); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        content: const Text('Yakin ingin keluar dari akun ini?', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0),
            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    ) ?? false;
    if (ok) await FirebaseAuth.instance.signOut();
  }

  Future<void> _hapusSemuaRiwayat() async {
    final ok = await confirmDelete(context,
      judul: 'Hapus Semua Riwayat',
      isi: 'Semua data transaksi akan dihapus permanen. Tidak bisa dibatalkan.',
      dangerous: true);
    if (!ok) return;
    try {
      final txList = await _svc.getTransaksi();
      await _svc.hapusSemua(txList.map((tx) => tx['id'] as String).toList());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua riwayat dihapus'), backgroundColor: Color(0xFF1D9E75)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.habis));
    }
  }

  Future<void> _exportData() async {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(width: 14),
          Text('Menyiapkan data...'),
        ]),
      ),
    );
    try {
      final data = await _svc.getTransaksi();
      if (!mounted) return;
      Navigator.pop(context);
      final total = data.fold(0.0, (s, tx) => s + (tx['total'] as num).toDouble());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${data.length} transaksi siap. Total: ${rupiahFormat(total)}'),
        backgroundColor: AppColors.tersedia, duration: const Duration(seconds: 4)));
      // TODO: implementasi export CSV/PDF
    } catch (e) {
      if (mounted) { Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.habis)); }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    final nama = _user?['nama'] ?? FirebaseAuth.instance.currentUser?.email ?? '?';
    final email = _user?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        elevation: 0, automaticallyImplyLeading: false,
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Profil card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF534AB7)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2)),
              child: Center(child: Text(
                nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nama, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(email, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Pemilik',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
            ])),
          ]),
        ),
        const SizedBox(height: 20),

        // Info Toko
        _label('Info Toko'),
        _card([
          _info(Icons.store_outlined, 'Nama Toko', _user?['namaToko'] ?? 'Belum diisi'),
          _info(Icons.location_on_outlined, 'Alamat', _user?['alamat'] ?? 'Belum diisi'),
          _info(Icons.phone_outlined, 'Telepon', _user?['telepon'] ?? 'Belum diisi'),
        ]),
        const SizedBox(height: 16),

        // Data
        _label('Data & Laporan'),
        _card([
          _menu(Icons.file_download_outlined, 'Export Data Transaksi', AppColors.secondary, onTap: _exportData),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _menu(Icons.delete_sweep_outlined, 'Hapus Semua Riwayat', AppColors.habis, onTap: _hapusSemuaRiwayat),
        ]),
        const SizedBox(height: 24),

        // Logout
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded, size: 17),
          label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: AppColors.habis,
            side: const BorderSide(color: AppColors.habis),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        )),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
      color: AppColors.textGrey.withValues(alpha: 0.7), letterSpacing: 0.4)));

  Widget _card(List<Widget> c) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)]),
    child: Column(children: c));

  Widget _info(IconData icon, String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.secondary),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(fontSize: 12, color: AppColors.textGrey.withValues(alpha: 0.8))),
      const Spacer(),
      Flexible(child: Text(val, textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark))),
    ]));

  Widget _menu(IconData icon, String label, Color color, {required VoidCallback onTap}) =>
    InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 16)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, color: AppColors.textGrey.withValues(alpha: 0.4), size: 16),
        ])));
}