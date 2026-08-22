import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../shared/utils/numbers.dart';
import 'invoice_amount_words.dart';
import 'invoice_file_store.dart';
import 'invoice_models.dart';

/// تولید PDF متنی (انتخاب‌پذیر) از فاکتور با فونت فارسی Vazirmatn
class InvoicePdfGenerator {
  static pw.Font? _regular;
  static pw.Font? _bold;

  static Future<pw.Font> _font({required bool bold}) async {
    if (bold) {
      return _bold ??= pw.Font.ttf(
        await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf'),
      );
    }
    return _regular ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf'),
    );
  }

  static Future<Uint8List> generate(InvoiceDraftModel invoice) async {
    final regular = await _font(bold: false);
    final bold = await _font(bold: true);

    final green = PdfColor.fromInt(0xFF16A34A);
    final greenLight = PdfColor.fromInt(0xFFF0FDF4);
    final greenBorder = PdfColor.fromInt(0xFF86EFAC);
    final ink = PdfColor.fromInt(0xFF1F2937);
    final inkDim = PdfColor.fromInt(0xFF6B7280);
    final line = PdfColor.fromInt(0xFFE5E7EB);
    final white = PdfColors.white;
    final formal = invoice.type == InvoiceType.formal;

    Future<pw.MemoryImage?> loadImage(String? path) async {
      if (path == null || path.isEmpty) return null;
      final bytes = await InvoiceFileStore.loadBytes(path);
      if (bytes == null) return null;
      return pw.MemoryImage(bytes);
    }

    final logo = await loadImage(invoice.logoPath);
    final signature = await loadImage(invoice.signaturePath);

    pw.Widget infoRow(String label, String value) {
      return pw.Text(
        '$label: $value',
        style: pw.TextStyle(font: regular, fontSize: 10, color: ink, fontWeight: pw.FontWeight.bold),
      );
    }

    pw.Widget partyBox(String label, InvoicePartyModel party) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: line),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(font: bold, fontSize: 11, color: green),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              party.name,
              style: pw.TextStyle(font: bold, fontSize: 11, color: ink),
            ),
            if (party.phone.trim().isNotEmpty) _partyLine(party.phone, regular, inkDim),
            if (party.address.trim().isNotEmpty) _partyLine(party.address, regular, inkDim),
            if (formal && party.economicCode.trim().isNotEmpty)
              _partyLine('کد اقتصادی: ${party.economicCode}', regular, inkDim),
            if (formal && party.registerNumber.trim().isNotEmpty)
              _partyLine('شماره ثبت: ${party.registerNumber}', regular, inkDim),
          ],
        ),
      );
    }

    final rows = <List<String>>[];
    for (var i = 0; i < invoice.items.length; i++) {
      final item = invoice.items[i];
      rows.add([
        '${i + 1}',
        item.description,
        formatNumber(item.quantity),
        item.unit,
        formatNumber(item.unitPrice),
        formatNumber(item.rowTotal),
      ]);
    }

    pw.Widget totals() {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _totalLine('جمع کل اقلام', formatNumber(invoice.subtotal), regular, ink, false),
          if (formal && invoice.includeTax)
            _totalLine('ارزش افزوده (${formatNumber(invoice.taxPercent)}٪)', formatNumber(invoice.taxAmount), regular, ink, false),
          if (invoice.shippingCost > 0)
            _totalLine('هزینه ارسال', formatNumber(invoice.shippingCost), regular, ink, false),
          pw.SizedBox(height: 5),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: pw.BoxDecoration(
              color: green,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'مبلغ نهایی: ${formatNumber(invoice.grandTotal)} تومان',
              style: pw.TextStyle(font: bold, fontSize: 13, color: white),
            ),
          ),
        ],
      );
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Container(
                      height: 5,
                      decoration: pw.BoxDecoration(
                        gradient: pw.LinearGradient(
                          colors: [green, greenBorder],
                        ),
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    // ─── هدر ───
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (logo != null)
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 12),
                            child: pw.ClipRRect(
                              horizontalRadius: 8,
                              verticalRadius: 8,
                              child: pw.Image(logo, width: 68, height: 68, fit: pw.BoxFit.contain),
                            ),
                          ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'فاکتور فروش کالا و خدمات',
                                style: pw.TextStyle(font: bold, fontSize: 21, color: ink),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Text(
                                formal ? 'فاکتور رسمی' : 'فاکتور ساده',
                                style: pw.TextStyle(font: bold, fontSize: 11, color: green),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: pw.BoxDecoration(
                            color: greenLight,
                            border: pw.Border.all(color: greenBorder),
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              infoRow('شماره فاکتور', invoice.number),
                              pw.SizedBox(height: 3),
                              infoRow('تاریخ', invoice.dateLabel),
                              pw.SizedBox(height: 3),
                              infoRow('نوع پرداخت', invoice.paymentMethod),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    // ─── فروشنده / خریدار ───
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(child: partyBox('فروشنده', invoice.seller)),
                        pw.SizedBox(width: 10),
                        pw.Expanded(child: partyBox('خریدار', invoice.buyer)),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    // ─── جدول اقلام ───
                    pw.TableHelper.fromTextArray(
                      headers: ['ردیف', 'شرح کالا/خدمات', 'تعداد', 'واحد', 'قیمت واحد', 'جمع'],
                      data: rows,
                      headerStyle: pw.TextStyle(font: bold, fontSize: 10, color: white),
                      headerDecoration: pw.BoxDecoration(color: green),
                      headerAlignment: pw.Alignment.center,
                      cellStyle: pw.TextStyle(font: regular, fontSize: 9.5, color: ink),
                      cellAlignments: const {
                        0: pw.Alignment.center,
                        1: pw.Alignment.centerRight,
                        2: pw.Alignment.center,
                        3: pw.Alignment.center,
                        4: pw.Alignment.center,
                        5: pw.Alignment.center,
                      },
                      border: pw.TableBorder.all(color: line, width: 0.7),
                    ),
                    pw.SizedBox(height: 10),
                    totals(),
                    pw.SizedBox(height: 10),
                    // ─── مبلغ به حروف ───
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: pw.BoxDecoration(
                        color: greenLight,
                        border: pw.Border.all(color: greenBorder),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'مبلغ به حروف:',
                            style: pw.TextStyle(font: bold, fontSize: 11, color: green),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Expanded(
                            child: pw.Text(
                              amountInWords(invoice.grandTotal),
                              style: pw.TextStyle(font: bold, fontSize: 11, color: ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (invoice.notes.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: line),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'توضیحات',
                              style: pw.TextStyle(font: bold, fontSize: 10, color: green),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              invoice.notes,
                              style: pw.TextStyle(font: regular, fontSize: 10, color: inkDim),
                            ),
                          ],
                        ),
                      ),
                    ],
                    pw.SizedBox(height: 16),
                    // ─── امضا ───
                    pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          if (signature != null)
                            pw.Image(signature, width: 90, height: 52, fit: pw.BoxFit.contain),
                          pw.SizedBox(height: 5),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: greenBorder),
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Text(
                              'امضا و مهر فروشنده',
                              style: pw.TextStyle(font: bold, fontSize: 10, color: inkDim),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            footer: (context) => pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'صفحه ${context.pageNumber} از ${context.pagesCount}',
                style: pw.TextStyle(font: regular, fontSize: 8, color: inkDim),
              ),
            ),
        ),
    );
    return doc.save();
  }
}

pw.Widget _partyLine(String text, pw.Font font, PdfColor color) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 2),
    child: pw.Text(
      text,
      style: pw.TextStyle(font: font, fontSize: 10.5, color: color),
    ),
  );
}

pw.Widget _totalLine(String label, String value, pw.Font font, PdfColor color, bool bold) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 2),
    child: pw.Text(
      '$label: $value تومان',
      style: pw.TextStyle(
        font: font,
        fontSize: 11,
        color: color,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}