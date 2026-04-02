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
      home: Riwayat(),
    );
  }
}

class Riwayat extends StatefulWidget {
  const Riwayat({super.key});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  final List<double> salesData = [20, 40, 30, 80, 45, 50, 60];

  final List<Map<String, dynamic>> history = [
    {'name': 'Beras 5kg', 'qty': 2, 'total': 50000},
    {'name': 'Minyak Goreng', 'qty': 1, 'total': 18000},
    {'name': 'Gula Pasir', 'qty': 3, 'total': 36000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Histori'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChart(),
            const SizedBox(height: 16),
            _buildStockInfo(),
            const SizedBox(height: 16),
            Expanded(child: _buildHistoryList()),
          ],
        ),
      ),
    );
  }

  /* =========================
     GRAFIK PENJUALAN
     ========================= */
  Widget _buildChart() {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: LineChartPainter(salesData),
        child: Container(),
      ),
    );
  }

  /* =========================
     INFO STOK
     ========================= */
  Widget _buildStockInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Stok tersedia: 124 item',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  /* =========================
     LIST RIWAYAT
     ========================= */
  Widget _buildHistoryList() {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Qty: ${item['qty']}'),
                ],
              ),
              Text(
                'Rp ${item['total']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* =========================
   CUSTOM PAINTER GRAFIK
   ========================= */
class LineChartPainter extends CustomPainter {
  final List<double> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final maxValue = data.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < data.length; i++) {
      final x = size.width * (i / (data.length - 1));
      final y = size.height - (data[i] / maxValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
