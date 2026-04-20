import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

class ProfilHeader extends StatelessWidget {
  final String nama, email;
  final DateTime? joinDate;

  const ProfilHeader({
    super.key,
    required this.nama,
    required this.email,
    this.joinDate,
  });

  String get _inisial {
    final w = nama.trim().split(' ');
    return w.length >= 2
        ? '${w[0][0]}${w[1][0]}'.toUpperCase()
        : nama.substring(0, nama.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get _joinStr {
    if (joinDate == null) return '-';
    const bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return '${bulan[joinDate!.month - 1]} ${joinDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Profil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 16),

        // Avatar + info
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Stack(children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEEEDFE),
                border: Border.all(color: const Color(0xFF7F77DD), width: 2),
              ),
              child: Center(child: Text(_inisial,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF3C3489)))),
            ),
            Positioned(bottom: 0, right: 0,
              child: Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF7F77DD),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, size: 10, color: Colors.white),
              )),
          ]),
          const SizedBox(width: 14),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nama,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(email,
              style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.5))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Kasir',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3C3489))),
            ),
          ])),

          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Bergabung', style: TextStyle(fontSize: 10, color: AppColors.textGrey.withValues(alpha: 0.8))),
            const SizedBox(height: 2),
            Text(_joinStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ]),
        ]),

        const SizedBox(height: 16),

        // Statistik ringkas
        Row(children: [
          _stat('Transaksi', '—'),
          _divider(),
          _stat('Produk Input', '—'),
          _divider(),
          _stat('Hari Aktif', '—'),
        ]),
      ]),
    );
  }

  Widget _stat(String label, String val) => Expanded(child: Column(children: [
    Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(fontSize: 10, color: AppColors.textGrey.withValues(alpha: 0.8)), textAlign: TextAlign.center),
  ]));

  Widget _divider() => Container(
    width: 0.5, height: 32,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: AppColors.textGrey.withValues(alpha: 0.2),
  );
}