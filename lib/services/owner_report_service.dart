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
      final d = doc.data();
      pendapatan += (d['total'] as num? ?? 0).toDouble();
      for (final item in (d['items'] as List? ?? [])) {
        itemTerjual += (item['qty'] as num? ?? 0).toInt();
      }
    }
    return {
      'pendapatan': pendapatan,
      'transaksi': snap.docs.length,
      'itemTerjual': itemTerjual,
    };
  }

  // ── Ringkasan bulanan ─────────────────────────────
  Future<Map<String, dynamic>> getRingkasanBulan({DateTime? tanggal}) async {
    final targetDate = tanggal ?? DateTime.now();
    final dari = DateTime(targetDate.year, targetDate.month, 1);
    final sampai = DateTime(targetDate.year, targetDate.month + 1, 1);

    final snap = await _db
        .collection('transaksi')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dari))
        .where('createdAt', isLessThan: Timestamp.fromDate(sampai))
        .get();

    double pendapatan = 0;
    int itemTerjual = 0;
    final Map<String, double> produkMap = {};

    for (final doc in snap.docs) {
      final d = doc.data();
      pendapatan += (d['total'] as num? ?? 0).toDouble();
      for (final item in (d['items'] as List? ?? [])) {
        itemTerjual += (item['qty'] as num? ?? 0).toInt();
        final nama = item['name'] ?? 'Unknown';
        produkMap[nama] =
            (produkMap[nama] ?? 0) + (item['subtotal'] as num? ?? 0).toDouble();
      }
    }

    final topProduk =
        (produkMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .map((e) => {'name': e.key, 'total': e.value})
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
        total += (doc.data()['total'] as num? ?? 0).toDouble();
      }
      result.add({
        'tanggal': hari,
        'label': [
          'Min',
          'Sen',
          'Sel',
          'Rab',
          'Kam',
          'Jum',
          'Sab',
        ][hari.weekday % 7],
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
        .where('stock', isLessThanOrEqualTo: batas)
        .get();

    final list = snap.docs
        .map(
          (doc) => {
            'id': doc.id,
            'nama': doc['name'] ?? '',
            'stok': (doc['stock'] as num? ?? 0).toInt(),
          },
        )
        .toList();

    list.sort((a, b) => (a['stok'] as int).compareTo(b['stok'] as int));
    return list;
  }

  // ── Semua transaksi + filter ──────────────────────
  Future<List<Map<String, dynamic>>> getTransaksi({
    DateTime? dari,
    DateTime? sampai,
    String? kasir,
  }) async {
    Query q = _db
        .collection('transaksi')
        .orderBy('createdAt', descending: true);
    if (dari != null) {
      q = q.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(dari),
      );
    }
    if (sampai != null) {
      q = q.where(
        'createdAt',
        isLessThan: Timestamp.fromDate(sampai.add(const Duration(days: 1))),
      );
    }
    if (kasir != null && kasir.isNotEmpty) {
      q = q.where('kasir', isEqualTo: kasir);
    }

    final snap = await q.get();
    return snap.docs.map((doc) {
      final d = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'total': (d['total'] as num? ?? 0).toDouble(),
        'totalLaba': (d['totalLaba'] as num? ?? 0).toDouble(),
        'kasir': d['kasir'] ?? '-',
        'createdAt': d['createdAt'],
        'items': d['items'] ?? [],
        'bayar': (d['bayar'] as num? ?? 0).toDouble(),
      };
    }).toList();
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

  Future<List<Map<String, dynamic>>> getAllProdukStok() async {
    final snap = await _db.collection('produk').get();

    final list = snap.docs
        .map((doc) => {
              'id': doc.id,
              'nama': doc['name'] ?? '',
              'stok': (doc['stock'] as num? ?? 0).toInt(),
            })
        .toList();

    // Urutkan: stok paling sedikit di atas
    list.sort((a, b) => (a['stok'] as int).compareTo(b['stok'] as int));
    return list;
  }
}