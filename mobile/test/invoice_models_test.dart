import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/invoices/invoice_models.dart';

InvoiceDraftModel _sample() {
  return InvoiceDraftModel(
    id: '1',
    number: '۱۴۰۵-۰۰۱',
    dateLabel: '۱۴۰۵/۰۵/۲۸',
    type: InvoiceType.formal,
    paymentMethod: 'نقدی',
    seller: const InvoicePartyModel(
      name: 'فروشگاه ما',
      phone: '۰۲۱۱۲۳۴۵',
      economicCode: '۱۲۳۴۵',
      registerNumber: '۹۹۹',
    ),
    buyer: const InvoicePartyModel(name: 'مشتری نمونه'),
    items: const [
      InvoiceItemModel(description: 'سینک ظرفشویی', quantity: 2, unitPrice: 1000, discount: 100),
      InvoiceItemModel(description: 'کولر گازی', quantity: 1, unitPrice: 500),
    ],
    includeTax: true,
    taxPercent: 9,
    shippingCost: 100,
    notes: 'تست',
  );
}

void main() {
  group('InvoiceItemModel', () {
    test('جمع ردیف = (تعداد × قیمت) − تخفیف', () {
      const item = InvoiceItemModel(quantity: 2, unitPrice: 1000, discount: 100);
      expect(item.rowTotal, 1900);
    });
  });

  group('InvoiceDraftModel', () {
    test('محاسبه جمع‌ها', () {
      final invoice = _sample();
      expect(invoice.subtotal, 2400);
      expect(invoice.taxAmount, 216);
      expect(invoice.grandTotal, 2716);
    });

    test('بدون ارزش افزوده در فاکتور ساده', () {
      final invoice = _sample().copyWith(type: InvoiceType.simple);
      expect(invoice.taxAmount, 0);
      expect(invoice.grandTotal, 2500);
    });

    test('کپی JSON رفت و برگشتی سالم است', () {
      final invoice = _sample();
      final restored = InvoiceDraftModel.fromJson(invoice.toJson());
      expect(restored, invoice);
    });

    test('copyWithResetId فقط شناسه و PDF را پاک می‌کند', () {
      final reset = _sample().copyWithResetId();
      expect(reset.id, '');
      expect(reset.pdfPath, isNull);
      expect(reset.createdAt, '');
      expect(reset.number, '۱۴۰۵-۰۰۱');
      expect(reset.items.length, 2);
    });
  });
}