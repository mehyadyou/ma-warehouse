// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShipmentReportModel _$ShipmentReportModelFromJson(Map<String, dynamic> json) =>
    _ShipmentReportModel(
      totalShipments: json['totalShipments'] as num? ?? 0,
      totalUnits: json['totalUnits'] as num? ?? 0,
      totalWarehouses: json['totalWarehouses'] as num? ?? 0,
      lastShipment: json['lastShipment'] == null
          ? null
          : ShipmentOrderModel.fromJson(
              json['lastShipment'] as Map<String, dynamic>,
            ),
      warehouses:
          (json['warehouses'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ShipmentWarehouseModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ShipmentReportModelToJson(
  _ShipmentReportModel instance,
) => <String, dynamic>{
  'totalShipments': instance.totalShipments,
  'totalUnits': instance.totalUnits,
  'totalWarehouses': instance.totalWarehouses,
  'lastShipment': instance.lastShipment,
  'warehouses': instance.warehouses,
};

_ShipmentWarehouseModel _$ShipmentWarehouseModelFromJson(
  Map<String, dynamic> json,
) => _ShipmentWarehouseModel(
  warehouseId: json['warehouseId'] as String?,
  warehouseName: json['warehouseName'] as String?,
  totalCount: json['totalCount'] as num? ?? 0,
  lastShipmentAt: json['lastShipmentAt'] as String?,
  daily:
      (json['daily'] as List<dynamic>?)
          ?.map((e) => ShipmentDayModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ShipmentWarehouseModelToJson(
  _ShipmentWarehouseModel instance,
) => <String, dynamic>{
  'warehouseId': instance.warehouseId,
  'warehouseName': instance.warehouseName,
  'totalCount': instance.totalCount,
  'lastShipmentAt': instance.lastShipmentAt,
  'daily': instance.daily,
};

_ShipmentDayModel _$ShipmentDayModelFromJson(Map<String, dynamic> json) =>
    _ShipmentDayModel(
      date: json['date'] as String?,
      count: json['count'] as num? ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => ShipmentOrderModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ShipmentDayModelToJson(_ShipmentDayModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'count': instance.count,
      'items': instance.items,
    };

_ShipmentOrderModel _$ShipmentOrderModelFromJson(Map<String, dynamic> json) =>
    _ShipmentOrderModel(
      orderId: json['orderId'] as String?,
      warehouseId: json['warehouseId'] as String?,
      warehouseName: json['warehouseName'] as String?,
      status: json['status'] as String?,
      city: json['city'] as String?,
      receiverName: json['receiverName'] as String?,
      senderName: json['senderName'] as String?,
      carrier: json['carrier'] as String?,
      createdByName: json['createdByName'] as String?,
      createdAt: json['createdAt'] as String?,
      totalUnits: json['totalUnits'] as num? ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => ShipmentItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ShipmentOrderModelToJson(_ShipmentOrderModel instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'warehouseId': instance.warehouseId,
      'warehouseName': instance.warehouseName,
      'status': instance.status,
      'city': instance.city,
      'receiverName': instance.receiverName,
      'senderName': instance.senderName,
      'carrier': instance.carrier,
      'createdByName': instance.createdByName,
      'createdAt': instance.createdAt,
      'totalUnits': instance.totalUnits,
      'items': instance.items,
    };

_ShipmentItemModel _$ShipmentItemModelFromJson(Map<String, dynamic> json) =>
    _ShipmentItemModel(
      productName: json['productName'] as String?,
      quantity: json['quantity'] as num? ?? 0,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$ShipmentItemModelToJson(_ShipmentItemModel instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'quantity': instance.quantity,
      'unit': instance.unit,
    };
