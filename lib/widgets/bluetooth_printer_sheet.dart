import 'package:flutter/material.dart';
import 'package:inventify/services/printer_service.dart';
import 'package:inventify/theme.dart';

/// Sheet untuk memilih printer Bluetooth.
/// Kembalikan [BtDevice] jika user memilih, atau null jika dibatalkan.
class BluetoothPrinterSheet extends StatefulWidget {
  const BluetoothPrinterSheet({super.key});

  static Future<BtDevice?> show(BuildContext context) {
    return showModalBottomSheet<BtDevice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BluetoothPrinterSheet(),
    );
  }

  @override
  State<BluetoothPrinterSheet> createState() => _BluetoothPrinterSheetState();
}

class _BluetoothPrinterSheetState extends State<BluetoothPrinterSheet> {
  final _printer = PrinterService();
  List<BtDevice> _devices = [];
  BtDevice? _selected;
  bool _scanning = false;
  bool _connecting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _error = null;
      _devices = [];
    });
    try {
      final found = await _printer.scanPairedDevices();
      if (!mounted) return;
      setState(() {
        _devices = found;
        // Tandai yang sedang aktif terkoneksi
        if (_printer.isConnected) {
          _selected = found.firstWhereOrNull(
              (d) => d.address == _printer.connectedAddress);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _connect(BtDevice device) async {
    setState(() => _connecting = true);
    try {
      final ok = await _printer.connect(device);
      if (!mounted) return;
      if (ok) {
        setState(() => _selected = device);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Terhubung ke ${device.name}'),
          backgroundColor: AppColors.tersedia,
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        _showError('Gagal terhubung ke ${device.name}');
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.habis,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Header
        Row(children: [
          const Icon(Icons.bluetooth_rounded,
              color: AppColors.secondary, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Pilih Printer Bluetooth',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ),
          // Tombol scan ulang
          if (!_scanning)
            GestureDetector(
              onTap: _scan,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(children: [
                  Icon(Icons.refresh_rounded,
                      size: 14, color: AppColors.secondary),
                  SizedBox(width: 4),
                  Text('Scan',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
        ]),
        const SizedBox(height: 6),

        Text(
          'Pastikan printer sudah di-pair di Pengaturan Bluetooth HP.',
          style: TextStyle(
              fontSize: 12,
              color: AppColors.textGrey.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 16),

        // State: scanning
        if (_scanning)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Column(children: [
              CircularProgressIndicator(
                  color: AppColors.secondary, strokeWidth: 2),
              SizedBox(height: 12),
              Text('Mencari perangkat...',
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
            ]),
          ),

        // State: error
        if (!_scanning && _error != null)
          _StatusTile(
            icon: Icons.warning_amber_rounded,
            color: AppColors.habis,
            text: _error!,
          ),

        // State: kosong
        if (!_scanning && _error == null && _devices.isEmpty)
          _StatusTile(
            icon: Icons.bluetooth_disabled_rounded,
            color: AppColors.textGrey,
            text: 'Tidak ada perangkat paired.\nPair printer dari Pengaturan HP.',
          ),

        // Daftar device
        if (!_scanning && _devices.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _devices.length,
            // ignore: unnecessary_underscores
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final d = _devices[i];
              final isActive = _selected?.address == d.address;
              return _DeviceTile(
                device: d,
                isActive: isActive,
                isConnecting: _connecting && !isActive,
                onTap: isActive ? null : () => _connect(d),
              );
            },
          ),

        const SizedBox(height: 20),

        // Tombol pakai printer ini
        if (_selected != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _connecting
                  ? null
                  : () => Navigator.pop(context, _selected),
              icon: const Icon(Icons.print_rounded, size: 18),
              label: Text('Gunakan ${_selected!.name}'),
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
      ]),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BtDevice device;
  final bool isActive;
  final bool isConnecting;
  final VoidCallback? onTap;

  const _DeviceTile({
    required this.device,
    required this.isActive,
    required this.isConnecting,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.secondary.withValues(alpha: 0.08)
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
            child: Icon(
              Icons.print_rounded,
              size: 18,
              color:
                  isActive ? AppColors.secondary : AppColors.textGrey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(device.name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.secondary
                          : AppColors.textDark)),
              Text(device.address,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey.withValues(alpha: 0.7))),
            ]),
          ),
          if (isActive)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tersedia.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Terhubung',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tersedia)),
            ),
          if (!isActive && isConnecting)
            const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.secondary),
            ),
          if (!isActive && !isConnecting)
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textGrey),
        ]),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _StatusTile(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: color))),
      ]),
    );
  }
}

// Helper extension
extension _ListX<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}