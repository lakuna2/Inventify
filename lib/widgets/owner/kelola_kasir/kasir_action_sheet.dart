// lib/pages/owner/kasir/widgets/kasir_action_sheet.dart

import 'package:flutter/material.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:inventify/models/kasir_model.dart';
import 'package:inventify/services/kasir_services.dart';
import 'package:inventify/theme.dart';
import 'package:inventify/widgets/owner/kelola_kasir/kasir_shared_widget.dart';


class KasirActionSheet extends StatelessWidget {
  final KasirModel kasir;
  const KasirActionSheet({super.key, required this.kasir});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KasirSheetHandle(),
            _buildHeader(),
            const Divider(height: 1),
            const SizedBox(height: 8),
            KasirActionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus Kasir',
              color: Colors.redAccent,
              bgColor: Colors.red.withValues(alpha: 0.07),
              onTap: () => _konfirmasiHapus(context),
            ),
            KasirActionTile(
              icon: Icons.close_rounded,
              label: 'Batal',
              color: AppColors.textSecondary,
              bgColor: AppColors.inputBg,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          KasirAvatar(initials: kasir.initials),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kasir.nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                kasir.email,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _konfirmasiHapus(BuildContext context) async {
    Navigator.pop(context);

    // showDialog mengembalikan bool? — aman untuk dicek
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Kasir?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Akun "${kasir.nama}" akan dihapus.\nTindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await KasirService.instance.hapusKasir(kasir.uid);
      CustomQuickAlert.success(
        title: 'Kasir Dihapus',
        message: 'Akun "${kasir.nama}" berhasil dihapus.',
        confirmBtnColor: AppColors.primary,
      );
    } catch (e) {
      CustomQuickAlert.error(
        title: 'Gagal Menghapus',
        message: e.toString(),
        confirmText: 'Tutup',
        confirmBtnColor: Colors.redAccent,
      );
    }
  }
}