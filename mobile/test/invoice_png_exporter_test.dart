import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/invoices/invoice_models.dart';
import 'package:ma_app/features/manager/invoices/invoice_png_exporter.dart';
import 'package:ma_app/features/manager/invoices/invoice_widget.dart';

void main() {
  testWidgets('خروجی PNG از قالب فاکتور ساخته می‌شود', (tester) async {
    final key = GlobalKey();
    final invoice = InvoiceDraftModel(
      number: '۱',
      dateLabel: '۱۴۰۵/۰۵/۲۸',
      seller: const InvoicePartyModel(name: 'فروشنده'),
      buyer: const InvoicePartyModel(name: 'خریدار'),
      items: const [InvoiceItemModel(description: 'قلم', quantity: 2, unitPrice: 500)],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: key,
          child: InvoiceView(invoice: invoice),
        ),
      ),
    );
    await tester.pump();

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final bytes = await InvoicePngExporter.capture(boundary);

      expect(bytes, isNotEmpty);
      // امضای فایل PNG
      expect(
        bytes.sublist(0, 8),
        [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
      );
    });
  });
}