import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId, barcode, name;
  final double hargaJual, hargaBeli;
  final int maxStock; // batas stok dari Firestore
  int qty;

  CartItem({
    required this.productId,
    required this.barcode,
    required this.name,
    required this.hargaJual,
    required this.hargaBeli,
    required this.maxStock,
    this.qty = 1,
  });

  bool get isMaxQty => qty >= maxStock;

  double get subtotal => hargaJual * qty;
  double get labaSubtotal => (hargaJual - hargaBeli) * qty;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'barcode': barcode,
        'name': name,
        'hargaJual': hargaJual,
        'hargaBeli': hargaBeli,
        'qty': qty,
        'subtotal': subtotal,
      };
}

class TransactionModel {
  final String id;
  final List<CartItem> items;
  final double total, bayar, kembalian, totalLaba;
  final DateTime createdAt;
  final String kasir;

  TransactionModel({
    required this.id,
    required this.items,
    required this.total,
    required this.bayar,
    required this.kembalian,
    required this.totalLaba,
    required this.createdAt,
    required this.kasir,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      items: (d['items'] as List<dynamic>? ?? []).map((e) => CartItem(
        productId: e['productId'] ?? '',
        barcode: e['barcode'] ?? '',
        name: e['name'] ?? '',
        hargaJual: (e['hargaJual'] ?? 0).toDouble(),
        hargaBeli: (e['hargaBeli'] ?? 0).toDouble(),
        maxStock: (e['qty'] ?? 1).toInt(), // historis, tidak perlu validasi
        qty: (e['qty'] ?? 1).toInt(),
      )).toList(),
      total: (d['total'] ?? 0).toDouble(),
      bayar: (d['bayar'] ?? 0).toDouble(),
      kembalian: (d['kembalian'] ?? 0).toDouble(),
      totalLaba: (d['totalLaba'] ?? 0).toDouble(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      kasir: d['kasir'] ?? '',
    );
  }
}
// Extension untuk konversi ke Map saat export laporan
extension TransactionModelExport on TransactionModel {
  Map<String, dynamic> toExportMap() => {
    'id': id,                          // ← kode transaksi (doc.id Firestore)
    'createdAt': createdAt,
    'kasir': kasir,
    'total': total,
    'totalLaba': totalLaba,
    'items': items.map((i) => i.toMap()).toList(),
  };
}