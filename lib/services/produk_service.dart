import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/models/produk_model.dart';

class ProductService {
  final _ref = FirebaseFirestore.instance.collection('produk');

  Stream<List<Product>> stream() =>
      _ref.orderBy('name').snapshots().map(
            (s) => s.docs.map(Product.fromFirestore).toList(),
          );

  Future<Product?> getByBarcode(String barcode) async {
    final s = await _ref.where('barcode', isEqualTo: barcode).limit(1).get();
    return s.docs.isEmpty ? null : Product.fromFirestore(s.docs.first);
  }

  Future<void> tambah(Product p) =>
      _ref.add({...p.toMap(), 'createdAt': FieldValue.serverTimestamp()});

  Future<void> edit(Product p) => _ref.doc(p.id).update(p.toMap());

  Future<void> hapus(String id) => _ref.doc(id).delete();
}