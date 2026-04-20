import 'package:flutter/material.dart';
import 'package:inventify/models/transaksi_model.dart';
import 'package:inventify/models/produk_model.dart';

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];
 
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get totalQty => _items.fold(0, (s, i) => s + i.qty);
  double get total => _items.fold(0.0, (s, i) => s + i.subtotal);
 
  /// Tambah produk ke keranjang.
  /// Mengembalikan false jika stok tidak mencukupi.
  bool addProduct(Product p) {
    final idx = _items.indexWhere((i) => i.productId == p.id);
    if (idx >= 0) {
      if (_items[idx].qty >= p.stock) return false; // stok habis
      _items[idx].qty++;
    } else {
      if (p.stock <= 0) return false;
      _items.add(CartItem(
        productId: p.id,
        barcode: p.barcode,
        name: p.name,
        hargaJual: p.hargaJual,
        hargaBeli: p.hargaBeli,
        maxStock: p.stock,
      ));
    }
    notifyListeners();
    return true;
  }
 
  /// Increment qty. Mengembalikan false jika sudah maks.
  bool increment(String productId) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx < 0) return false;
    if (_items[idx].qty >= _items[idx].maxStock) return false;
    _items[idx].qty++;
    notifyListeners();
    return true;
  }
 
  void decrement(String productId) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx < 0) return;
    if (_items[idx].qty <= 1) {
      _items.removeAt(idx);
    } else {
      _items[idx].qty--;
    }
    notifyListeners();
  }
 
  void remove(String productId) {
    _items.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }
 
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
 