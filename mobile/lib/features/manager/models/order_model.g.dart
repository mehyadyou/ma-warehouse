// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => _OrderModel(
  id: json['id'] as String,
  orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
  version: (json['version'] as num?)?.toInt() ?? 0,
  senderName: json['senderName'] as String?,
  receiverName: json['receiverName'] as String?,
  customerPhone: json['customerPhone'] as String?,
  city: json['city'] as String?,
  address: json['address'] as String?,
  postalCode: json['postalCode'] as String?,
  shippingMethod: json['shippingMethod'] as String?,
  carrier: json['carrier'] as String?,
  warehouseName: json['warehouseName'] as String?,
  driverName: json['driverName'] as String?,
  status: json['status'] as String?,
  deliveryStatus: json['deliveryStatus'] as String?,
  badgeCount: (json['badgeCount'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String?,
  deliveredAt: json['deliveredAt'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OrderItemModel>[],
);

Map<String, dynamic> _$OrderModelToJson(_OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'version': instance.version,
      'senderName': instance.senderName,
      'receiverName': instance.receiverName,
      'customerPhone': instance.customerPhone,
      'city': instance.city,
      'address': instance.address,
      'postalCode': instance.postalCode,
      'shippingMethod': instance.shippingMethod,
      'carrier': instance.carrier,
      'warehouseName': instance.warehouseName,
      'driverName': instance.driverName,
      'status': instance.status,
      'deliveryStatus': instance.deliveryStatus,
      'badgeCount': instance.badgeCount,
      'createdAt': instance.createdAt,
      'deliveredAt': instance.deliveredAt,
      'items': instance.items,
    };

_OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    _OrderItemModel(
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      model: json['model'] as String?,
      quantity: json['quantity'] == null ? 0 : _toNum(json['quantity']),
      price: _toNum(json['price']),
      exchangeRate: _toNum(json['exchangeRate']),
    );

Map<String, dynamic> _$OrderItemModelToJson(_OrderItemModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'model': instance.model,
      'quantity': instance.quantity,
      'price': instance.price,
      'exchangeRate': instance.exchangeRate,
    };

_OrderCountsModel _$OrderCountsModelFromJson(Map<String, dynamic> json) =>
    _OrderCountsModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      inTransit: (json['inTransit'] as num?)?.toInt() ?? 0,
      delivered: (json['delivered'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$OrderCountsModelToJson(_OrderCountsModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'pending': instance.pending,
      'inTransit': instance.inTransit,
      'delivered': instance.delivered,
    };
