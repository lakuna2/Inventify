import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventify/theme.dart';

class Product {
  final String id, barcode, name, description, category;
  final int stock;
  final double hargaBeli, hargaJual;

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.description,
    required this.stock,
    required this.hargaBeli,
    required this.hargaJual,
    required this.category,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      barcode: d['barcode'] ?? '',
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      stock: (d['stock'] ?? 0).toInt(),
      hargaBeli: (d['hargaBeli'] ?? 0).toDouble(),
      hargaJual: (d['hargaJual'] ?? 0).toDouble(),
      category: d['category'] ?? 'Lainnya',
    );
  }

  Map<String, dynamic> toMap() => {
        'barcode': barcode,
        'name': name,
        'description': description,
        'stock': stock,
        'hargaBeli': hargaBeli,
        'hargaJual': hargaJual,
        'category': category,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  /// Laba per unit
  double get laba => hargaJual - hargaBeli;

  /// Persentase margin
  double get marginPersen => hargaBeli == 0 ? 0 : (laba / hargaBeli) * 100;

  String get stockStatus =>
      stock == 0 ? 'Habis' : stock <= 5 ? 'Stok tipis' : 'Tersedia';

  Color get stockColor =>
      stock == 0 ? AppColors.habis : stock <= 5 ? AppColors.stokTipis : AppColors.tersedia;

  String get initials {
    final w = name.trim().split(' ');
    return w.length >= 2
        ? '${w[0][0]}${w[1][0]}'.toUpperCase()
        : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color get avatarBg {
    const list = [Color(0xFFE3F2FD), Color(0xFFF3E5F5), Color(0xFFFFF8E1), Color(0xFFE8F5E9), Color(0xFFFCE4EC)];
    return list[name.codeUnitAt(0) % list.length];
  }

  Color get avatarFg {
    const list = [Color(0xFF1565C0), Color(0xFF6A1B9A), Color(0xFFE65100), Color(0xFF2E7D32), Color(0xFFC62828)];
    return list[name.codeUnitAt(0) % list.length];
  }
}