import 'package:flutter/material.dart';
import 'package:inventify/models/transaksi_model.dart';
import 'package:inventify/services/transaksi_service.dart';
import 'package:inventify/widgets/transaksi_card.dart';
import 'package:inventify/widgets/transaksi_detail_sheet.dart';
import 'package:inventify/theme.dart';

class Riwayat extends StatefulWidget {
  const Riwayat({super.key});
  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  final _svc = TransactionService();
  String _query = '';
  DateTime? _filterDate;

  List<TransactionModel> _filter(List<TransactionModel> list) {
    return list.where((tx) {
      final matchQuery = _query.isEmpty ||
          tx.id.toLowerCase().contains(_query.toLowerCase()) ||
          tx.kasir.toLowerCase().contains(_query.toLowerCase());
      final matchDate = _filterDate == null ||
          (tx.createdAt.year == _filterDate!.year &&
           tx.createdAt.month == _filterDate!.month &&
           tx.createdAt.day == _filterDate!.day);
      return matchQuery && matchDate;
    }).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _filterDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.background,
        child: Column(children: [
          _Header(
            filterDate: _filterDate,
            onPickDate: _pickDate,
            onClearDate: () => setState(() => _filterDate = null),
          ),
          _SearchBar(onChanged: (v) => setState(() => _query = v)),
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: _svc.stream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                }
                if (snap.hasError) {
                  return _ErrorState(error: snap.error);
                }
                final list = _filter(snap.data ?? []);
                if (list.isEmpty) return const _EmptyState();
                return _TransactionList(list: list);
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final DateTime? filterDate;
  final VoidCallback onPickDate, onClearDate;
  const _Header({required this.filterDate, required this.onPickDate, required this.onClearDate});

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        const Expanded(
          child: Text('Riwayat', style: TextStyle(
            color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 20)),
        ),
        // Filter tanggal
        GestureDetector(
          onTap: onPickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: filterDate != null ? AppColors.secondary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: filterDate != null
                  ? AppColors.secondary
                  : AppColors.textGrey.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.calendar_today_outlined,
                size: 14,
                color: filterDate != null ? Colors.white : AppColors.textGrey),
              const SizedBox(width: 6),
              Text(filterDate != null ? _fmt(filterDate!) : 'Filter',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: filterDate != null ? Colors.white : AppColors.textGrey)),
              if (filterDate != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onClearDate,
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final void Function(String) onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari ID transaksi atau kasir...',
          hintStyle: TextStyle(color: AppColors.textDark.withValues(alpha: 0.4), fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> list;
  const _TransactionList({required this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: list.length,
      itemBuilder: (_, i) => TransactionCard(
        tx: list[i],
        onTap: () => TransactionDetailSheet.show(context, list[i]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textGrey.withValues(alpha: 0.4)),
      const SizedBox(height: 12),
      Text('Belum ada riwayat', style: TextStyle(
        fontSize: 15, color: AppColors.textDark.withValues(alpha: 0.4))),
    ]));
  }
}

class _ErrorState extends StatelessWidget {
  final Object? error;
  const _ErrorState({this.error});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Gagal memuat\n$error',
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.textDark.withValues(alpha: 0.5))));
  }
}