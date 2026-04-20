import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

class HistoriFilter extends StatefulWidget {
  final DateTime? dari;
  final DateTime? sampai;
  final String kasir;

  const HistoriFilter({super.key, this.dari, this.sampai, this.kasir = ''});

  @override
  State<HistoriFilter> createState() => _HistoriFilterState();
}

class _HistoriFilterState extends State<HistoriFilter> {
  late DateTime? _dari;
  late DateTime? _sampai;
  late final _kasirCtrl = TextEditingController(text: widget.kasir);

  @override
  void initState() {
    super.initState();
    _dari = widget.dari;
    _sampai = widget.sampai;
  }

  Future<void> _pick(bool isDari) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isDari ? _dari : _sampai) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!),
    );
    if (picked != null) setState(() => isDari ? _dari = picked : _sampai = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Filter Transaksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: _datePicker('Dari', _dari, () => _pick(true))),
            const SizedBox(width: 10),
            Expanded(child: _datePicker('Sampai', _sampai, () => _pick(false))),
          ]),
          const SizedBox(height: 10),

          TextField(
            controller: _kasirCtrl,
            decoration: InputDecoration(
              labelText: 'Nama Kasir',
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.secondary),
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.secondary)),
            ),
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context, {'dari': null, 'sampai': null, 'kasir': ''}),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Reset', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'dari': _dari, 'sampai': _sampai, 'kasir': _kasirCtrl.text.trim()}),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0),
              child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _datePicker(String label, DateTime? val, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(Icons.calendar_today_outlined, size: 14,
            color: val != null ? AppColors.secondary : AppColors.textGrey),
          const SizedBox(width: 7),
          Text(val != null ? '${val.day}/${val.month}/${val.year}' : label,
            style: TextStyle(fontSize: 12,
              color: val != null ? AppColors.textDark : AppColors.textGrey,
              fontWeight: val != null ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    );
  }
}