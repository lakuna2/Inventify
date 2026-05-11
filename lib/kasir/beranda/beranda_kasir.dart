// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:inventify/theme.dart';
import 'package:inventify/kasir/riwayat.dart';

import 'package:inventify/kasir/beranda/beranda_header.dart';
import 'package:inventify/kasir/beranda/beranda_total_card.dart';
import 'package:inventify/kasir/beranda/beranda_akses_cepat.dart';
import 'package:inventify/kasir/beranda/beranda_riwayat.dart';

////////////////////////////////////////////////////////////
/// BERANDA
////////////////////////////////////////////////////////////
class Beranda extends StatefulWidget {
  final void Function(int) onNavigate;
  const Beranda({super.key, required this.onNavigate});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  bool _isHidden = false;

  int _totalPenjualan = 0;
  int _totalLaba = 0;
  int _jumlahTransaksi = 0;
  bool _loadingSummary = true;

  List<Map<String, dynamic>> _riwayat = [];
  bool _loadingRiwayat = true;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    await Future.wait([_fetchSummary(), _fetchRiwayat()]);
  }

  Future<void> _fetchSummary() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    try {
      final snap = await FirebaseFirestore.instance
          .collection('transaksi')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .get();

      int penjualan = 0, laba = 0;
      for (final doc in snap.docs) {
        final d = doc.data();
        penjualan += (d['total'] as num? ?? 0).toInt();
        laba += (d['totalLaba'] as num? ?? 0).toInt();
      }

      if (mounted) {
        setState(() {
          _totalPenjualan = penjualan;
          _totalLaba = laba;
          _jumlahTransaksi = snap.docs.length;
          _loadingSummary = false;
        });
      }
    } catch (e) {
      debugPrint('fetchSummary error: $e');
      if (mounted) setState(() => _loadingSummary = false);
    }
  }

  Future<void> _fetchRiwayat() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('transaksi')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final list = snap.docs.map((doc) {
        final d = doc.data();
        return {
          'id': doc.id,
          'total': (d['total'] as num? ?? 0).toInt(),
          'totalLaba': (d['totalLaba'] as num? ?? 0).toInt(),
          'kasir': d['kasir'] ?? '-',
          'createdAt': d['createdAt'] as Timestamp?,
          'items': d['items'] as List<dynamic>? ?? [],
        };
      }).toList();

      if (mounted) {
        setState(() {
          _riwayat = list;
          _loadingRiwayat = false;
        });
      }
    } catch (e) {
      debugPrint('fetchRiwayat error: $e');
      if (mounted) setState(() => _loadingRiwayat = false);
    }
  }

  static String formatRupiah(int value) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderBanner(),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TotalCard(
                        totalPenjualan: _totalPenjualan,
                        totalLaba: _totalLaba,
                        jumlahTransaksi: _jumlahTransaksi,
                        isHidden: _isHidden,
                        isLoading: _loadingSummary,
                        onToggle: () => setState(() => _isHidden = !_isHidden),
                        formatRupiah: formatRupiah,
                      ),
                      const SizedBox(height: 20),
                      AksesCepat(onNavigate: widget.onNavigate),
                      const SizedBox(height: 24),
                      RiwayatSection(
                        riwayat: _riwayat,
                        isLoading: _loadingRiwayat,
                        formatRupiah: formatRupiah,
                        onLihatSemua: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Riwayat()),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}