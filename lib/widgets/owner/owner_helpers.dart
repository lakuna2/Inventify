import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

String rupiahFormat(double val) {
  final str = val.toStringAsFixed(0).split('');
  final buf = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
    buf.write(str[i]);
  }
  return 'Rp $buf';
}

Future<bool> confirmDelete(BuildContext context, {
  required String judul,
  required String isi,
  bool dangerous = false,
}) async {
  return await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(judul, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      content: Text(isi, style: const TextStyle(fontSize: 13)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: dangerous ? AppColors.habis : AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  ) ?? false;
}