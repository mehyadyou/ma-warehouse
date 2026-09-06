import 'package:shamsi_date/shamsi_date.dart';

String _asString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

/// تاریخ میلادی (ISO) را به شمسی با ارقام فارسی تبدیل می‌کند — قالب «۱۴۰۴/۰۵/۲۵»
String toJalaliDate(dynamic value) {
  final raw = _asString(value);
  if (raw.isEmpty) return '—';
  // تاریخ‌ها معمولاً ISO با زمان (T...) هستند — فقط بخش تاریخ جدا می‌شود
  final datePart = raw.contains('T') ? raw.substring(0, 10) : raw;
  final parts = datePart.split('-');
  if (parts.length != 3) return datePart;
  final yr = int.tryParse(parts[0]);
  final mo = int.tryParse(parts[1]);
  final dy = int.tryParse(parts[2]);
  if (yr == null || mo == null || dy == null) return datePart;
  final j = Jalali.fromDateTime(DateTime(yr, mo, dy));
  String two(int v) => v.toString().padLeft(2, '0');
  String fa(String s) => s.split('').map((c) {
    final i = int.tryParse(c);
    return i == null ? c : '۰۱۲۳۴۵۶۷۸۹'[i];
  }).join();
  return '${fa('${j.year}')}/${fa(two(j.month))}/${fa(two(j.day))}';
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

/// اولویت با عکسِ لحظهٔ ثبت روی خودِ بیجک؛ برای بیجک‌های قدیمی‌تر از اطلاعات سفارش
String _snapshotOr(String snapshot, String orderFallback) =>
    snapshot.isNotEmpty ? snapshot : orderFallback;

class BadgeData {
  final int sequence;
  final int total;
  final int count;

  /// عکسِ قلمِ اولِ سفارش (از پنل مدیریت): نام مدل + نحوهٔ بسته‌بندی و تعداد هر بسته
  final String modelName;
  final String packageType;
  final int? unitsPerBox;

  final String senderName;
  final String senderPhone;
  final String senderNationalId;
  final String receiverName;
  final String receiverCity;
  final String receiverPostalCode;
  final String receiverAddress;
  final String receiverPhone;
  final String shippingMethod;
  final String carrier;
  final String orderRef;
  final String createdAt;

  BadgeData({
    required this.sequence,
    required this.total,
    required this.count,
    required this.modelName,
    required this.packageType,
    required this.unitsPerBox,
    required this.senderName,
    required this.senderPhone,
    required this.senderNationalId,
    required this.receiverName,
    required this.receiverCity,
    required this.receiverPostalCode,
    required this.receiverAddress,
    required this.receiverPhone,
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
      count: (badge['count'] as num?)?.toInt() ?? 1,
      modelName: _asString(badge['modelName']),
      packageType: _asString(badge['packageType']),
      unitsPerBox: (badge['unitsPerBox'] as num?)?.toInt(),
      senderName: _asString(badge['senderName']),
      senderPhone: _snapshotOr(
        _asString(badge['senderPhone']),
        _asString(order['senderPhone']),
      ),
      senderNationalId: _snapshotOr(
        _asString(badge['senderNationalId']),
        _asString(order['senderNationalId']),
      ),
      receiverName: _asString(badge['receiverName']),
      receiverCity: _snapshotOr(
        _asString(badge['receiverCity']),
        _asString(order['city']),
      ),
      receiverPostalCode: _snapshotOr(
        _asString(badge['receiverPostalCode']),
        _asString(order['postalCode']),
      ),
      receiverAddress: _snapshotOr(
        _asString(badge['receiverAddress']),
        _asString(order['address']),
      ),
      receiverPhone: _snapshotOr(
        _asString(badge['receiverPhone']),
        _asString(order['customerPhone']),
      ),
      shippingMethod: _asString(order['shippingMethod']),
      carrier: _asString(order['carrier']),
      orderRef: shortOrderId(_asString(badge['orderId'])),
      createdAt: toJalaliDate(badge['createdAt']),
    );
  }

  bool get isTipax => shippingMethod.trim() == 'تیپاکس';
  bool get isBarebari => shippingMethod.trim() == 'باربری';
  bool get missingReceiver => receiverName.isEmpty;

  /// نام باربری/روش ارسال برای نمایش روی برگهٔ بیجک — عیناً معادلِ
  /// `badgeCarrierLabel` در بک‌اند (orders.service.ts):
  /// تیپاکس → «تیپاکس» · باربری → نام دقیق باربریِ ثبت‌شده (یا «باربری» اگر ثبت نشده)
  String get carrierLabel {
    final method = shippingMethod.trim();
    final c = carrier.trim();
    if (method == 'تیپاکس') return 'تیپاکس';
    if (method == 'باربری') return c.isNotEmpty ? c : 'باربری';
    return c.isNotEmpty ? c : (method.isEmpty ? '—' : method);
  }

  /// برچسب نوع بسته از پنل مدیریت (کارتن/کیسه/…) — پیش‌فرض «کارتن»
  String get packageLabel {
    final t = packageType.trim();
    return t.isEmpty ? 'کارتن' : t;
  }

  /// نام مدل برای نمایش روی برگه — اگر ثبت نشده باشد «—»
  String get modelDisplay {
    final t = modelName.trim();
    return t.isEmpty ? '—' : t;
  }

  /// تعداد بسته‌ها = تعداد کل ÷ ظرفیت هر بسته (گردشده به بالا)؛
  /// اگر ظرفیت ثبت نشده باشد همان تعداد کل
  int get packageCount {
    final cap = unitsPerBox;
    if (cap == null || cap <= 0) return count;
    return (count / cap).ceil();
  }
}
