// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carton_search_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartonSearchModel _$CartonSearchModelFromJson(Map<String, dynamic> json) =>
    _CartonSearchModel(
      cartonStatus: json['cartonStatus'] as String?,
      orderStatus: json['orderStatus'] as String?,
      orderId: json['orderId'] as String?,
      relatedOrders:
          (json['relatedOrders'] as List<dynamic>?)
              ?.map(
                (e) => RelatedOrderModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <RelatedOrderModel>[],
      productName: json['productName'] as String?,
      modelName: json['modelName'] as String?,
      warehouseName: json['warehouseName'] as String?,
      serialNumber: json['serialNumber'] as String?,
      qrUuid: json['qrUuid'] as String?,
      createdAt: json['createdAt'] as String?,
      scannedOutAt: json['scannedOutAt'] as String?,
      senderName: json['senderName'] as String?,
      receiverName: json['receiverName'] as String?,
      city: json['city'] as String?,
      driverName: json['driverName'] as String?,
      deliveredAt: json['deliveredAt'] as String?,
    );

Map<String, dynamic> _$CartonSearchModelToJson(_CartonSearchModel instance) =>
    <String, dynamic>{
      'cartonStatus': instance.cartonStatus,
      'orderStatus': instance.orderStatus,
      'orderId': instance.orderId,
      'relatedOrders': instance.relatedOrders,
      'productName': instance.productName,
      'modelName': instance.modelName,
      'warehouseName': instance.warehouseName,
      'serialNumber': instance.serialNumber,
      'qrUuid': instance.qrUuid,
      'createdAt': instance.createdAt,
      'scannedOutAt': instance.scannedOutAt,
      'senderName': instance.senderName,
      'receiverName': instance.receiverName,
      'city': instance.city,
      'driverName': instance.driverName,
      'deliveredAt': instance.deliveredAt,
    };

_RelatedOrderModel _$RelatedOrderModelFromJson(Map<String, dynamic> json) =>
    _RelatedOrderModel(
      order: json['order'] == null
          ? const CartonOrderRefModel()
          : CartonOrderRefModel.fromJson(json['order'] as Map<String, dynamic>),
      quantity: json['quantity'] as num? ?? 0,
    );

Map<String, dynamic> _$RelatedOrderModelToJson(_RelatedOrderModel instance) =>
    <String, dynamic>{'order': instance.order, 'quantity': instance.quantity};

_CartonOrderRefModel _$CartonOrderRefModelFromJson(Map<String, dynamic> json) =>
    _CartonOrderRefModel(
      status: json['status'] as String?,
      senderName: json['senderName'] as String?,
      receiverName: json['receiverName'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$CartonOrderRefModelToJson(
  _CartonOrderRefModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'senderName': instance.senderName,
  'receiverName': instance.receiverName,
  'createdAt': instance.createdAt,
};
