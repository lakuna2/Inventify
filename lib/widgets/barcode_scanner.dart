import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:inventify/theme.dart';

class BarcodeScanner extends StatefulWidget {
  final void Function(String) onDetected;
  const BarcodeScanner({super.key, required this.onDetected});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner>
    with WidgetsBindingObserver {
  late final MobileScannerController _ctrl;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ← daftarkan observer
    _ctrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates, // ← hindari deteksi ganda
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    // Start kamera setelah frame pertama selesai render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.start();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause kamera saat app background, resume saat kembali
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _ctrl.stop();
        break;
      case AppLifecycleState.resumed:
        if (mounted && !_done) _ctrl.start();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ← hapus observer
    _ctrl.stop();
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture c) {
    if (_done) return;
    final val = c.barcodes.firstOrNull?.rawValue;
    if (val == null || val.isEmpty) return;
    setState(() => _done = true);
    _ctrl.stop(); // ← stop setelah berhasil scan
    widget.onDetected(val);
  }

  // Tambah method reset agar bisa scan lagi setelah transaksi selesai
  void reset() {
    if (!mounted) return;
    setState(() => _done = false);
    _ctrl.start();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                MobileScanner(
                  controller: _ctrl,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) {
                    // ← tampilkan error + tombol retry jika kamera gagal
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white54,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Kamera tidak tersedia',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _ctrl.start(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Coba Lagi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned.fill(child: _ScanOverlay()),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _ctrlBtn(
                        Icons.flash_on_rounded,
                        () => _ctrl.toggleTorch(),
                      ),
                      const SizedBox(width: 6),
                      _ctrlBtn(
                        Icons.flip_camera_ios_rounded,
                        () => _ctrl.switchCamera(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _done ? 'Berhasil scan!' : 'Arahkan kamera ke barcode barang',
          style: TextStyle(
            fontSize: 12,
            color: _done
                ? AppColors.tersedia
                : AppColors.textDark.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    ),
  );
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _OverlayPainter());
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const l = 20.0; // corner length
    const m = 12.0; // margin

    final corners = [
      // top-left
      [Offset(m, m + l), Offset(m, m), Offset(m + l, m)],
      // top-right
      [
        Offset(size.width - m - l, m),
        Offset(size.width - m, m),
        Offset(size.width - m, m + l),
      ],
      // bottom-left
      [
        Offset(m, size.height - m - l),
        Offset(m, size.height - m),
        Offset(m + l, size.height - m),
      ],
      // bottom-right
      [
        Offset(size.width - m - l, size.height - m),
        Offset(size.width - m, size.height - m),
        Offset(size.width - m, size.height - m - l),
      ],
    ];

    for (final pts in corners) {
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
