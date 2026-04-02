import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Produk(),
    );
  }
}

/* =======================
   MODEL DATA PRODUK
   ======================= */
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

/* =======================
   HALAMAN PRODUK
   ======================= */
class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  State<Produk> createState() => _ProductPageState();
}

class _ProductPageState extends State<Produk> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<Product> _products = [
    Product(
      name: 'XXXX XXX',
      description: 'Vorem ipsum dolor sit amet, consectetur adipiscing elit.',
      stock: 8,
    ),
    Product(
      name: 'XXXXX',
      description: 'Vorem ipsum dolor sit amet, consectetur adipiscing elit.',
      stock: 3,
    ),
    Product(
      name: 'XXXXX',
      description: 'Vorem ipsum dolor sit amet, consectetur adipiscing elit.',
      stock: 5,
    ),
    Product(
      name: 'XXXXXX',
      description: 'Vorem ipsum dolor sit amet, consectetur adipiscing elit.',
      stock: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((product) {
      return product.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: _buildSearchAppBar(),
      floatingActionButton: _buildAddProductButton(),
      body: Column(
        children: [
          _buildFilterPlaceholder(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(filteredProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /* =======================
     APPBAR + SEARCH
     ======================= */
  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const BackButton(color: Colors.black),
      title: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _query = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /* =======================
     FILTER PLACEHOLDER
     ======================= */
  Widget _buildFilterPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(
          4,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* =======================
     CARD PRODUK
     ======================= */
  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined, size: 18),
                    onPressed: () {
                      setState(() {
                        product.stock++;
                      });
                    },
                  ),
                  Text(product.stock.toString()),
                  IconButton(
                    icon: const Icon(
                      Icons.indeterminate_check_box_outlined,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        if (product.stock > 0) {
                          product.stock--;
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /* =======================
     FLOATING ADD BUTTON
     ======================= */
  Widget _buildAddProductButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // nanti: buka halaman tambah produk
      },
      backgroundColor: Colors.blue,
      icon: const Icon(Icons.add),
      label: const Text('Tambah Produk'),
    );
  }
}
