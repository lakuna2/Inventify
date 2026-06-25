import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/pages/masuk.dart';
import 'package:inventify/services/owner_report_service.dart';
import 'package:inventify/services/export_services.dart';
import 'package:inventify/widgets/owner/owner_helpers.dart';
import 'package:inventify/theme.dart';
// ignore: unused_import
import 'package:inventify/utils/alert_helper.dart';

class OwnerPengaturan extends StatefulWidget {
  const OwnerPengaturan({super.key});

  @override
  State<OwnerPengaturan> createState() => _OwnerPengaturanState();
}

class _OwnerPengaturanState extends State<OwnerPengaturan> {
  final _svc = OwnerReportService();
  final _exportSvc = ExportService();

  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (mounted) {
        setState(() {
          _user = doc.data();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    CustomQuickAlert.confirm(
      title: 'Konfirmasi Logout',
      message: 'Yakin ingin Logout?',
      confirmBtnColor: AppColors.primary,
      onConfirm: () async {
        try {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MasukPage()),
              (route) => false,
            );
            AlertHelper.success('Berhasil logout!');
          }
        } catch (e) {
          if (mounted) {
            AlertHelper.error('Gagal logout: $e');
          }
        }
      },
    );
  }

  Future<void> _hapusSemuaRiwayat() async {
    CustomQuickAlert.confirm(
      title: 'Hapus Semua Riwayat?',
      message: 'Semua data transaksi akan dihapus permanen. Tidak bisa dibatalkan.',
      confirmBtnColor: AppColors.habis,
      onConfirm: () async {
        try {
          final txList = await _svc.getTransaksi();
          await _svc.hapusSemua(txList.map((tx) => tx['id'] as String).toList());
          if (mounted) {
            AlertHelper.success('Semua riwayat berhasil dihapus');
          }
        } catch (e) {
          if (mounted) {
            AlertHelper.error('Gagal menghapus riwayat: $e');
          }
        }
      },
    );
  }

  /// Tampilkan bottom sheet pilihan periode + format export
  Future<void> _exportData() async {
    // Ambil data dulu sebelum buka sheet supaya preview jumlah transaksi akurat
    List<Map<String, dynamic>> semuaData = [];
    try {
      semuaData = await _svc.getTransaksi();
    } catch (_) {}

    if (!mounted) return;

    if (semuaData.isEmpty) {
      AlertHelper.warning('Belum ada data transaksi untuk diekspor');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ExportSheet(
        semuaData: semuaData,
        namaToko: _user?['namaToko'] as String? ?? 'Inventify',
        alamat: _user?['alamatToko'] as String?,
        exportSvc: _exportSvc,
        onSuccess: (jumlah, total) {
          if (!mounted) return;
          AlertHelper.success('$jumlah transaksi berhasil diekspor · ${rupiahFormat(total)}');
        },
        onError: (e) {
          if (!mounted) return;
          AlertHelper.error('Gagal export: $e');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final nama =
        _user?['nama'] ?? FirebaseAuth.instance.currentUser?.email ?? '?';
    final email =
        _user?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profil card ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF534AB7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Pemilik',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Info Toko ─────────────────────────────────────────────
          _label('Info Toko'),
          _card([
            _info(
              Icons.store_outlined,
              'Nama Toko',
              _user?['namaToko'] ?? 'Belum diisi',
            ),
            _info(
              Icons.location_on_outlined,
              'Alamat',
              _user?['alamatToko'] ?? 'Belum diisi',
            ),
          ]),
          const SizedBox(height: 16),

          // ── Data & Laporan ────────────────────────────────────────
          _label('Data & Laporan'),
          _card([
            _menu(
              Icons.file_download_outlined,
              'Export Data Transaksi',
              AppColors.secondary,
              onTap: _exportData,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _menu(
              Icons.delete_sweep_outlined,
              'Hapus Semua Riwayat',
              AppColors.habis,
              onTap: _hapusSemuaRiwayat,
            ),
          ]),
          const SizedBox(height: 24),

          // ── Logout ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, size: 17),
              label: const Text(
                'Keluar dari Akun',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: AppColors.habis,
                side: const BorderSide(color: AppColors.habis),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Helper widgets ───────────────────────────────────────────────
  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textGrey.withValues(alpha: 0.7),
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _card(List<Widget> c) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
      ],
    ),
    child: Column(children: c),
  );

  Widget _info(IconData icon, String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGrey.withValues(alpha: 0.8),
            ),
          ),
        ),
        Expanded(
          child: Text(
            val,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _menu(
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textGrey.withValues(alpha: 0.4),
            size: 16,
          ),
        ],
      ),
    ),
  );
}

