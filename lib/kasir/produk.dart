import 'package:flutter/material.dart';
import 'package:inventify/models/produk_model.dart';
import 'package:inventify/services/produk_service.dart';
import 'package:inventify/widgets/produk_card.dart';
import 'package:inventify/widgets/produk_form.dart';
import 'package:inventify/theme.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});
  @override
  State<Produk> createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  final _svc = ProductService();
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _cat = 'Semua';


  List<Product> _filter(List<Product> list) => list.where((p) =>
    p.name.toLowerCase().contains(_query.toLowerCase()) &&
    (_cat == 'Semua' || p.category == _cat)
  ).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.background,
        child: Column(children: [
          _Header(onAdd: () => ProductForm.show(context)),
          _SearchBar(ctrl: _searchCtrl, onChanged: (v) => setState(() => _query = v)),
          _CategoryFilter(selected: _cat, onSelect: (c) => setState(() => _cat = c)),
          Expanded(child: _ProductList(stream: _svc.stream(), filter: _filter)),
        ]),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onAdd;
  const _Header({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        const Expanded(child: Text('Data Barang',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 20))),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final void Function(String) onChanged;
  const _SearchBar({required this.ctrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari barang...',
          hintStyle: TextStyle(color: AppColors.textDark.withValues(alpha: 0.4)),
          prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;
  static const _cats = ['Semua', 'Makanan', 'Minuman', 'Snack', 'Lainnya'];
  const _CategoryFilter({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: _cats.length,
        itemBuilder: (_, i) {
          final c = _cats[i];
          final active = c == selected;
          return GestureDetector(
            onTap: () => onSelect(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: active ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
              ),
              child: Center(child: Text(c,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.textDark.withValues(alpha: 0.6),
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ))),
            ),
          );
        },
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final Stream<List<Product>> stream;
  final List<Product> Function(List<Product>) filter;
  const _ProductList({required this.stream, required this.filter});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
        }
        if (snap.hasError) {
          return Center(child: Text('Gagal memuat\n${snap.error}',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDark.withValues(alpha: 0.5))));
        }
        final list = filter(snap.data ?? []);
        if (list.isEmpty) return _empty();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: list.length,
          itemBuilder: (_, i) => ProductCard(product: list[i]),
        );
      },
    );
  }

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.textGrey.withValues(alpha: 0.4)),
    const SizedBox(height: 12),
    Text('Belum ada barang', style: TextStyle(color: AppColors.textDark.withValues(alpha: 0.4), fontSize: 15)),
  ]));
}