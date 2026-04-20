import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:inventify/theme.dart';

class BarcodeScanner extends StatefulWidget {
  final void Function(String) onDetected;
  const BarcodeScanner({super.key, required this.onDetected});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final _ctrl = MobileScannerController();
  bool _done = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onDetect(BarcodeCapture c) {
    if (_done) return;
    final val = c.barcodes.firstOrNull?.rawValue;
    if (val == null || val.isEmpty) return;
    setState(() => _done = true);
    widget.onDetected(val);
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
            child: Stack(children: [
              MobileScanner(controller: _ctrl, onDetect: _onDetect),
              // Corner brackets overlay
              Positioned.fill(child: _ScanOverlay()),
              // Controls
              Positioned(top: 8, right: 8, child: Row(children: [
                _ctrl_btn(Icons.flash_on_rounded, () => _ctrl.toggleTorch()),
                const SizedBox(width: 6),
                _ctrl_btn(Icons.flip_camera_ios_rounded, () => _ctrl.switchCamera()),
              ])),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Arahkan kamera ke barcode barang',
          style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget _ctrl_btn(IconData icon, VoidCallback onTap) => GestureDetector(
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
      [Offset(size.width - m - l, m), Offset(size.width - m, m), Offset(size.width - m, m + l)],
      // bottom-left
      [Offset(m, size.height - m - l), Offset(m, size.height - m), Offset(m + l, size.height - m)],
      // bottom-right
      [Offset(size.width - m - l, size.height - m), Offset(size.width - m, size.height - m), Offset(size.width - m, size.height - m - l)],
    ];

    for (final pts in corners) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy)..lineTo(pts[1].dx, pts[1].dy)..lineTo(pts[2].dx, pts[2].dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}