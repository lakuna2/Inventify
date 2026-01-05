import 'package:flutter/material.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  State<Produk> createState() => _ProdukState();
}

class Product {
  final String name;
  final String description;
  int stock;

  Product({
    required this.name,
    required this.description,
    required this.stock,
  });
}

class _ProdukState extends State<Produk> {
  
  
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}