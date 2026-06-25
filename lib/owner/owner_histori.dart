import 'package:flutter/material.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:inventify/services/owner_report_service.dart';
import 'package:inventify/widgets/owner/recent_tx_tile.dart';
import 'package:inventify/widgets/owner/owner_helpers.dart';
import 'package:inventify/owner/owner_histori_detail.dart';
import 'package:inventify/owner/owner_histori_filter.dart';
import 'package:inventify/theme.dart';
import 'package:inventify/utils/alert_helper.dart';

class OwnerHistori extends StatefulWidget {
  const OwnerHistori({super.key});

  @override
  State<OwnerHistori> createState() => _OwnerHistoriState();
}

class _OwnerHistoriState extends State<OwnerHistori> {
  final _svc = OwnerReportService();
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;

  DateTime? _dari;
  DateTime? _sampai;
  String _kasir = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _svc.getTransaksi(dari: _dari, sampai: _sampai, kasir: _kasir.isEmpty ? null : _kasir);
      if (!mounted) return;
      setState(() { _all = data; _applySearch(); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applySearch() {
    final q = _searchCtrl.text.toLowerCase();
    _filtered = q.isEmpty ? List.from(_all) : _all.where((tx) {
      return (tx['id'] as String).toLowerCase().contains(q) ||
             (tx['kasir'] as String? ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _hapusSatu(String id) async {
    CustomQuickAlert.confirm(
      title: 'Hapus Transaksi?',
      message: 'Transaksi #${id.substring(0, 8).toUpperCase()} akan dihapus permanen.',
      confirmBtnColor: AppColors.habis,
      onConfirm: () async {
        await _svc.hapusSatu(id);
        setState(() { _all.removeWhere((tx) => tx['id'] == id); _applySearch(); });
        if (mounted) {
          AlertHelper.success('Transaksi berhasil dihapus');
        }
      },
    );
  }

  Future<void> _hapusSemua() async {
    CustomQuickAlert.confirm(
      title: 'Hapus Semua Transaksi?',
      message: 'Semua ${_filtered.length} transaksi akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.',
      confirmBtnColor: AppColors.habis,
      onConfirm: () async {
        await _svc.hapusSemua(_filtered.map((tx) => tx['id'] as String).toList());
        await _load();
        if (mounted) {
          AlertHelper.success('Semua riwayat berhasil dihapus');
        }
      },
    );
  }

  bool get _hasFilter => _dari != null || _sampai != null || _kasir.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Riwayat Transaksi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [
          if (_filtered.isNotEmpty)
            IconButton(icon: const Icon(Icons.delete_sweep_rounded), onPressed: _hapusSemua),
          Stack(children: [
            IconButton(icon: const Icon(Icons.tune_rounded), onPressed: _openFilter),
            if (_hasFilter) Positioned(top: 8, right: 8,
              child: Container(width: 7, height: 7,
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle))),
          ]),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() => _applySearch()),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari ID atau kasir...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7), size: 18),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: Column(children: [
        // Filter & total bar
        if (!_loading)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Text('${_filtered.length} transaksi',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey.withValues(alpha: 0.7))),
              const Spacer(),
              if (_filtered.isNotEmpty)
                Text(rupiahFormat(_filtered.fold(0.0, (s, tx) => s + (tx['total'] as num).toDouble())),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ),

        // List
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _filtered.isEmpty
            ? Center(child: Text(_hasFilter ? 'Tidak ada hasil' : 'Belum ada transaksi',
                style: TextStyle(fontSize: 13, color: AppColors.textGrey.withValues(alpha: 0.5))))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 32),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final tx = _filtered[i];
                  return RecentTxTile(
                    txId: tx['id'],
                    waktu: (tx['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
                    total: (tx['total'] as num).toDouble(),
                    jumlahItem: (tx['items'] as List?)?.length ?? 0,
                    kasir: tx['kasir'] ?? '-',
                    onDelete: () => _hapusSatu(tx['id']),
                    onTap: () => HistoriDetail.show(context, tx: tx, onDelete: () => _hapusSatu(tx['id'])),
                  );
                },
              ),
        ),
      ]),
    );
  }

  void _openFilter() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistoriFilter(dari: _dari, sampai: _sampai, kasir: _kasir),
    );
    if (result == null) return;
    setState(() {
      _dari = result['dari'];
      _sampai = result['sampai'];
      _kasir = result['kasir'] ?? '';
    });
    _load();
  }
}