// ─── Export Bottom Sheet ──────────────────────────────────────────────────────
class _ExportSheet extends StatefulWidget {
  final List<Map<String, dynamic>> semuaData;
  final String namaToko;
  final String? alamat;
  final ExportService exportSvc;
  final void Function(int jumlah, double total) onSuccess;
  final void Function(Object e) onError;

  const _ExportSheet({
    required this.semuaData,
    required this.namaToko,
    this.alamat,
    required this.exportSvc,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  FilterPeriode? _periode;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Default: semua transaksi
    _periode = FilterPeriode.semua();
  }

  List<Map<String, dynamic>> get _filtered =>
      ExportService.filterTransaksi(widget.semuaData, _periode!);

  // Ambil daftar bulan unik dari transaksi
  List<FilterPeriode> get _availableMonths {
    final months = <String, FilterPeriode>{};
    
    for (final tx in widget.semuaData) {
      final timestamp = tx['createdAt'];
      if (timestamp != null) {
        try {
          final date = (timestamp as dynamic).toDate() as DateTime;
          final key = '${date.year}-${date.month}';
          if (!months.containsKey(key)) {
            months[key] = FilterPeriode.bulan(date.year, date.month);
          }
        } catch (_) {}
      }
    }
    
    // Sort descending (bulan terbaru di atas)
    final list = months.values.toList();
    list.sort((a, b) {
      if (a.year != b.year) return b.year!.compareTo(a.year!);
      return b.month!.compareTo(a.month!);
    });
    
    return list;
  }

  Future<void> _export(String format) async {
    setState(() => _loading = true);
    try {
      final data = _filtered;
      if (format == 'csv') {
        await widget.exportSvc.exportCsv(
          widget.semuaData,
          namaToko: widget.namaToko,
          periode: _periode,
        );
      } else {
        await widget.exportSvc.exportPdf(
          widget.semuaData,
          namaToko: widget.namaToko,
          alamat: widget.alamat,
          periode: _periode,
        );
      }
      if (mounted) Navigator.pop(context);
      final total = data.fold(0.0, (s, tx) => s + (tx['total'] as num? ?? 0).toDouble());
      widget.onSuccess(data.length, total);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      widget.onError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jumlah = _filtered.length;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 14, 20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Judul
          const Text(
            'Export Data Transaksi',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih periode lalu pilih format file',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGrey.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),

          // Pilih Periode (Dropdown)
          const Text(
            'Periode',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<FilterPeriode>(
                isExpanded: true,
                value: _periode,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textGrey),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                items: [
                  // Opsi "Semua Transaksi"
                  DropdownMenuItem(
                    value: FilterPeriode.semua(),
                    child: const Text('Semua Transaksi'),
                  ),
                  // Divider
                  if (_availableMonths.isNotEmpty)
                    const DropdownMenuItem(
                      enabled: false,
                      child: Divider(height: 1),
                    ),
                  // Bulan-bulan yang tersedia
                  ..._availableMonths.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p.label),
                  )),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _periode = val);
                },
              ),
            ),
          ),

          // Preview jumlah
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '$jumlah transaksi pada periode "${_periode!.label}"',
                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pilih Format
          const Text(
            'Format File',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 10),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else ...[
            _fmtBtn(
              icon: Icons.table_chart_outlined,
              label: 'Export CSV',
              desc: 'Cocok untuk spreadsheet (Excel, Google Sheets)',
              color: const Color(0xFF1D9E75),
              onTap: () => _export('csv'),
            ),
            const SizedBox(height: 10),
            _fmtBtn(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Export PDF',
              desc: 'Laporan siap cetak dengan tampilan profesional',
              color: AppColors.habis,
              onTap: () => _export('pdf'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fmtBtn({
    required IconData icon,
    required String label,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(14),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )),
                  const SizedBox(height: 2),
                  Text(desc,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey.withValues(alpha: 0.8),
                    )),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
              color: AppColors.textGrey.withValues(alpha: 0.4), size: 18),
          ],
        ),
      ),
    );
  }
}