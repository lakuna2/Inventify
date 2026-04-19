import 'package:flutter/material.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              header(),
              statsSection(),
              chartSection(),
              detailButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2A6E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard Pemilik",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Inventify",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Rabu, 02 Apr 2026",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ================= STAT CARDS =================
  Widget statsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.4, // <-- INI YANG FIX OVERFLOW
        children: const [
          StatCard("Pendapatan hari ini", "Rp 1,2jt"),
          StatCard("Transaksi", "24"),
          StatCard("Bulan ini", "Rp 28jt"),
          StatCard("Produk terjual", "342"),
        ],
      ),
    );
  }

  // ================= CHART =================
  Widget chartSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Penjualan 7 hari",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              ChartBar(40, "Sn"),
              ChartBar(60, "Sl"),
              ChartBar(35, "Rb"),
              ChartBar(70, "Km"),
              ChartBar(80, "Jm"),
              ChartBar(50, "Sb"),
              ChartBar(30, "Mg"),
            ],
          )
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget detailButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        child: const Text("Lihat detail laporan"),
      ),
    );
  }
}

// ================= STAT CARD =================
class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CHART BAR =================
class ChartBar extends StatelessWidget {
  final double height;
  final String label;

  const ChartBar(this.height, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 16,
          height: height,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}