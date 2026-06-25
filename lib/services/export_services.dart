import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

// ─── Filter Periode (Bulan spesifik atau Semua) ──────────────────────────────
class FilterPeriode {
  final int? year;  // null untuk "Semua"
  final int? month; // null untuk "Semua"
  
  const FilterPeriode({this.year, this.month});
  
  bool get isSemua => year == null || month == null;
  
  String get label {
    if (isSemua) return 'Semua Transaksi';
    return DateFormat('MMMM yyyy', 'id_ID').format(DateTime(year!, month!));
  }
  
  static FilterPeriode semua() => const FilterPeriode();
  
  static FilterPeriode bulan(int year, int month) => FilterPeriode(year: year, month: month);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterPeriode &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month;
  
  @override
  int get hashCode => year.hashCode ^ month.hashCode;
}

// ─── Model bantu per baris TRANSAKSI (1 transaksi = 1 baris) ─────────────────
class _TxRow {
  final String kodeTransaksi;
  final String tanggal;
  final String kasir;
  final String produkLabel; // maks 3 produk, dipisah koma, + "..." jika lebih
  final int totalQty;       // total seluruh item dalam transaksi
  final double total;
  final double laba;        // sum (hargaJual - hargaBeli) * qty

  const _TxRow({
    required this.kodeTransaksi,
    required this.tanggal,
    required this.kasir,
    required this.produkLabel,
    required this.totalQty,
    required this.total,
    required this.laba,
  });
}

class ExportService {
  // ─── Format helpers ───────────────────────────────────────────────
  static String _rupiah(double v) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(v);

  static String _tgl(dynamic ts) {
    if (ts == null) return '-';
    DateTime dt;
    if (ts is DateTime) {
      dt = ts;
    } else if (ts.runtimeType.toString().contains('Timestamp')) {
      dt = ts.toDate();
    } else {
      return ts.toString();
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  static DateTime? _toDateTime(dynamic ts) {
    if (ts == null) return null;
    if (ts is DateTime) return ts;
    if (ts.runtimeType.toString().contains('Timestamp')) return ts.toDate();
    return null;
  }

  // ─── Filter transaksi berdasarkan periode ─────────────────────────
  static List<Map<String, dynamic>> filterTransaksi(
    List<Map<String, dynamic>> transaksi,
    FilterPeriode periode,
  ) {
    if (periode.isSemua) return transaksi;

    return transaksi.where((tx) {
      final dt = _toDateTime(tx['createdAt'] ?? tx['tanggal']);
      if (dt == null) return false;

      // Filter berdasarkan tahun dan bulan yang dipilih
      return dt.year == periode.year && dt.month == periode.month;
    }).toList();
  }

  // ─── Konversi transaksi → 1 baris per transaksi ───────────────────
  static List<_TxRow> _buildRows(List<Map<String, dynamic>> transaksi) {
    return transaksi.map((tx) {
      final kodeTransaksi = (tx['id'] ?? tx['kodeTransaksi'] ?? '-').toString();
      final tanggal = _tgl(tx['createdAt'] ?? tx['tanggal']);
      final kasir = (tx['kasir'] ?? '-').toString();
      final items = tx['items'] as List? ?? [];

      // Hitung total qty dan laba dari semua item
      int totalQty = 0;
      double laba = 0;
      final namaList = <String>[];

      for (final item in items) {
        final m = item as Map<String, dynamic>;
        final nama = (m['name'] ?? m['namaBarang'] ?? m['nama'] ?? '-').toString();
        final qty = ((m['qty'] ?? 1) as num).toInt();
        final hargaJual = ((m['hargaJual'] ?? m['harga'] ?? 0) as num).toDouble();
        final hargaBeli = ((m['hargaBeli'] ?? m['modal'] ?? m['hargaModal'] ?? 0) as num).toDouble();

        totalQty += qty;
        laba += (hargaJual - hargaBeli) * qty;
        namaList.add(nama);
      }

      // Ambil maks 3 nama produk, sisanya jadi "..."
      String produkLabel;
      if (namaList.isEmpty) {
        produkLabel = '-';
      } else if (namaList.length <= 3) {
        produkLabel = namaList.join(', ');
      } else {
        produkLabel = '${namaList.take(3).join(', ')}, ...';
      }

      // total pendapatan dari field 'total' (sudah dihitung saat simpan)
      final total = (tx['total'] as num? ?? 0).toDouble();

      return _TxRow(
        kodeTransaksi: kodeTransaksi,
        tanggal: tanggal,
        kasir: kasir,
        produkLabel: produkLabel,
        totalQty: totalQty,
        total: total,
        laba: laba,
      );
    }).toList();
  }

  // ─── CSV ──────────────────────────────────────────────────────────
  Future<void> exportCsv(
    List<Map<String, dynamic>> transaksi, {
    String namaToko = 'Toko',
    FilterPeriode? periode,
  }) async {
    final filter = periode ?? FilterPeriode.semua();
    final filtered = filterTransaksi(transaksi, filter);
    final txRows = _buildRows(filtered);

    final rows = <List<dynamic>>[
      ['No', 'Kode Transaksi', 'Tanggal', 'Kasir', 'Produk', 'Qty', 'Total', 'Laba'],
    ];

    for (int i = 0; i < txRows.length; i++) {
      final r = txRows[i];
      rows.add([
        i + 1,
        r.kodeTransaksi,
        r.tanggal,
        r.kasir,
        r.produkLabel,
        r.totalQty,
        r.total,
        r.laba,
      ]);
    }

    final grandTotal = txRows.fold(0.0, (s, r) => s + r.total);
    final grandLaba  = txRows.fold(0.0, (s, r) => s + r.laba);
    rows.add(['', '', '', '', '', 'TOTAL', grandTotal, grandLaba]);

    final csvString = csv.encode(rows);
    final dir   = await getApplicationDocumentsDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final fileLabel = filter.isSemua ? 'semua' : '${filter.year}_${filter.month}';
    final file  = File('${dir.path}/transaksi_${fileLabel}_$stamp.csv');
    await file.writeAsString(csvString);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Data Transaksi $namaToko — ${filter.label}',
      ),
    );
  }

