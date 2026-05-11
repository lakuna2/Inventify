import 'package:flutter/material.dart';
import 'package:inventify/services/owner_report_service.dart';
import 'package:inventify/widgets/owner/summary_card.dart';
import 'package:inventify/widgets/owner/recent_tx_tile.dart';
import 'package:inventify/widgets/owner/low_stock_banner.dart';
import 'package:inventify/widgets/owner/owner_helpers.dart';
import 'package:inventify/theme.dart';

class OwnerDashboard extends StatefulWidget {
  final void Function(int index)? onNavigate;

  const OwnerDashboard({super.key, this.onNavigate});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final _svc = OwnerReportService();

  Map<String, dynamic> _ringkasan = {};
  List<Map<String, dynamic>> _recentTx = [];
  List<Map<String, dynamic>> _stokTipis = [];
  List<Map<String, dynamic>> _allStok = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        _svc.getRingkasanHarian(),
        _svc.getTransaksi(),
        _svc.getStokTipis(),
        _svc.getAllProdukStok(),
      ]);
      if (!mounted) return;
      setState(() {
        _ringkasan = res[0] as Map<String, dynamic>;
        _recentTx = (res[1] as List<Map<String, dynamic>>).take(5).toList();
        _stokTipis = res[2] as List<Map<String, dynamic>>;
        _allStok = res[3] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (e) {
      debugPrint('=== _load ERROR: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _appBar(),
            _loading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _summaryGrid(),
                        const SizedBox(height: 16),
                        if (_stokTipis.isNotEmpty) ...[
                          LowStockBanner(
                            items: _stokTipis,
                            allStokData: _allStok,
                            onRefresh: _load,
                            onNavigate: widget.onNavigate,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _recentHeader(),
                        const SizedBox(height: 10),
                        if (_recentTx.isEmpty)
                          _empty('Belum ada transaksi hari ini')
                        else
                          ..._recentTx.map(
                            (tx) => RecentTxTile(
                              txId: tx['id'],
                              waktu:
                                  (tx['createdAt'] as dynamic)?.toDate() ??
                                  DateTime.now(),
                              total: (tx['total'] as num).toDouble(),
                              jumlahItem: (tx['items'] as List?)?.length ?? 0,
                              kasir: tx['kasir'] ?? '-',
                            ),
                          ),
                      ]),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0xFF534AB7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const Text(
                        'Dashboard Pemilik',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _load,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SummaryCard(
          label: 'Pendapatan Hari Ini',
          value: rupiahFormat(
            (_ringkasan['pendapatan'] as num?)?.toDouble() ?? 0,
          ),
          icon: Icons.trending_up_rounded,
          color: AppColors.primary,
          badge: 'Hari ini',
        ),
        SummaryCard(
          label: 'Total Transaksi',
          value: '${_ringkasan['transaksi'] ?? 0}',
          icon: Icons.receipt_long_rounded,
          color: AppColors.secondary,
          badge: 'Hari ini',
        ),
        SummaryCard(
          label: 'Item Terjual',
          value: '${_ringkasan['itemTerjual'] ?? 0}',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF1D9E75),
        ),
        SummaryCard(
          label: 'Stok Tipis',
          value: '${_stokTipis.length}',
          icon: Icons.warning_amber_rounded,
          color: AppColors.habis,
        ),
      ],
    );
  }

  Widget _recentHeader() {
    return const Row(
      children: [
        Text(
          'Transaksi Terbaru',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _empty(String msg) => Container(
    padding: const EdgeInsets.symmetric(vertical: 28),
    alignment: Alignment.center,
    child: Text(
      msg,
      style: TextStyle(
        fontSize: 13,
        color: AppColors.textGrey.withValues(alpha: 0.5),
      ),
    ),
  );

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat pagi 👋';
    if (h < 15) return 'Selamat siang 👋';
    if (h < 18) return 'Selamat sore 👋';
    return 'Selamat malam 👋';
  }
}