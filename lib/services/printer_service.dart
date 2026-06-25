import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:inventify/models/transaksi_model.dart';
import 'package:inventify/widgets/cart_item.dart'; // rupiahFormat

class BtDevice {
  final String name;
  final String address;
  BtDevice({required this.name, required this.address});
}

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  // ─── State koneksi ────────────────────────────────────────────────────────
  String? _connectedAddress;
  String? _connectedName;

  String? get connectedAddress => _connectedAddress;
  String? get connectedDeviceName => _connectedName;
  bool get isConnected => _connectedAddress != null;

  // ─── Info toko (diset dari PrinterSetupSheet) ─────────────────────────────
  String storeName = 'INVENTIFY';
  String storeAddress = 'Jl. Contoh No. 1';
  String storePhone = '0812-3456-7890';
  PaperSize paperSize = PaperSize.mm58;

  // ─── Permissions ──────────────────────────────────────────────────────────
  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }

  // ─── Scan paired devices ──────────────────────────────────────────────────
  Future<List<BtDevice>> scanPairedDevices() async {
    final granted = await requestPermissions();
    if (!granted) throw Exception('Permission Bluetooth tidak diberikan');
    final List<BluetoothInfo> paired =
        await PrintBluetoothThermal.pairedBluetooths;
    return paired
        .map((d) => BtDevice(name: d.name, address: d.macAdress))
        .toList();
  }

  // ─── Connect / Disconnect ─────────────────────────────────────────────────
  Future<bool> connect(BtDevice device) async {
    if (isConnected) await disconnect();
    await Future.delayed(const Duration(milliseconds: 800));
    final ok = await PrintBluetoothThermal.connect(
      macPrinterAddress: device.address,
    );
    if (ok) {
      _connectedAddress = device.address;
      _connectedName = device.name;
    }
    return ok;
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect; // atau tanpa await sekalian
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 500));
    _connectedAddress = null;
    _connectedName = null;
  }

  // ─── Cetak dari TransactionModel (riwayat → cetak ulang) ─────────────────
  Future<void> printReceipt({required TransactionModel tx}) async {
    if (!isConnected) throw Exception('Printer belum terhubung');
    final bytes = await _buildFromModel(tx);
    final ok = await PrintBluetoothThermal.writeBytes(bytes.toList());
    if (!ok) throw Exception('Gagal mengirim data ke printer');
  }

  // ─── Cetak cepat setelah transaksi selesai ────────────────────────────────
  Future<void> printQuickReceipt({
    required String txId,
    required List<CartItem> items,
    required double total,
    required double bayar,
    required String kasir,
  }) async {
    if (!isConnected) throw Exception('Printer belum terhubung');
    final bytes = await _buildFromItems(
      txId: txId,
      items: items,
      total: total,
      bayar: bayar,
      kasir: kasir,
    );
    final ok = await PrintBluetoothThermal.writeBytes(bytes.toList());
    if (!ok) throw Exception('Gagal mengirim data ke printer');
  }

  // ─── Builder: dari TransactionModel ──────────────────────────────────────
  Future<Uint8List> _buildFromModel(TransactionModel tx) async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(paperSize, profile);
    final List<int> buf = [];
    final now = tx.createdAt;
    final dateStr = _fmtDate(now);
    final timeStr = _fmtTime(now);

    buf
      ..addAll(_header(gen))
      // bbb
      ..addAll(
        gen.row([
          PosColumn(text: 'Tanggal', width: 5),
          PosColumn(text: ': $dateStr $timeStr', width: 7),
        ]),
      )
      ..addAll(
        gen.row([
          PosColumn(text: 'No. Resi', width: 5),
          PosColumn(
            text: ': #${tx.id.substring(0, 8).toUpperCase()}',
            width: 7,
          ),
        ]),
      )
      ..addAll(
        gen.row([
          PosColumn(text: 'Kasir', width: 5),
          PosColumn(text: ': ${tx.kasir}', width: 7),
        ]),
      )
      ..addAll(gen.hr());

    for (final item in tx.items) {
      buf
        ..addAll(
          gen.text(
            _truncate(item.name, 24),
            styles: const PosStyles(bold: true),
          ),
        )
        ..addAll(
          gen.row([
            PosColumn(
              text: '  ${item.qty} x ${rupiahFormat(item.hargaJual)}',
              width: 7,
            ),
            PosColumn(
              text: rupiahFormat(item.subtotal),
              width: 5,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]),
        );
    }

    buf
      ..addAll(gen.hr())
      ..addAll(_summary(gen, total: tx.total, bayar: tx.bayar))
      ..addAll(_footer(gen));

    return Uint8List.fromList(buf);
  }

  // ─── Builder: dari CartItem list ─────────────────────────────────────────
  Future<Uint8List> _buildFromItems({
    required String txId,
    required List<CartItem> items,
    required double total,
    required double bayar,
    required String kasir,
  }) async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(paperSize, profile);
    final List<int> buf = [];
    final now = DateTime.now();

    buf
      ..addAll(_header(gen))

      ..addAll(
        gen.row([
          PosColumn(text: 'Tanggal', width: 5),
          PosColumn(text: ': ${_fmtDate(now)} ${_fmtTime(now)}', width: 7),
        ]),
      )
      ..addAll(
        gen.row([
          PosColumn(text: 'No. Resi', width: 5),
          PosColumn(text: ': #${txId.substring(0, 8).toUpperCase()}', width: 7),
        ]),
      )
      ..addAll(
        gen.row([
          PosColumn(text: 'Kasir', width: 5),
          PosColumn(text: ': $kasir', width: 7),
        ]),
      )
      ..addAll(gen.hr());

    for (final item in items) {
      buf
        ..addAll(
          gen.text(
            _truncate(item.name, 24),
            styles: const PosStyles(bold: true),
          ),
        )
        ..addAll(
          gen.row([
            PosColumn(
              text: '  ${item.qty} x ${rupiahFormat(item.hargaJual)}',
              width: 7,
            ),
            PosColumn(
              text: rupiahFormat(item.subtotal),
              width: 5,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]),
        );
    }

    buf
      ..addAll(gen.hr())
      ..addAll(_summary(gen, total: total, bayar: bayar))
      ..addAll(_footer(gen));

    return Uint8List.fromList(buf);
  }

  // ─── Reusable ESC/POS sections ───────────────────────────────────────────
  List<int> _header(Generator gen) => [
    ...gen.text(
      storeName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    ),
    ...gen.text(storeAddress, styles: const PosStyles(align: PosAlign.center)),
    ...gen.text(
      'Telp: $storePhone',
      styles: const PosStyles(align: PosAlign.center),
    ),
    ...gen.hr(),
  ];

  List<int> _summary(
    Generator gen, {
    required double total,
    required double bayar,
  }) => [
    ...gen.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: rupiahFormat(total),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]),
    ...gen.row([
      PosColumn(text: 'Bayar', width: 6),
      PosColumn(
        text: rupiahFormat(bayar),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]),
    ...gen.row([
      PosColumn(text: 'Kembalian', width: 6),
      PosColumn(
        text: rupiahFormat(bayar - total),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]),
  ];

  List<int> _footer(Generator gen) => [
    ...gen.hr(),
    ...gen.text(
      'Terima kasih telah berbelanja!',
      styles: const PosStyles(align: PosAlign.center),
    ),
    ...gen.text(
      'Barang yang dibeli tidak dapat\ndikembalikan.',
      styles: const PosStyles(align: PosAlign.center),
    ),
    ...gen.text(' '),
    ...gen.hr(),
    ...gen.text(' '),
    
  ];

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString().substring(2)}';
  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  String _truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max - 1)}…' : s;
}