  // ─── PDF ──────────────────────────────────────────────────────────
  Future<void> exportPdf(
    List<Map<String, dynamic>> transaksi, {
    String namaToko = 'Toko',
    String? alamat,
    FilterPeriode? periode,
  }) async {
    final filter = periode ?? FilterPeriode.semua();
    final filtered = filterTransaksi(transaksi, filter);
    final txRows = _buildRows(filtered);

    final grandTotal = txRows.fold(0.0, (s, r) => s + r.total);
    final grandLaba  = txRows.fold(0.0, (s, r) => s + r.laba);

    const brandColor = PdfColor.fromInt(0xFF6C63FF);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => _pdfHeader(namaToko, alamat, brandColor, filter),
        footer: (ctx) => _pdfFooter(ctx),
        build: (ctx) => [
          _pdfSummaryRow(filtered.length, grandTotal, grandLaba, brandColor),
          pw.SizedBox(height: 16),
          _pdfTable(txRows, grandTotal, grandLaba, brandColor),
        ],
      ),
    );

    final dir   = await getApplicationDocumentsDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final fileLabel = filter.isSemua ? 'semua' : '${filter.year}_${filter.month}';
    final file  = File('${dir.path}/laporan_${fileLabel}_$stamp.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Laporan Transaksi $namaToko — ${filter.label}',
      ),
    );
  }

  // ─── PDF Widgets ──────────────────────────────────────────────────
  static pw.Widget _pdfHeader(
    String namaToko,
    String? alamat,
    PdfColor brand,
    FilterPeriode periode,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: pw.BoxDecoration(
            color: brand,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                namaToko,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              if (alamat != null && alamat.isNotEmpty)
                pw.Text(
                  alamat,
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.white),
                ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Laporan Transaksi — ${periode.label}  |  '
                '${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.white),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _pdfSummaryRow(
    int jumlah,
    double total,
    double laba,
    PdfColor brand,
  ) {
    return pw.Row(
      children: [
        _summaryBox('Total Transaksi', '$jumlah', brand),
        pw.SizedBox(width: 10),
        _summaryBox('Total Pendapatan', _rupiah(total), brand),
        pw.SizedBox(width: 10),
        _summaryBox('Total Laba', _rupiah(laba), brand),
      ],
    );
  }

  static pw.Widget _summaryBox(String label, String val, PdfColor brand) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: brand, width: 0.8),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 3),
            pw.Text(
              val,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: brand,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _pdfTable(
    List<_TxRow> rows,
    double grandTotal,
    double grandLaba,
    PdfColor brand,
  ) {
    final cellStyle = pw.TextStyle(fontSize: 8, color: PdfColors.grey900);
    final boldCell  = pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900);

    return pw.Table(
      columnWidths: const {
        0: pw.FixedColumnWidth(18),  // No
        1: pw.FlexColumnWidth(2.0),  // Kode Transaksi
        2: pw.FlexColumnWidth(1.6),  // Tanggal
        3: pw.FlexColumnWidth(1.1),  // Kasir
        4: pw.FlexColumnWidth(2.8),  // Produk (lebih lebar karena bisa 3 nama)
        5: pw.FixedColumnWidth(22),  // Qty
        6: pw.FlexColumnWidth(1.5),  // Total
        7: pw.FlexColumnWidth(1.5),  // Laba
      },
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: brand),
          children: ['No', 'Kode Transaksi', 'Tanggal', 'Kasir', 'Produk', 'Qty', 'Total', 'Laba']
              .map((h) => _cell(h, pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  )))
              .toList(),
        ),
        // Data rows
        ...rows.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          final bg = i.isEven ? PdfColors.white : PdfColors.grey50;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: [
              _cell('${i + 1}',           cellStyle),
              _cell(r.kodeTransaksi,      cellStyle),
              _cell(r.tanggal,            cellStyle),
              _cell(r.kasir,              cellStyle),
              _cell(r.produkLabel,        cellStyle),
              _cell('${r.totalQty}',      cellStyle),
              _cell(_rupiah(r.total),     boldCell),
              _cell(_rupiah(r.laba),      boldCell),
            ],
          );
        }),
        // Footer total
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('', null),
            _cell('', null),
            _cell('', null),
            _cell('', null),
            _cell('TOTAL', pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            _cell('', null),
            _cell(_rupiah(grandTotal), pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brand)),
            _cell(_rupiah(grandLaba),  pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brand)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _cell(String text, pw.TextStyle? style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Text(text, style: style),
    );
  }

  static pw.Widget _pdfFooter(pw.Context ctx) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Digenerate oleh Inventify', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
        pw.Text('Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
      ],
    );
  }
}