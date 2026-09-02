/// یک رکورد صندوق تحویل — عکس بیجک باربری به‌همراه سفارش و راننده
class DeliveryInboxItem {
  final String id;
  final String? receiptUrl;
  final DateTime? deliveredAt;
  final String? notes;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? warehouseId;
  final int? orderNumber;
  final String? carrier;
  final String? receiverName;
  final String? city;
  final String? address;
  final String? customerPhone;

  const DeliveryInboxItem({
    required this.id,
    this.receiptUrl,
    this.deliveredAt,
    this.notes,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.warehouseId,
    this.orderNumber,
    this.carrier,
    this.receiverName,
    this.city,
    this.address,
    this.customerPhone,
  });

  factory DeliveryInboxItem.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final order = json['order'];
    final driverMap = driver is Map ? Map<String, dynamic>.from(driver) : null;
    final orderMap = order is Map ? Map<String, dynamic>.from(order) : null;
    return DeliveryInboxItem(
      id: json['id'] as String? ?? '',
      receiptUrl: json['receiptUrl'] as String?,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'] as String)
          : null,
      notes: json['notes'] as String?,
      driverId: driverMap?['id'] as String?,
      driverName: driverMap?['name'] as String?,
      driverPhone: driverMap?['phone'] as String?,
      warehouseId: orderMap?['warehouseId'] as String?,
      orderNumber: orderMap?['orderNumber'] as int?,
      carrier: orderMap?['carrier'] as String?,
      receiverName: orderMap?['receiverName'] as String?,
      city: orderMap?['city'] as String?,
      address: orderMap?['address'] as String?,
      customerPhone: orderMap?['customerPhone'] as String?,
    );
  }
}

/// راننده‌ای که حداقل یک بیجک در صندوق ثبت کرده — برای فیلتر راننده
class DeliveryInboxDriver {
  final String id;
  final String? name;
  final String? phone;

  const DeliveryInboxDriver({required this.id, this.name, this.phone});

  factory DeliveryInboxDriver.fromJson(Map<String, dynamic> json) {
    return DeliveryInboxDriver(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      phone: json['phone'] as String?,
    );
  }
}