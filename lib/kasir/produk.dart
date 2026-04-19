import 'package:flutter/material.dart';

/* =======================
   KONSTANTA WARNA
   ======================= */
class AppColors {
  static const primary = Color(0xFF1B2B5E);
  static const secondary = Color(0xFF00BCD4);
  static const background = Color(0xFFF5F6FA);
  static const cardBg = Color(0xFFFFFDE7);
  static const tersedia = Color(0xFF00BCD4);
  static const stokTipis = Color(0xFFFFA726);
  static const habis = Color(0xFFEF5350);
  static const textDark = Color(0xFF1B2B5E);
  static const textGrey = Color(0xFF90A4AE);
}

/* =======================
   MODEL DATA PRODUK
   ======================= */
class Product {
  String id;
  String name;
  String description;
  int stock;
  double price;
  String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.stock,
    required this.price,
    required this.category,
  });

  String get initials {
    final words = name.trim().split(' ');
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get stockStatus {
    if (stock == 0) return 'Habis';
    if (stock <= 5) return 'Stok tipis';
    return 'Tersedia';
  }

  Color get stockColor {
    if (stock == 0) return AppColors.habis;
    if (stock <= 5) return AppColors.stokTipis;
    return AppColors.tersedia;
  }

  Color get avatarColor {
    const colors = [
      Color(0xFFE3F2FD),
      Color(0xFFF3E5F5),
      Color(0xFFFFF8E1),
      Color(0xFFE8F5E9),
      Color(0xFFFCE4EC),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  Color get avatarTextColor {
    const colors = [
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFFE65100),
      Color(0xFF2E7D32),
      Color(0xFFC62828),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

/* =======================
   HALAMAN PRODUK
   ======================= */
class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  State<Produk> createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Semua';

  // Menyimpan id produk yang sedang terbuka swipe-nya
  String? _openSwipeId;

  final List<String> _categories = [
    'Semua', 'Makanan', 'Minuman', 'Snack', 'Lainnya',
  ];

  final List<Product> _products = [
    Product(id: '1', name: 'Indomie Goreng', description: 'Mie goreng instan rasa ayam bawang.', stock: 150, price: 3500, category: 'Makanan'),
    Product(id: '2', name: 'Aqua 600ml', description: 'Air mineral kemasan botol 600ml.', stock: 80, price: 4000, category: 'Minuman'),
    Product(id: '3', name: 'Roti Tawar', description: 'Roti tawar segar kemasan 10 lembar.', stock: 5, price: 12000, category: 'Makanan'),
    Product(id: '4', name: 'Kopi Sachet', description: 'Kopi sachet 3in1, nikmat dan praktis.', stock: 0, price: 2000, category: 'Minuman'),
    Product(id: '5', name: 'Chitato', description: 'Keripik kentang renyah berbagai rasa.', stock: 30, price: 8500, category: 'Snack'),
  ];

  List<Product> get _filtered => _products.where((p) {
        final matchSearch = p.name.toLowerCase().contains(_query.toLowerCase());
        final matchCategory = _selectedCategory == 'Semua' || p.category == _selectedCategory;
        return matchSearch && matchCategory;
      }).toList();

  String _formatRupiah(double value) {
    final str = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  // Tutup semua swipe yang terbuka
  void _closeAllSwipe() {
    if (_openSwipeId != null) {
      setState(() => _openSwipeId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        // Tap di mana saja di luar card → tutup swipe
        onTap: _closeAllSwipe,
        child: Container(
          color: AppColors.background,
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildCategoryFilter(),
              Expanded(
                child: _filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) =>
                            _buildSwipeCard(_filtered[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* =======================
     HEADER
     ======================= */
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Data Barang',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _openForm(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  /* =======================
     SEARCH BAR
     ======================= */
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Cari barang...',
          hintStyle: TextStyle(color: AppColors.textDark.withOpacity(0.4)),
          prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  /* =======================
     FILTER KATEGORI
     ======================= */
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () {
              _closeAllSwipe();
              setState(() => _selectedCategory = cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textDark.withOpacity(0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /* =======================
     SWIPE CARD MANUAL
     Geser kiri → tahan → tombol muncul & bisa diklik
     ======================= */
  Widget _buildSwipeCard(Product product) {
    final isOpen = _openSwipeId == product.id;
    // Lebar tombol aksi (Edit + Hapus + gap)
    const double actionWidth = 148.0;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Geser ke kiri (velocity negatif) → buka
        // Geser ke kanan (velocity positif) → tutup
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -100) {
            setState(() => _openSwipeId = product.id);
          } else if (details.primaryVelocity! > 100) {
            setState(() => _openSwipeId = null);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        // Clip agar tombol di belakang tidak keluar area card
        child: Stack(
          children: [
            // Tombol Edit & Hapus di belakang (kanan)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionButton(
                      icon: Icons.edit_outlined,
                      color: AppColors.secondary,
                      label: 'Edit',
                      onTap: () {
                        setState(() => _openSwipeId = null);
                        _openForm(product: product);
                      },
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      icon: Icons.delete_outline,
                      color: AppColors.habis,
                      label: 'Hapus',
                      onTap: () {
                        setState(() => _openSwipeId = null);
                        _confirmDelete(product);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Card produk yang bergeser ke kiri
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                isOpen ? -actionWidth : 0,
                0,
                0,
              ),
              child: _buildProductCard(product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 72,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /* =======================
     CARD PRODUK
     ======================= */
  Widget _buildProductCard(Product product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: product.avatarColor, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                product.initials,
                style: TextStyle(color: product.avatarTextColor, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 3),
                Text('Stok: ${product.stock} pcs', style: TextStyle(color: AppColors.textDark.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatRupiah(product.price), style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(product.stockStatus, style: TextStyle(color: product.stockColor, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  /* =======================
     EMPTY STATE
     ======================= */
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textGrey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Belum ada barang', style: TextStyle(color: AppColors.textDark.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /* =======================
     FORM TAMBAH / EDIT
     ======================= */
  void _openForm({Product? product}) {
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toStringAsFixed(0) ?? '');
    String selectedCat = product?.category ?? 'Makanan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEdit ? 'Edit Barang' : 'Tambah Barang',
                  style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                _formField(nameCtrl, 'Nama Barang', Icons.inventory_2_outlined),
                const SizedBox(height: 12),
                _formField(descCtrl, 'Deskripsi', Icons.notes_outlined, maxLines: 2),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _formField(stockCtrl, 'Stok', Icons.numbers_outlined, numeric: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _formField(priceCtrl, 'Harga (Rp)', Icons.attach_money, numeric: true)),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: const Icon(Icons.category_outlined, color: AppColors.secondary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary)),
                  ),
                  items: ['Makanan', 'Minuman', 'Snack', 'Lainnya']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedCat = v!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          setState(() {
                            if (isEdit) {
                              product
                                ..name = name
                                ..description = descCtrl.text.trim()
                                ..stock = int.tryParse(stockCtrl.text) ?? 0
                                ..price = double.tryParse(priceCtrl.text) ?? 0
                                ..category = selectedCat;
                            } else {
                              _products.add(Product(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: name,
                                description: descCtrl.text.trim(),
                                stock: int.tryParse(stockCtrl.text) ?? 0,
                                price: double.tryParse(priceCtrl.text) ?? 0,
                                category: selectedCat,
                              ));
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(isEdit ? 'Simpan' : 'Tambah', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1, bool numeric = false}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary)),
      ),
    );
  }

  /* =======================
     KONFIRMASI HAPUS
     ======================= */
  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Barang?', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        content: Text('Apakah kamu yakin ingin menghapus "${product.name}"?', style: TextStyle(color: AppColors.textDark.withOpacity(0.6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _products.removeWhere((p) => p.id == product.id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.habis,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}