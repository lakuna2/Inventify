import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:inventify/services/printer_service.dart';
import 'package:inventify/theme.dart';

/// Sheet setup printer yang dibuka dari halaman Profil.
/// User bisa: pilih printer, atur info toko, dan preview tampilan resi.
class PrinterSetupSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PrinterSetupContent(),
    );
  }
}

class _PrinterSetupContent extends StatefulWidget {
  const _PrinterSetupContent();

  @override
  State<_PrinterSetupContent> createState() => _PrinterSetupContentState();
}

class _PrinterSetupContentState extends State<_PrinterSetupContent>
    with SingleTickerProviderStateMixin {
  final _printer = PrinterService();
  late final TabController _tab;

  List<BtDevice> _devices = [];
  bool _scanning = false;
  bool _connecting = false;
  String? _error;

  // Controller info toko
  late final TextEditingController _namaTokoCtrl;
  late final TextEditingController _alamatCtrl;
  late final TextEditingController _teleponCtrl;
  bool _savingInfo = false;

  // Paper size
  bool _is80mm = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _namaTokoCtrl = TextEditingController(text: _printer.storeName);
    _alamatCtrl   = TextEditingController(text: _printer.storeAddress);
    _teleponCtrl  = TextEditingController(text: _printer.storePhone);
    _is80mm       = _printer.paperSize == PaperSize.mm80;
    _scan();
  }

  @override
  void dispose() {
    _tab.dispose();
    _namaTokoCtrl.dispose();
    _alamatCtrl.dispose();
    _teleponCtrl.dispose();
    super.dispose();
  }

  // ─── Scan ───────────────────────────────────────────────────────────────
  Future<void> _scan() async {
    setState(() { _scanning = true; _error = null; _devices = []; });
    try {
      final found = await _printer.scanPairedDevices();
      if (!mounted) return;
      setState(() => _devices = found);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  // ─── Connect ────────────────────────────────────────────────────────────
  Future<void> _connect(BtDevice device) async {
    setState(() => _connecting = true);
    try {
      final ok = await _printer.connect(device);
      if (!mounted) return;
      if (ok) {
        setState(() {});
        _snack('Terhubung ke ${device.name}', ok: true);
      } else {
        _snack('Gagal terhubung ke ${device.name}', ok: false);
      }
    } catch (e) {
      if (mounted) _snack('Error: $e', ok: false);
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _disconnect() async {
    await _printer.disconnect();
    if (mounted) setState(() {});
  }

  // ─── Simpan info toko ───────────────────────────────────────────────────
  void _simpanInfo() {
    setState(() => _savingInfo = true);
    _printer.storeName    = _namaTokoCtrl.text.trim().isEmpty
        ? 'INVENTIFY'
        : _namaTokoCtrl.text.trim();
    _printer.storeAddress = _alamatCtrl.text.trim();
    _printer.storePhone   = _teleponCtrl.text.trim();
    _printer.paperSize    = _is80mm ? PaperSize.mm80 : PaperSize.mm58;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _savingInfo = false);
        _snack('Informasi toko disimpan', ok: true);
      }
    });
  }

  void _snack(String msg, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? AppColors.tersedia : AppColors.habis,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ─── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // ── Header fixed ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),

              // Judul + status koneksi
              Row(children: [
                const Expanded(
                  child: Text('Pengaturan Printer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                ),
                _ConnectionBadge(printer: _printer),
              ]),
              const SizedBox(height: 14),

              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textGrey,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Printer'),
                    Tab(text: 'Info Toko'),
                    Tab(text: 'Preview'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ]),
          ),

          // ── Tab content ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildPrinterTab(scrollCtrl),
                _buildInfoTokoTab(scrollCtrl),
                _buildPreviewTab(scrollCtrl),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // TAB 1: PRINTER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildPrinterTab(ScrollController ctrl) {
    return ListView(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        // Info jika sudah terhubung
        if (_printer.isConnected) ...[
          _ConnectedCard(
            name: _printer.connectedDeviceName ?? '-',
            onDisconnect: _disconnect,
          ),
          const SizedBox(height: 16),
        ],

        // Panduan singkat
        _InfoBox(
          icon: Icons.info_outline_rounded,
          color: AppColors.secondary,
          text: 'Pastikan printer sudah di-pair melalui Pengaturan Bluetooth HP kamu sebelum memilih di sini.',
        ),
        const SizedBox(height: 16),

        // Header daftar + tombol scan
        Row(children: [
          const Expanded(
            child: Text('Perangkat Paired',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          ),
          GestureDetector(
            onTap: _scanning ? null : _scan,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _scanning
                    ? const SizedBox(width: 12, height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: AppColors.secondary))
                    : const Icon(Icons.refresh_rounded,
                        size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(_scanning ? 'Scanning...' : 'Scan Ulang',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppColors.secondary)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 10),

        // Error
        if (_error != null)
          _InfoBox(icon: Icons.warning_amber_rounded, color: AppColors.habis, text: _error!),

        // Kosong
        if (!_scanning && _error == null && _devices.isEmpty)
          _InfoBox(
            icon: Icons.bluetooth_disabled_rounded,
            color: AppColors.textGrey,
            text: 'Tidak ada perangkat. Pair printer dari Pengaturan HP terlebih dahulu.',
          ),

        // Daftar device
        ..._devices.map((d) {
          final isActive = _printer.connectedAddress == d.address;
          return _DeviceTile(
            device: d,
            isActive: isActive,
            connecting: _connecting && !isActive,
            onTap: isActive ? null : () => _connect(d),
          );
        }),

        const SizedBox(height: 20),

        // Ukuran kertas
        const Text('Ukuran Kertas',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: AppColors.textDark)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _PaperSizeOption(
            label: '58mm', sub: 'Printer kecil',
            selected: !_is80mm,
            onTap: () => setState(() { _is80mm = false; _printer.paperSize = PaperSize.mm58; }),
          )),
          const SizedBox(width: 10),
          Expanded(child: _PaperSizeOption(
            label: '80mm', sub: 'Printer kasir',
            selected: _is80mm,
            onTap: () => setState(() { _is80mm = true; _printer.paperSize = PaperSize.mm80; }),
          )),
        ]),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // TAB 2: INFO TOKO
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildInfoTokoTab(ScrollController ctrl) {
    return ListView(
      controller: ctrl,
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      children: [
        _InfoBox(
          icon: Icons.receipt_long_outlined,
          color: AppColors.secondary,
          text: 'Informasi ini akan tampil di bagian atas setiap resi yang dicetak.',
        ),
        const SizedBox(height: 16),

        _field(_namaTokoCtrl, 'Nama Toko', Icons.storefront_outlined),
        const SizedBox(height: 10),
        _field(_alamatCtrl, 'Alamat', Icons.location_on_outlined),
        const SizedBox(height: 10),
        _field(_teleponCtrl, 'Nomor Telepon', Icons.phone_outlined, numeric: true),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _savingInfo ? null : _simpanInfo,
            icon: _savingInfo
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(_savingInfo ? 'Menyimpan...' : 'Simpan Info Toko'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // TAB 3: PREVIEW RESI
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildPreviewTab(ScrollController ctrl) {
    // Data contoh
    final storeName    = _namaTokoCtrl.text.trim().isEmpty ? 'INVENTIFY' : _namaTokoCtrl.text.trim();
    final storeAddress = _alamatCtrl.text.trim().isEmpty ? 'Jl. Contoh No. 1' : _alamatCtrl.text.trim();
    final storePhone   = _teleponCtrl.text.trim().isEmpty ? '0812-3456-7890' : _teleponCtrl.text.trim();

    return ListView(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        _InfoBox(
          icon: Icons.visibility_outlined,
          color: AppColors.secondary,
          text: 'Contoh tampilan resi yang akan dicetak. Sesuaikan info toko di tab "Info Toko".',
        ),
        const SizedBox(height: 16),

        // Simulasi kertas thermal
        Center(
          child: Container(
            width: _is80mm ? double.infinity : 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(children: [
              // Garis atas kertas thermal
              Container(height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(children: [

                  // Header toko
                  Text(storeName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      fontFamily: 'Courier', letterSpacing: 1,
                      color: Color(0xFF1a1a1a))),
                  const SizedBox(height: 2),
                  Text(storeAddress,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, fontFamily: 'Courier',
                        color: Color(0xFF444444))),
                  Text('Telp: $storePhone',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, fontFamily: 'Courier',
                        color: Color(0xFF444444))),

                  _receiptDivider(),

                  // Info transaksi
                  _receiptRow('#A3F9C2B1', '28/05/2025', bold: true),
                  _receiptRow('Kasir: Budi', '14:32'),

                  _receiptDivider(),

                  // Item contoh
                  _receiptItem('Aqua 600ml', 2, 3500),
                  _receiptItem('Indomie Goreng', 3, 3500),
                  _receiptItem('Teh Botol Sosro', 1, 5000),

                  _receiptDivider(),

                  // Summary
                  _receiptRow('TOTAL', 'Rp 22.500', bold: true),
                  _receiptRow('Bayar', 'Rp 25.000'),
                  _receiptRow('Kembalian', 'Rp 2.500',
                    valueColor: const Color(0xFF1D9E75), bold: true),

                  _receiptDivider(),

                  // Footer
                  const Text('Terima kasih telah berbelanja!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, fontFamily: 'Courier',
                        color: Color(0xFF666666))),
                  const SizedBox(height: 2),
                  const Text('Barang yang dibeli tidak dapat\ndikembalikan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, fontFamily: 'Courier',
                        color: Color(0xFF666666))),
                  const SizedBox(height: 10),

                  // Garis potong
                  Row(children: [
                    const Icon(Icons.content_cut_rounded, size: 10, color: Color(0xFF999999)),
                    Expanded(child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 1,
                      color: const Color(0xFFCCCCCC),
                    )),
                  ]),
                ]),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 20),

        // Label ukuran
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Kertas ${_is80mm ? '80mm' : '58mm'} — ${_is80mm ? 'lebih lebar' : 'standard'}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.secondary),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Tombol cetak test
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _printer.isConnected ? _cetakTest : null,
            icon: const Icon(Icons.print_outlined, size: 18),
            label: Text(_printer.isConnected
                ? 'Cetak Resi Test'
                : 'Hubungkan printer dulu di tab Printer'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                  color: _printer.isConnected
                      ? AppColors.secondary
                      : AppColors.textGrey.withValues(alpha: 0.3)),
              foregroundColor: _printer.isConnected
                  ? AppColors.secondary
                  : AppColors.textGrey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Cetak resi test ────────────────────────────────────────────────────
  Future<void> _cetakTest() async {
    try {
      await _printer.printQuickReceipt(
        txId: 'TEST0001',
        items: [],
        total: 22500,
        bayar: 25000,
        kasir: 'Test',
      );
      if (mounted) _snack('Resi test berhasil dicetak', ok: true);
    } catch (e) {
      if (mounted) _snack('Gagal: $e', ok: false);
    }
  }

  // ─── Helper widgets receipt preview ────────────────────────────────────
  Widget _receiptDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: List.generate(32, (_) => Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        height: 1,
        color: const Color(0xFFDDDDDD),
      ),
    ))),
  );

  Widget _receiptRow(String left, String right,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(children: [
        Expanded(child: Text(left,
          style: TextStyle(fontSize: 10, fontFamily: 'Courier',
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: const Color(0xFF1a1a1a)))),
        Text(right,
          style: TextStyle(fontSize: 10, fontFamily: 'Courier',
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: valueColor ?? const Color(0xFF1a1a1a))),
      ]),
    );
  }

  Widget _receiptItem(String name, int qty, int harga) {
    final subtotal = qty * harga;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name,
          style: const TextStyle(fontSize: 10, fontFamily: 'Courier',
              fontWeight: FontWeight.w700, color: Color(0xFF1a1a1a))),
        Row(children: [
          Text('  $qty x Rp ${_fmt(harga)}',
            style: const TextStyle(fontSize: 9, fontFamily: 'Courier',
                color: Color(0xFF555555))),
          const Spacer(),
          Text('Rp ${_fmt(subtotal)}',
            style: const TextStyle(fontSize: 10, fontFamily: 'Courier',
                color: Color(0xFF1a1a1a))),
        ]),
      ]),
    );
  }

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      if (++c % 3 == 0 && i != 0) buf.write('.');
    }
    return buf.toString().split('').reversed.join();
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool numeric = false}) {
    return TextField(
      controller: c,
      keyboardType: numeric ? TextInputType.phone : TextInputType.text,
      onChanged: (_) => setState(() {}), // update preview real-time
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondary),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.secondary)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ════════════════════════════════════════════════════════════════════════════

