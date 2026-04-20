import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/models/transaksi_model.dart';

class TransactionService {
  final _db = FirebaseFirestore.instance;

  Future<String> simpan({
    required List<CartItem> items,
    required double total,
    required double bayar,
    required String kasir,
  }) async {
    final kembalian = bayar - total;
    // ignore: avoid_types_as_parameter_names
    final totalLaba = items.fold(0.0, (sum, i) => sum + i.labaSubtotal);

    // Jalankan batch: simpan transaksi + kurangi stok produk
    final batch = _db.batch();

    final txRef = _db.collection('transaksi').doc();
    batch.set(txRef, {
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'bayar': bayar,
      'kembalian': kembalian,
      'totalLaba': totalLaba,
      'kasir': kasir,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Kurangi stok tiap produk
    for (final item in items) {
      final prodRef = _db.collection('produk').doc(item.productId);
      batch.update(prodRef, {'stock': FieldValue.increment(-item.qty)});
    }

    await batch.commit();
    return txRef.id;
  }

  Stream<List<TransactionModel>> stream() {
    return _db
        .collection('transaksi')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(TransactionModel.fromFirestore).toList());
  }
}