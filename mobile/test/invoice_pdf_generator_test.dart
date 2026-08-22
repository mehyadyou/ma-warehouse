import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/invoices/invoice_models.dart';
import 'package:ma_app/features/manager/invoices/invoice_pdf_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('تولید PDF اسموک: خروجی بایت‌های PDF سالم دارد', () async {
    final invoice = InvoiceDraftModel(
      number: '۱۴۰۵-۰۰۱',
      dateLabel: '۱۴۰۵/۰۵/۲۸',
      type: InvoiceType.formal,
      paymentMethod: 'نقدی',
      seller: const InvoicePartyModel(
        name: 'فروشگاه نمونه',
        phone: '۰۲۱۱۲۳',
        address: 'تهران، خیابان آزادی',
        economicCode: '۱۲۳۴۵۶',
      ),
      buyer: const InvoicePartyModel(name: 'مشتری نمونه', address: 'کرج'),
      items: const [
        InvoiceItemModel(description: 'سینک ظرفشویی', quantity: 2, unitPrice: 1000),
        InvoiceItemModel(description: 'کولر گازی', quantity: 1, unitPrice: 500),
      ],
      includeTax: true,
      shippingCost: 100,
      notes: 'شرایط پرداخت: نقدی',
    );

    final Uint8List bytes = await InvoicePdfGenerator.generate(invoice);

    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
  });
}