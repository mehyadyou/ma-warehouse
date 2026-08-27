String _asString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

String _first10(String value) {
  if (value.length > 10) return value.substring(0, 10);
  return value;
}

String shortOrderId(String orderId) {
  final raw = orderId.replaceAll('-', '').toUpperCase();
  final short = raw.length > 8 ? raw.substring(0, 8) : raw;
  return 'MA-$short';
}

class LabelData {
  final String productName;
  final String modelDisplay;
  final String qtyText;
  final String serial;
  final String barcode;
  final String tracking;
  final String date;
  final String qrPayload;

  LabelData({
    required this.productName,
    required this.modelDisplay,
    required this.qtyText,
    required this.serial,
    required this.barcode,
    required this.tracking,
    required this.date,
    required this.qrPayload,
  });

  factory LabelData.fromCarton(Map<String, dynamic> carton) {
    final product = carton['product'];
    final productName = product is Map<String, dynamic>
        ? _asString(product['name'])
        : _asString(carton['productName']);

    final model = carton['model'];
    final String modelName;
    final dynamic units;
    if (model is Map<String, dynamic>) {
      modelName = _asString(model['name']);
      units = model['unitsPerBox'];
    } else {
      modelName = _asString(carton['modelName']);
      units = carton['capacityPerBox'];
    }

    final modelDisplay =
        (modelName.isNotEmpty ? modelName : productName).isNotEmpty
        ? (modelName.isNotEmpty ? modelName : productName)
        : '—';
    final isIndividual =
        carton['isIndividual'] == true || carton['isIndividualUnit'] == true;
    final qtyText = isIndividual
        ? '۱ عدد (تکی)'
        : '${units ?? '?'} عدد / کارتن';

    var serial = _asString(carton['serialNumber']);
    if (serial.isEmpty) {
      final rawId = _asString(carton['qrUuid']).isNotEmpty
          ? _asString(carton['qrUuid'])
          : _asString(carton['id']);
      serial = rawId.replaceAll('-', '').toUpperCase();
      if (serial.length > 8) serial = serial.substring(0, 8);
    }
    final barcode =
        (serial.length > 16 ? serial.substring(0, 16) : serial).isNotEmpty
        ? (serial.length > 16 ? serial.substring(0, 16) : serial)
        : '000000';
    final tracking = serial.isNotEmpty ? serial : 'MA-XXXXXXXX';
    final dateValue = _asString(carton['createdAt']).isEmpty
        ? '—'
        : _first10(_asString(carton['createdAt']));
    final qrPayload = _asString(carton['qrPayload']).isNotEmpty
        ? _asString(carton['qrPayload'])
        : tracking;

    return LabelData(
      productName: productName,
      modelDisplay: modelDisplay,
      qtyText: qtyText,
      serial: serial,
      barcode: barcode,
      tracking: tracking,
      date: dateValue,
      qrPayload: qrPayload,
    );
  }
}

const orderStatusLabels = {
  'PENDING': 'در انتظار',
  'IN_TRANSIT': 'در مسیر ارسال',
  'DELIVERED': 'تحویل شده',
  'CANCELLED': 'لغو شده',
};

class BadgeData {
  final int sequence;
  final int total;
  final String senderName;
  final String receiverName;
  final String city;
  final String address;
  final String postalCode;
  final String shippingMethod;
  final String carrier;
  final String orderRef;
  final String createdAt;

  BadgeData({
    required this.sequence,
    required this.total,
    required this.senderName,
    required this.receiverName,
    required this.city,
    required this.address,
    required this.postalCode,
    required this.shippingMethod,
    required this.carrier,
    required this.orderRef,
    required this.createdAt,
  });

  factory BadgeData.fromBadge(Map<String, dynamic> badge, {int? total}) {
    final order = badge['order'] is Map<String, dynamic>
        ? badge['order'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final sequence = (badge['sequence'] as num?)?.toInt() ?? 1;
    return BadgeData(
      sequence: sequence,
      total: total ?? (badge['total'] as num?)?.toInt() ?? sequence,
      senderName: _asString(badge['senderName']),
      receiverName: _asString(badge['receiverName']),
      city: _asString(order['city']),
      address: _asString(order['address']),
      postalCode: _asString(order['postalCode']),
      shippingMethod: _asString(order['shippingMethod']),
      carrier: _asString(order['carrier']),
      orderRef: shortOrderId(_asString(badge['orderId'])),
      createdAt: _asString(badge['createdAt']).isEmpty
          ? '—'
          : _first10(_asString(badge['createdAt'])),
    );
  }

  bool get missingReceiver => receiverName.isEmpty;
}
