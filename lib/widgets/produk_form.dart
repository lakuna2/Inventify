import 'package:flutter/material.dart';
import 'package:inventify/models/produk_model.dart';
import 'package:inventify/services/produk_service.dart';
import 'package:inventify/widgets/barcode_scanner.dart';
import 'package:inventify/theme.dart';

class ProductForm {
  static void show(BuildContext context, {Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductFormSheet(product: product),
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  final Product? product;
  const _ProductFormSheet({this.product});
  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _svc = ProductService();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _beliCtrl = TextEditingController();
  final _jualCtrl = TextEditingController();

  String _barcode = '';
  String _cat = 'Makanan';
  bool _scanned = false;
  bool _loading = false;

  // Validation errors
  String? _nameError;
  String? _descError;
  String? _stockError;
  String? _beliError;
  String? _jualError;

  bool get _isEdit => widget.product != null;
  static const _cats = [
    'Makanan',
    'Minuman',
    'Snack',
    'Rokok',
    'ATK',
    'Sembako',
    'Bumbu Dapur',
    'Rumah Tangga',
    'Lainnya',
  ];

  // Preview laba realtime
  double get _previewLaba =>
      (double.tryParse(_jualCtrl.text) ?? 0) -
      (double.tryParse(_beliCtrl.text) ?? 0);
  double get _previewMargin {
    final beli = double.tryParse(_beliCtrl.text) ?? 0;
    return beli == 0 ? 0 : (_previewLaba / beli) * 100;
  }

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.product!;
      _barcode = p.barcode;
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description;
      _stockCtrl.text = p.stock.toString();
      _beliCtrl.text = p.hargaBeli.toStringAsFixed(0);
      _jualCtrl.text = p.hargaJual.toStringAsFixed(0);
      _cat = p.category;
      _scanned = true;
    }
    // Trigger rebuild saat harga berubah
    _beliCtrl.addListener(() => setState(() {}));
    _jualCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    _beliCtrl.dispose();
    _jualCtrl.dispose();
    super.dispose();
  }

