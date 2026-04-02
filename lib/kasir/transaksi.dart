import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScanPage(),
  ));
}

/* =========================
   MODEL BARANG
   ========================= */
class Product {
  final String name;
  final int price;

  Product(this.name, this.price);
}

/* =========================
   STEP 1 - SCAN / INPUT
   ========================= */
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final List<Product> cart = [];

  void addDummyProduct() {
    setState(() {
      cart.add(Product('Beras 5kg', 50000));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, size: 200),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: addDummyProduct,
            child: const Text('Scan / Input Barang'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: cart.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartPage(cart: cart),
                      ),
                    );
                  },
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
  }
}

/* =========================
   STEP 2 - DETAIL TRANSAKSI
   ========================= */
class CartPage extends StatelessWidget {
  final List<Product> cart;

  const CartPage({super.key, required this.cart});

  int get total =>
      cart.fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  title: Text(item.name),
                  trailing: Text('Rp ${item.price}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Total: Rp $total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(total: total),
                      ),
                    );
                  },
                  child: const Text('Bayar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   STEP 3 - PEMBAYARAN
   ========================= */
class PaymentPage extends StatefulWidget {
  final int total;

  const PaymentPage({super.key, required this.total});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController controller = TextEditingController();
  int change = 0;

  void calculate() {
    final paid = int.tryParse(controller.text) ?? 0;
    setState(() {
      change = paid - widget.total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total: Rp ${widget.total}'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Uang Dibayar',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: calculate,
              child: const Text('Hitung'),
            ),
            const SizedBox(height: 12),
            Text(
              'Kembalian: Rp $change',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }
}
