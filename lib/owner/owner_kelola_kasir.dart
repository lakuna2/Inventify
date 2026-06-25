// lib/pages/owner/kasir/owner_kelola_kasir.dart

import 'package:flutter/material.dart';
import 'package:inventify/models/kasir_model.dart';
import 'package:inventify/services/kasir_services.dart';
import 'package:inventify/theme.dart';
import 'package:inventify/widgets/owner/kelola_kasir/kasir_action_sheet.dart';
import 'package:inventify/widgets/owner/kelola_kasir/kasir_card.dart';
import 'package:inventify/widgets/owner/kelola_kasir/tambah_kasir_sheet.dart';
// import 'package:inventify/widgets/owner/kasir_shared_widgets.dart';

// ============================================================
// HALAMAN UTAMA — Entry point, hanya Scaffold + routing sheet
// ============================================================
class OwnerKelolaKasir extends StatelessWidget {
  const OwnerKelolaKasir({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kelola Kasir',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
      body: const _KasirListBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahSheet(context),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  static void _showTambahSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TambahKasirSheet(),
    );
  }
}

// ============================================================
// BODY — Stream list kasir + empty state
// ============================================================
class _KasirListBody extends StatelessWidget {
  const _KasirListBody();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<KasirModel>>(
      stream: KasirService.instance.streamKasir(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = snap.data ?? [];

        if (list.isEmpty) return const _KasirEmptyState();

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) => KasirCard(
            kasir: list[i],
            onTap: () => _showActionSheet(context, list[i]),
          ),
        );
      },
    );
  }

  static void _showActionSheet(BuildContext context, KasirModel kasir) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => KasirActionSheet(kasir: kasir),
    );
  }
}

// ============================================================
// EMPTY STATE — Ditampilkan saat belum ada kasir
// ============================================================
class _KasirEmptyState extends StatelessWidget {
  const _KasirEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada kasir',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tekan tombol + untuk menambahkan kasir baru.',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}