  Future<void> _onBarcode(String code) async {
    final existing = await _svc.getByBarcode(code);
    if (!mounted) return;
    if (existing != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${existing.name}" sudah terdaftar'),
          backgroundColor: AppColors.stokTipis,
          action: SnackBarAction(
            label: 'Edit',
            textColor: Colors.white,
            onPressed: () => ProductForm.show(context, product: existing),
          ),
        ),
      );
      return;
    }
    setState(() {
      _barcode = code;
      _scanned = true;
    });
  }

  bool _validate() {
    bool valid = true;
    final beli = double.tryParse(_beliCtrl.text) ?? 0;
    final jual = double.tryParse(_jualCtrl.text) ?? 0;
    setState(() {
      _nameError = _nameCtrl.text.trim().isEmpty ? 'Nama barang wajib diisi' : null;
      _descError = _descCtrl.text.trim().isEmpty ? 'Deskripsi wajib diisi' : null;
      _stockError = _stockCtrl.text.trim().isEmpty ? 'Stok wajib diisi' : null;
      _beliError = _beliCtrl.text.trim().isEmpty
          ? 'Harga beli wajib diisi'
          : (beli <= 0 ? 'Harga beli harus lebih dari 0' : null);
      _jualError = _jualCtrl.text.trim().isEmpty
          ? 'Harga jual wajib diisi'
          : (jual <= 0
              ? 'Harga jual harus lebih dari 0'
              : (jual <= beli ? 'Harga jual harus lebih besar dari harga beli' : null));
      valid = _nameError == null &&
          _descError == null &&
          _stockError == null &&
          _beliError == null &&
          _jualError == null;
    });
    return valid;
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_validate()) {
      _showWarning('Semua form wajib diisi sebelum menyimpan!');
      return;
    }
    setState(() => _loading = true);
    final p = Product(
      id: widget.product?.id ?? '',
      barcode: _barcode,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      stock: int.tryParse(_stockCtrl.text) ?? 0,
      hargaBeli: double.tryParse(_beliCtrl.text) ?? 0,
      hargaJual: double.tryParse(_jualCtrl.text) ?? 0,
      category: _cat,
    );
    try {
      _isEdit ? await _svc.edit(p) : await _svc.tambah(p);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: AppColors.habis,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEdit ? 'Edit Barang' : 'Tambah Barang',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // STEP 1 — Scan
              if (!_scanned) ...[
                BarcodeScanner(onDetected: _onBarcode),
                const SizedBox(height: 12),
                _ManualBarcodeInput(onSubmit: _onBarcode),
              ],

              // STEP 2 — Form
              if (_scanned) ...[
                _BarcodeBadge(
                  barcode: _barcode,
                  onReset: _isEdit
                      ? null
                      : () => setState(() {
                          _scanned = false;
                          _barcode = '';
                        }),
                ),
                const SizedBox(height: 12),
                _field(_nameCtrl, 'Nama Barang', Icons.inventory_2_outlined, errorText: _nameError, onChanged: (_) => setState(() => _nameError = null)),
                const SizedBox(height: 10),
                _field(_descCtrl, 'Deskripsi', Icons.notes_outlined, lines: 2, errorText: _descError, onChanged: (_) => setState(() => _descError = null)),
                const SizedBox(height: 10),

                // Stok + Kategori
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        _stockCtrl,
                        'Stok',
                        Icons.numbers_outlined,
                        numeric: true,
                        errorText: _stockError,
                        onChanged: (_) => setState(() => _stockError = null),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _cat,
                        decoration: _decor('Kategori', Icons.category_outlined),
                        // Tambahkan ini:
                        dropdownColor:
                            Colors.white, // warna background popup menu
                        style: const TextStyle(
                          color: AppColors
                              .textDark, // warna teks item yang dipilih
                          fontSize: 14,
                        ),
                        items: _cats
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                  ),
                                ), // warna teks di list
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _cat = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Harga Beli + Harga Jual
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        _beliCtrl,
                        'Harga Beli',
                        Icons.arrow_downward_rounded,
                        numeric: true,
                        errorText: _beliError,
                        onChanged: (_) => setState(() => _beliError = null),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _field(
                        _jualCtrl,
                        'Harga Jual',
                        Icons.arrow_upward_rounded,
                        numeric: true,
                        errorText: _jualError,
                        onChanged: (_) => setState(() => _jualError = null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Preview laba realtime
                _LabaPreview(laba: _previewLaba, margin: _previewMargin),
                const SizedBox(height: 20),

                _ActionButtons(
                  isEdit: _isEdit,
                  loading: _loading,
                  onCancel: () => Navigator.pop(context),
                  onSubmit: _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    int lines = 1,
    bool numeric = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        controller: c,
        maxLines: lines,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: _decor(label, icon, errorText: errorText),
        onChanged: onChanged,
      ),
      if (errorText != null) ...[
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            errorText,
            style: const TextStyle(
              color: AppColors.habis,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ],
  );

  InputDecoration _decor(String label, IconData icon, {String? errorText}) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: AppColors.secondary),
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: errorText != null ? AppColors.habis : AppColors.secondary,
      ),
    ),
  );
}

// ── Sub-widgets form ───────────────────────────────────────────────────────

class _LabaPreview extends StatelessWidget {
  final double laba, margin;
  const _LabaPreview({required this.laba, required this.margin});

  static String _rp(double v) {
    final s = v.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      if (++c % 3 == 0 && i != 0) buf.write('.');
    }
    return '${v < 0 ? '-' : ''}Rp ${buf.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = laba >= 0;
    final color = isPositive ? AppColors.tersedia : AppColors.habis;
    final bg = isPositive
        ? AppColors.tersedia.withValues(alpha: 0.08)
        : AppColors.habis.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            'Estimasi laba/unit  ',
            style: TextStyle(fontSize: 12, color: color),
          ),
          const Spacer(),
          Text(
            _rp(laba),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '(${margin.toStringAsFixed(1)}%)',
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _BarcodeBadge extends StatelessWidget {
  final String barcode;
  final VoidCallback? onReset;
  const _BarcodeBadge({required this.barcode, this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.qr_code_rounded,
            color: AppColors.secondary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Barcode',
                  style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                ),
                Text(
                  barcode,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          if (onReset != null)
            GestureDetector(
              onTap: onReset,
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.secondary,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

class _ManualBarcodeInput extends StatelessWidget {
  final void Function(String) onSubmit;
  _ManualBarcodeInput({required this.onSubmit});
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: 'Atau input barcode manual...',
              hintStyle: TextStyle(
                color: AppColors.textDark.withValues(alpha: 0.4),
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (_ctrl.text.trim().isNotEmpty) onSubmit(_ctrl.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'OK',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isEdit, loading;
  final VoidCallback onCancel, onSubmit;
  const _ActionButtons({
    required this.isEdit,
    required this.loading,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: loading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _isEdit ? 'Simpan' : 'Tambah',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }

  bool get _isEdit => isEdit;
}
