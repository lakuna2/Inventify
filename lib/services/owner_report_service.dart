import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerReportService {
  final _db = FirebaseFirestore.instance;

  // ── Ringkasan harian ──────────────────────────────
  Future<Map<String, dynamic>> getRingkasanHarian() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _db
        .collection('transaksi')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .get();

    double pendapatan = 0;
    int itemTerjual = 0;
    for (final doc in snap.docs) {
      pendapatan += (doc['total'] as num).toDouble();
      for (final item in (doc['items'] as List? ?? [])) {
        itemTerjual += (item['qty'] as num).toInt();
      }
    }
    return {
      'pendapatan': pendapatan,
      'transaksi': snap.docs.length,
      'itemTerjual': itemTerjual,
    };
  }

  // ── Ringkasan bulanan ─────────────────────────────
  Future<Map<String, dynamic>> getRingkasanBulan() async {
    final now = DateTime.now();
    final dari = DateTime(now.year, now.month, 1);
    final sampai = DateTime(now.year, now.month + 1, 1);

    final snap = await _db
        .collection('transaksi')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dari))
        .where('createdAt', isLessThan: Timestamp.fromDate(sampai))
        .get();

    double pendapatan = 0;
    int itemTerjual = 0;
    final Map<String, double> produkMap = {};

    for (final doc in snap.docs) {
      pendapatan += (doc['total'] as num).toDouble();
      for (final item in (doc['items'] as List? ?? [])) {
        itemTerjual += (item['qty'] as num).toInt();
        final nama = item['nama'] ?? item['name'] ?? 'Unknown';
        produkMap[nama] = (produkMap[nama] ?? 0) + (item['subtotal'] as num).toDouble();
      }
    }

    final topProduk = (produkMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(5)
        .map((e) => {'nama': e.key, 'total': e.value})
        .toList();

    return {
      'pendapatan': pendapatan,
      'transaksi': snap.docs.length,
      'itemTerjual': itemTerjual,
      'topProduk': topProduk,
    };
  }

  // ── Grafik 7 hari terakhir ────────────────────────
  Future<List<Map<String, dynamic>>> getGrafikMingguan() async {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final hari = DateTime(now.year, now.month, now.day - i);
      final next = hari.add(const Duration(days: 1));
      final snap = await _db
          .collection('transaksi')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(hari))
          .where('createdAt', isLessThan: Timestamp.fromDate(next))
          .get();
      double total = 0;
      for (final doc in snap.docs) {
        total += (doc['total'] as num).toDouble();
      }
      result.add({
        'tanggal': hari,
        'label': ['Min','Sen','Sel','Rab','Kam','Jum','Sab'][hari.weekday % 7],
        'total': total,
        'jumlah': snap.docs.length,
      });
    }
    return result;
  }

  // ── Stok tipis ────────────────────────────────────
  Future<List<Map<String, dynamic>>> getStokTipis({int batas = 5}) async {
    final snap = await _db
        .collection('produk')
        .where('stok', isLessThanOrEqualTo: batas)
        .orderBy('stok')
        .get();
    return snap.docs.map((doc) => {
      'id': doc.id,
      'nama': doc['nama'] ?? '',
      'stok': (doc['stok'] as num).toInt(),
    }).toList();
  }

  // ── Semua transaksi + filter ──────────────────────
  Future<List<Map<String, dynamic>>> getTransaksi({
    DateTime? dari,
    DateTime? sampai,
    String? kasir,
  }) async {
    Query q = _db.collection('transaksi').orderBy('createdAt', descending: true);
    if (dari != null) q = q.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dari));
    if (sampai != null) q = q.where('createdAt', isLessThan: Timestamp.fromDate(sampai.add(const Duration(days: 1))));
    if (kasir != null && kasir.isNotEmpty) q = q.where('kasir', isEqualTo: kasir);

    final snap = await q.get();
    return snap.docs.map((doc) => {'id': doc.id, ...(doc.data() as Map<String, dynamic>)}).toList();
  }

  // ── Hapus transaksi ───────────────────────────────
  Future<void> hapusSatu(String txId) =>
      _db.collection('transaksi').doc(txId).delete();

  Future<void> hapusSemua(List<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(_db.collection('transaksi').doc(id));
    }
    await batch.commit();
  }
}