// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_out_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScanOutResultModel _$ScanOutResultModelFromJson(Map<String, dynamic> json) =>
    _ScanOutResultModel(
      valid: json['valid'] as bool? ?? false,
      error: json['error'] as String? ?? '',
      carton: json['carton'] == null
          ? null
          : ScanOutCartonModel.fromJson(json['carton'] as Map<String, dynamic>),
      candidates: (json['candidates'] as List<dynamic>?)
          ?.map((e) => ScanOutTargetModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScanOutResultModelToJson(_ScanOutResultModel instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'error': instance.error,
      'carton': instance.carton,
      'candidates': instance.candidates,
    };

_ScanOutTargetModel _$ScanOutTargetModelFromJson(Map<String, dynamic> json) =>
    _ScanOutTargetModel(
      kind: json['kind'] as String? ?? '',
      id: json['id'] as String? ?? '',
      orderNumber: (json['orderNumber'] as num?)?.toInt(),
      city: json['city'] as String?,
      receiverName: json['receiverName'] as String?,
      carrier: json['carrier'] as String?,
      customerPhone: json['customerPhone'] as String?,
      productName: json['productName'] as String? ?? '',
      modelName: json['modelName'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      toWarehouseName: json['toWarehouseName'] as String?,
    );

Map<String, dynamic> _$ScanOutTargetModelToJson(_ScanOutTargetModel instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'city': instance.city,
      'receiverName': instance.receiverName,
      'carrier': instance.carrier,
      'customerPhone': instance.customerPhone,
      'productName': instance.productName,
      'modelName': instance.modelName,
      'quantity': instance.quantity,
      'toWarehouseName': instance.toWarehouseName,
    };

_ScanOutCartonModel _$ScanOutCartonModelFromJson(Map<String, dynamic> json) =>
    _ScanOutCartonModel(
      productName: json['productName'] as String? ?? '',
      modelName: json['modelName'] as String? ?? '',
      serialNumber: json['serialNumber'] as String?,
      isIndividualUnit: json['isIndividualUnit'] as bool?,
      capacityPerBox: (json['capacityPerBox'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      packageType: json['packageType'] as String?,
      transfer: json['transfer'] == null
          ? null
          : ScanOutTransferModel.fromJson(
              json['transfer'] as Map<String, dynamic>,
            ),
      order: json['order'] == null
          ? null
          : ScanOutOrderModel.fromJson(json['order'] as Map<String, dynamic>),
      driver: json['driver'] == null
          ? null
          : ScanOutDriverModel.fromJson(json['driver'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ScanOutCartonModelToJson(_ScanOutCartonModel instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'modelName': instance.modelName,
      'serialNumber': instance.serialNumber,
      'isIndividualUnit': instance.isIndividualUnit,
      'capacityPerBox': instance.capacityPerBox,
      'unit': instance.unit,
      'packageType': instance.packageType,
      'transfer': instance.transfer,
      'order': instance.order,
      'driver': instance.driver,
    };

_ScanOutOrderModel _$ScanOutOrderModelFromJson(Map<String, dynamic> json) =>
    _ScanOutOrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: (json['orderNumber'] as num?)?.toInt(),
      customerPhone: json['customerPhone'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$ScanOutOrderModelToJson(_ScanOutOrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'customerPhone': instance.customerPhone,
      'city': instance.city,
      'address': instance.address,
    };

_ScanOutDriverModel _$ScanOutDriverModelFromJson(Map<String, dynamic> json) =>
    _ScanOutDriverModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$ScanOutDriverModelToJson(_ScanOutDriverModel instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_ScanOutTransferModel _$ScanOutTransferModelFromJson(
  Map<String, dynamic> json,
) => _ScanOutTransferModel(
  id: json['id'] as String,
  toWarehouseId: json['toWarehouseId'] as String?,
  toWarehouseName: json['toWarehouseName'] as String?,
);

Map<String, dynamic> _$ScanOutTransferModelToJson(
  _ScanOutTransferModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'toWarehouseId': instance.toWarehouseId,
  'toWarehouseName': instance.toWarehouseName,
};
