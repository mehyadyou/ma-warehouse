import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/invoices/invoice_models.dart';
import 'package:ma_app/features/manager/invoices/invoice_order_converter.dart';
import 'package:ma_app/features/manager/models/order_model.dart';

void main() {
  const seller = InvoicePartyModel(
    name: 'شرکت ما',
    phone: '۰۲۱',
    address: 'تهران',
    economicCode: '۱۲۳',
  );

  test('تبدیل سفارش به فاکتور: خریدار و اقلام به‌درستی نگاشت می‌شوند', () {
    final order = OrderModel(
      id: 'order-1',
      receiverName: 'رضا محمدی',
      customerPhone: '۰۹۱۲۳۴',
      city: 'کرج',
      address: 'خیابان امام',
      shippingMethod: 'باربری',
      carrier: 'پارس',
      driverName: 'احمد',
      items: const [
        OrderItemModel(
          productId: 'p1',
          productName: 'یخچال',
          model: 'A-100',
          quantity: 2,
          price: 5000,
        ),
        OrderItemModel(
          productId: 'p2',
          productName: 'تلویزیون',
          quantity: 1,
          price: 3000,
        ),
      ],
    );

    final invoice = convertOrderToInvoice(order, seller: seller);

    expect(invoice.sourceOrderId, 'order-1');
    expect(invoice.type, InvoiceType.simple);
    expect(invoice.seller, seller);
    expect(invoice.buyer.name, 'رضا محمدی');
    expect(invoice.buyer.phone, '۰۹۱۲۳۴');
    expect(invoice.buyer.address, 'کرج — خیابان امام');

    expect(invoice.items.length, 2);
    expect(invoice.items[0].description, 'یخچال — A-100');
    expect(invoice.items[0].quantity, 2);
    expect(invoice.items[0].unit, 'عدد');
    expect(invoice.items[0].unitPrice, 5000);
    expect(invoice.items[1].description, 'تلویزیون');
    expect(invoice.items[1].unitPrice, 3000);

    expect(invoice.notes, contains('روش حمل: باربری'));
    expect(invoice.notes, contains('باربری: پارس'));
    expect(invoice.notes, contains('راننده: احمد'));

    // شماره و تاریخ خالی می‌مانند تا بیلدر خودکار پر کند
    expect(invoice.number, '');
    expect(invoice.dateLabel, '');
    expect(invoice.grandTotal, 2 * 5000 + 1 * 3000);
  });

  test('سفارش بدون اطلاعات جانبی، فاکتور حداقلی می‌سازد', () {
    final order = OrderModel(id: 'order-2');
    final invoice = convertOrderToInvoice(order, seller: seller);

    expect(invoice.buyer.name, '');
    expect(invoice.buyer.address, '');
    expect(invoice.items, isEmpty);
    expect(invoice.notes, '');
    expect(invoice.grandTotal, 0);
  });

  test('جمع مبلغ سفارش برابر مجموع قیمت×تعداد است', () {
    final order = OrderModel(
      id: 'order-3',
      items: const [
        OrderItemModel(productName: 'الف', quantity: 3, price: 1000),
        OrderItemModel(productName: 'ب', quantity: 2, price: null),
      ],
    );
    expect(orderTotal(order), 3000);
  });
}