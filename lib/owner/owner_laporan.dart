import 'package:flutter/material.dart';
import 'package:inventify/services/owner_report_service.dart';
import 'package:inventify/owner/owner_laporan_minggu.dart';
import 'package:inventify/owner/owner_laporan_bulan.dart';
import 'package:inventify/owner/owner_laporan_stok.dart';
import 'package:inventify/theme.dart';

class OwnerLaporan extends StatefulWidget {
  const OwnerLaporan({super.key});

  @override
  State<OwnerLaporan> createState() => _OwnerLaporanState();
}

class _OwnerLaporanState extends State<OwnerLaporan>
    with SingleTickerProviderStateMixin {
  final _svc = OwnerReportService();
  late final TabController _tab = TabController(length: 3, vsync: this);

  List<Map<String, dynamic>> _grafikData = [];
  Map<String, dynamic> _bulanData = {};
  List<Map<String, dynamic>> _stokData = [];

  bool _loadMinggu = true, _loadBulan = true, _loadStok = true;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchMinggu();
    _tab.addListener(() {
      if (_tab.indexIsChanging) return;
      if (_tab.index == 1 && _bulanData.isEmpty) _fetchBulan();
      if (_tab.index == 2 && _stokData.isEmpty) _fetchStok();
    });
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _fetchMinggu() async {
    setState(() => _loadMinggu = true);
    try {
      final d = await _svc.getGrafikMingguan();
      if (mounted) setState(() { _grafikData = d; _loadMinggu = false; });
    } catch (_) { if (mounted) setState(() => _loadMinggu = false); }
  }

  Future<void> _fetchBulan() async {
    setState(() => _loadBulan = true);
    try {
      final d = await _svc.getRingkasanBulan(tanggal: _selectedMonth);
      if (mounted) setState(() { _bulanData = d; _loadBulan = false; });
    } catch (_) { if (mounted) setState(() => _loadBulan = false); }
  }

  void _changeMonth(DateTime newMonth) {
    setState(() => _selectedMonth = newMonth);
    _fetchBulan();
  }

  Future<void> _fetchStok() async {
    setState(() => _loadStok = true);
    try {
      // Ganti getStokTipis() → getAllProdukStok() agar semua produk tampil
      final d = await _svc.getAllProdukStok();
      if (mounted) setState(() { _stokData = d; _loadStok = false; });
    } catch (_) { if (mounted) setState(() => _loadStok = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Laporan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [Tab(text: 'Mingguan'), Tab(text: 'Bulanan'), Tab(text: 'Stok')],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        LaporanMinggu(loading: _loadMinggu, data: _grafikData, onRefresh: _fetchMinggu),
        LaporanBulan(
          loading: _loadBulan,
          data: _bulanData,
          onRefresh: _fetchBulan,
          selectedMonth: _selectedMonth,
          onMonthChange: _changeMonth,
        ),
        LaporanStok(loading: _loadStok, data: _stokData, onRefresh: _fetchStok),
      ]),
    );
  }
}