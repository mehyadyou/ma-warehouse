import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr/qr.dart';

import '../core/badge_print_settings.dart';
import '../core/label_data.dart';
import '../core/printer_settings.dart';

/// ابعاد لیبل فیزیکی از تنظیمات ذخیره‌شده‌ی چاپگر (پیش‌فرض ۱۰×۸ سانتی‌متر)
double _labelWidthMm() => PrinterSettingsHolder.instance.current.labelWidthMm;
double _labelHeightMm() => PrinterSettingsHolder.instance.current.labelHeightMm;
double _labelMarginMm() => PrinterSettingsHolder.instance.current.labelMarginMm;

/// چاپ بیجک:
/// - حالت دوتایی (پیش‌فرض): دو بیجک A6 کنار هم روی یک برگهٔ A5 افقی (۲۱۰×۱۴۸)
///   تا با برش وسط، دو برگهٔ A6 جدا شود
/// - حالت تکی: هر بیجک روی یک برگهٔ A6 عمودی (۱۰۵×۱۴۸) جداگانه
const double _badgePageWidthMm = 210;
const double _badgePageHeightMm = 148;
const double _badgeSingleWidthMm = 105;

class PdfLabels {
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

  static Future<Uint8List> _qrPng(String data, int size) async {
    final qrCode = QrCode.fromData(
      data: data.isEmpty ? ' ' : data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    final qrImage = QrImage(qrCode);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final moduleCount = qrImage.moduleCount;
    final module = size / moduleCount;
    final paint = Paint()..color = const Color(0xFF000000);
    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (qrImage.isDark(row, col)) {
          canvas.drawRect(
            Rect.fromLTWH(col * module, row * module, module, module),
            paint,
          );
        }
      }
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<bool> printLabels(List<LabelData> labels) async {
    if (labels.isEmpty) return false;
    final document = await _buildLabelDocument(labels);
    if (document == null) return false;
    final pageFormat = PdfPageFormat(
      _labelWidthMm() * PdfPageFormat.mm,
      _labelHeightMm() * PdfPageFormat.mm,
      marginAll: 0,
    );
    return _showPrintDialog(document, pageFormat);
  }

  static Future<Uint8List?> buildLabelPdfBytes(List<LabelData> labels) async {
    final document = await _buildLabelDocument(labels);
    if (document == null) return null;
    return document.save();
  }

  static Future<pw.Document?> _buildLabelDocument(
    List<LabelData> labels,
  ) async {
    if (labels.isEmpty) return null;
    final regular = await _font(bold: false);
    final bold = await _font(bold: true);
    final courier = pw.Font.courierBold();
    final document = pw.Document();
    final pageFormat = PdfPageFormat(
      _labelWidthMm() * PdfPageFormat.mm,
      _labelHeightMm() * PdfPageFormat.mm,
      marginAll: 0,
    );

    for (final label in labels) {
      final qrBytes = await _qrPng(label.qrPayload, 200);
      final s = PrinterSettingsHolder.instance.current;
      document.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.all(_labelMarginMm() * PdfPageFormat.mm),
          build: (context) => pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Transform.translate(
              offset: PdfPoint(
                s.offsetXmm * PdfPageFormat.mm,
                s.offsetYmm * PdfPageFormat.mm,
              ),
              child: pw.Transform.scale(
                scale: s.scalePercent / 100,
                alignment: pw.Alignment.center,
                child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // سربرگ: PGG + زیرنویس ریز
                pw.Container(
                  height: 34,
                  alignment: pw.Alignment.center,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 2),
                    ),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        'PGG',
                        style: pw.TextStyle(
                          font: bold,
                          fontSize: 16,
                          letterSpacing: 4,
                        ),
                      ),
                      pw.Text(
                        'Pro Global Groups',
                        style: pw.TextStyle(
                          font: regular,
                          fontSize: 6,
                          letterSpacing: 1.2,
                          color: PdfColor.fromHex('#4a4a4a'),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                // بدنه افقی: اطلاعات سمت راست، QR سمت چپ
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // اطلاعات دقیق محصول
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          mainAxisAlignment:
                              pw.MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: [
                            _pdfInfoRow('محصول', label.productName, regular, bold),
                            _pdfInfoRow('مدل', label.modelDisplay, regular, bold),
                            _pdfInfoRow('تعداد', label.qtyText, regular, bold),
                            _pdfInfoRow('سریال', label.serial, regular, bold),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      // QR
                      pw.Expanded(
                        flex: 2,
                        child: pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Image(
                            pw.MemoryImage(qrBytes),
                            width: 110,
                            height: 110,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 6),
                _pdfDivider(),
                pw.SizedBox(height: 2),
                pw.Container(
                  height: 24,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '*${label.barcode}*',
                    style: pw.TextStyle(font: courier, fontSize: 14),
                  ),
                ),
                pw.Container(
                  height: 14,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    label.tracking,
                    maxLines: 1,
                    style: pw.TextStyle(
                      font: regular,
                      fontSize: 7,
                      color: PdfColor.fromHex('#4a4a4a'),
                    ),
                  ),
                ),
              ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return document;
  }

  static Future<bool> printBadges(List<BadgeData> badges) async {
    if (badges.isEmpty) return false;
    final document = await _buildBadgeDocument(badges);
    if (document == null) return false;
    final s = BadgePrintSettingsHolder.instance.current;
    final pageFormat = PdfPageFormat(
      (s.dualMode ? _badgePageWidthMm : _badgeSingleWidthMm) *
          PdfPageFormat.mm,
      _badgePageHeightMm * PdfPageFormat.mm,
      marginAll: 0,
    );
    return _showPrintDialog(document, pageFormat);
  }

  static Future<Uint8List?> buildBadgePdfBytes(List<BadgeData> badges) async {
    final document = await _buildBadgeDocument(badges);
    if (document == null) return null;
    return document.save();
  }

  static Future<pw.Document?> _buildBadgeDocument(
    List<BadgeData> badges,
  ) async {
    if (badges.isEmpty) return null;
    final regular = await _font(bold: false);
    final bold = await _font(bold: true);
    final courier = pw.Font.courierBold();
    final document = pw.Document();
    final s = BadgePrintSettingsHolder.instance.current;
    final pageFormat = PdfPageFormat(
      (s.dualMode ? _badgePageWidthMm : _badgeSingleWidthMm) *
          PdfPageFormat.mm,
      _badgePageHeightMm * PdfPageFormat.mm,
      marginAll: 0,
    );

    if (!s.dualMode) {
      // حالت تکی: هر بیجک روی یک برگهٔ A6 جداگانه
      for (final badge in badges) {
        document.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(0),
            build: (context) => _buildBadgeHalf(
              badge,
              regular,
              bold,
              courier,
              scalePercent: s.singleScalePercent,
              offsetXmm: s.singleOffsetXmm,
              offsetYmm: s.singleOffsetYmm,
            ),
          ),
        );
      }
      return document;
    }

    // حالت دوتایی: جفت‌جفت روی برگهٔ A5 افقی (بیجک تکی آخر در نیمهٔ چپ)
    for (var i = 0; i < badges.length; i += 2) {
      final left = badges[i];
      final right = i + 1 < badges.length ? badges[i + 1] : null;
      document.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(0),
          build: (context) => pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Expanded(
                child: _buildBadgeHalf(
                  left,
                  regular,
                  bold,
                  courier,
                  scalePercent: s.dualScalePercent,
                  offsetXmm: s.dualOffsetXmm,
                  offsetYmm: s.dualOffsetYmm,
                ),
              ),
              // راهنمای برش وسط — خط باریک عمودی
              pw.Container(
                width: 0.6,
                color: PdfColor.fromHex('#b0b0b0'),
              ),
              pw.Expanded(
                child: right != null
                    ? _buildBadgeHalf(
                        right,
                        regular,
                        bold,
                        courier,
                        scalePercent: s.dualScalePercent,
                        offsetXmm: s.dualOffsetXmm,
                        offsetYmm: s.dualOffsetYmm,
                      )
                    : pw.SizedBox(),
              ),
            ],
          ),
        ),
      );
    }

    return document;
  }

  /// نیمهٔ A6 یک بیجک — کادر دورش تا بعد از برش، هر برگهٔ A6 کامل دیده شود.
  /// مقیاس و جابه‌جایی طبق تنظیمات حالتِ فعال اعمال می‌شود (مثل چاپ لیبل).
  static pw.Widget _buildBadgeHalf(
    BadgeData badge,
    pw.Font regular,
    pw.Font bold,
    pw.Font courier, {
    double scalePercent = 100,
    double offsetXmm = 0,
    double offsetYmm = 0,
  }) {
    return pw.Transform.translate(
      offset: PdfPoint(
        offsetXmm * PdfPageFormat.mm,
        offsetYmm * PdfPageFormat.mm,
      ),
      child: pw.Transform.scale(
        scale: scalePercent / 100,
        alignment: pw.Alignment.center,
        child: pw.Container(
          margin: const pw.EdgeInsets.all(3),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColor.fromHex('#d0d0d0'),
              width: 0.7,
            ),
          ),
          child: pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Container(
                  height: 16,
                  alignment: pw.Alignment.center,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 2),
                    ),
                  ),
                  child: pw.Text(
                    'MA WAREHOUSE',
                    style: pw.TextStyle(font: bold, fontSize: 8.5),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Container(
                  height: 18,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'بیجک سفارش ${badge.sequence} از ${badge.total}',
                    style: pw.TextStyle(font: bold, fontSize: 10),
                  ),
                ),
                pw.Container(
                  height: 12,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'برگه بیجک',
                    style: pw.TextStyle(
                      font: regular,
                      fontSize: 7,
                      color: PdfColor.fromHex('#4a4a4a'),
                    ),
                  ),
                ),
                _pdfDivider(),
                pw.Expanded(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      _pdfBadgeRow('فرستنده', badge.senderName, regular, bold),
                      if (badge.isTipax) ...[
                        _pdfBadgeRow(
                          'تلفن فرستنده',
                          badge.senderPhone,
                          regular,
                          bold,
                        ),
                        _pdfBadgeRow(
                          'کد ملی فرستنده',
                          badge.senderNationalId,
                          regular,
                          bold,
                        ),
                      ],
                      _pdfBadgeRow('گیرنده', badge.receiverName, regular, bold),
                      _pdfBadgeRow(
                        'شهر گیرنده',
                        badge.receiverCity,
                        regular,
                        bold,
                      ),
                      if (badge.isTipax) ...[
                        _pdfBadgeRow(
                          'کد پستی گیرنده',
                          badge.receiverPostalCode,
                          regular,
                          bold,
                        ),
                        _pdfBadgeRow(
                          'آدرس گیرنده',
                          badge.receiverAddress,
                          regular,
                          bold,
                        ),
                      ],
                  _pdfBadgeRow(
                    'تلفن گیرنده',
                    badge.receiverPhone,
                    regular,
                    bold,
                  ),
                  _pdfBadgeRow('مدل', badge.modelDisplay, regular, bold),
                  _pdfBadgeRow(
                    'تعداد ${badge.packageLabel}',
                    '${badge.packageCount}',
                    regular,
                    bold,
                  ),
                  _pdfBadgeRow(
                    'باربری',
                    badge.carrierLabel,
                    regular,
                    bold,
                  ),
                    ],
                  ),
                ),
                _pdfDivider(),
                pw.Container(
                  height: 16,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    badge.orderRef,
                    style: pw.TextStyle(font: courier, fontSize: 8),
                  ),
                ),
                pw.Container(
                  height: 12,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'MA-BADGE  |  ${badge.createdAt}',
                    style: pw.TextStyle(
                      font: regular,
                      fontSize: 6.5,
                      color: PdfColor.fromHex('#4a4a4a'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<bool> _showPrintDialog(
    pw.Document document,
    PdfPageFormat pageFormat,
  ) async {
    try {
      return await Printing.layoutPdf(
        name: 'warehouse_label.pdf',
        format: pageFormat,
        // صفحه‌ی PDF دقیقاً به اندازه‌ی لیبل فیزیکی است تا چاپگر محتوا را وسط قرار دهد
        forceCustomPrintPaper: true,
        onLayout: (format) async => document.save(),
      );
    } catch (_) {
      return false;
    }
  }

  static pw.Widget _pdfDivider() {
    return pw.Container(
      height: 5,
      alignment: pw.Alignment.center,
      child: pw.Container(
        height: 0.8,
        width: double.infinity,
        color: PdfColor.fromHex('#dcdcdc'),
      ),
    );
  }

  static pw.Widget _pdfInfoRow(
    String label,
    String value,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Container(
      height: 15,
      child: pw.Row(
        children: [
          pw.Text('▸ $label', style: pw.TextStyle(font: regular, fontSize: 7)),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              maxLines: 1,
              style: pw.TextStyle(font: bold, fontSize: 7),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfBadgeRow(
    String label,
    String value,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '▸ $label',
          style: pw.TextStyle(
            font: regular,
            fontSize: 10,
            color: PdfColor.fromHex('#4a4a4a'),
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: pw.Text(
            value.isEmpty ? '—' : value,
            textAlign: pw.TextAlign.right,
            maxLines: 2,
            style: pw.TextStyle(font: bold, fontSize: 10),
          ),
        ),
      ],
    );
  }
}
