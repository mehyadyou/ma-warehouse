import '../models/order_model.dart';
import 'invoice_models.dart';

/// تبدیل سفارش ثبت‌شده توسط مدیر به پیش‌نویس فاکتور
///
/// شماره فاکتور و تاریخ خالی می‌مانند تا بیلدر آن‌ها را خودکار پر کند؛
/// شناسه سفارش در [InvoiceDraftModel.sourceOrderId] نگهداری می‌شود تا
/// سفارش دوبار فاکتور نشود.
InvoiceDraftModel convertOrderToInvoice(
  OrderModel order, {
  required InvoicePartyModel seller,
}) {
  final city = order.city?.trim() ?? '';
  final address = order.address?.trim() ?? '';
  final fullAddress = city.isNotEmpty
      ? [city, address].where((part) => part.isNotEmpty).join(' — ')
      : address;

  return InvoiceDraftModel(
    type: InvoiceType.simple,
    seller: seller,
    buyer: InvoicePartyModel(
      name: order.receiverName?.trim() ?? '',
      phone: order.customerPhone?.trim() ?? '',
      address: fullAddress,
    ),
    items: order.items
        .map((item) => InvoiceItemModel(
              description: [
                item.productName?.trim() ?? '',
                item.model?.trim() ?? '',
              ].where((part) => part.isNotEmpty).join(' — '),
              quantity: item.quantity,
              unit: 'عدد',
              unitPrice: item.price ?? 0,
            ))
        .toList(),
    notes: _orderNotes(order),
    sourceOrderId: order.id,
  );
}

/// جمع مبلغ سفارش (تومان) برای نمایش در صندوق — فقط نمایش، بدون محاسبه مالیات
num orderTotal(OrderModel order) =>
    order.items.fold(0, (sum, item) => sum + (item.price ?? 0) * item.quantity);

String _orderNotes(OrderModel order) {
  final parts = <String>[
    if ((order.shippingMethod?.trim() ?? '').isNotEmpty)
      'روش حمل: ${order.shippingMethod!.trim()}',
    if ((order.carrier?.trim() ?? '').isNotEmpty)
      'باربری: ${order.carrier!.trim()}',
    if ((order.driverName?.trim() ?? '').isNotEmpty)
      'راننده: ${order.driverName!.trim()}',
  ];
  return parts.join(' — ');
}