class _ConnectionBadge extends StatelessWidget {
  final PrinterService printer;
  const _ConnectionBadge({required this.printer});

  @override
  Widget build(BuildContext context) {
    final connected = printer.isConnected;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: connected
            ? AppColors.tersedia.withValues(alpha: 0.1)
            : AppColors.textGrey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: connected
              ? AppColors.tersedia.withValues(alpha: 0.3)
              : AppColors.textGrey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 7, height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: connected ? AppColors.tersedia : AppColors.textGrey,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          connected ? 'Terhubung' : 'Tidak terhubung',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: connected ? AppColors.tersedia : AppColors.textGrey,
          ),
        ),
      ]),
    );
  }
}

class _ConnectedCard extends StatelessWidget {
  final String name;
  final VoidCallback onDisconnect;
  const _ConnectedCard({required this.name, required this.onDisconnect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tersedia.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tersedia.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.tersedia.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.print_rounded, color: AppColors.tersedia, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Printer Aktif',
            style: TextStyle(fontSize: 11, color: AppColors.tersedia)),
          Text(name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        ])),
        GestureDetector(
          onTap: onDisconnect,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.habis.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.habis.withValues(alpha: 0.25)),
            ),
            child: const Text('Putuskan',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.habis)),
          ),
        ),
      ]),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BtDevice device;
  final bool isActive, connecting;
  final VoidCallback? onTap;
  const _DeviceTile({
    required this.device,
    required this.isActive,
    required this.connecting,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.secondary.withValues(alpha: 0.07)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.secondary.withValues(alpha: 0.4)
                : Colors.grey.shade200,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.secondary.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.print_rounded, size: 18,
              color: isActive ? AppColors.secondary : AppColors.textGrey),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(device.name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: isActive ? AppColors.secondary : AppColors.textDark)),
            Text(device.address,
              style: TextStyle(fontSize: 11,
                  color: AppColors.textGrey.withValues(alpha: 0.7))),
          ])),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.tersedia.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Aktif',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppColors.tersedia)),
            ),
          if (!isActive && connecting)
            const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.secondary)),
          if (!isActive && !connecting)
            Icon(Icons.chevron_right_rounded, size: 18,
                color: AppColors.textGrey.withValues(alpha: 0.5)),
        ]),
      ),
    );
  }
}

class _PaperSizeOption extends StatelessWidget {
  final String label, sub;
  final bool selected;
  final VoidCallback onTap;
  const _PaperSizeOption({
    required this.label, required this.sub,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withValues(alpha: 0.07)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.secondary : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Icon(Icons.receipt_long_outlined,
            size: 20,
            color: selected ? AppColors.secondary : AppColors.textGrey),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: selected ? AppColors.secondary : AppColors.textDark)),
            Text(sub,
              style: TextStyle(fontSize: 11,
                color: AppColors.textGrey.withValues(alpha: 0.7))),
          ]),
          const Spacer(),
          if (selected)
            const Icon(Icons.check_circle_rounded,
                size: 18, color: AppColors.secondary),
        ]),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _InfoBox({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
          style: TextStyle(fontSize: 12, color: color, height: 1.4))),
      ]),
    );
  }
}