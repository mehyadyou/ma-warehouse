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
    );

Map<String, dynamic> _$ScanOutResultModelToJson(_ScanOutResultModel instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'error': instance.error,
      'carton': instance.carton,
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
    };

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
