// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WarehouseStatsModel _$WarehouseStatsModelFromJson(Map<String, dynamic> json) =>
    _WarehouseStatsModel(
      productCount: json['productCount'] as num? ?? 0,
      inCount: json['inCount'] as num? ?? 0,
      outCount: json['outCount'] as num? ?? 0,
      totalUnits: json['totalUnits'] as num? ?? 0,
      totalCartons: json['totalCartons'] as num? ?? 0,
    );

Map<String, dynamic> _$WarehouseStatsModelToJson(
  _WarehouseStatsModel instance,
) => <String, dynamic>{
  'productCount': instance.productCount,
  'inCount': instance.inCount,
  'outCount': instance.outCount,
  'totalUnits': instance.totalUnits,
  'totalCartons': instance.totalCartons,
};

_WarehouseProductStockModel _$WarehouseProductStockModelFromJson(
  Map<String, dynamic> json,
) => _WarehouseProductStockModel(
  name: json['name'] as String?,
  unit: json['unit'] as String?,
  totalCount: json['totalCount'] as num? ?? 0,
  cartonCount: json['cartonCount'] as num? ?? 0,
  individualCount: json['individualCount'] as num? ?? 0,
  modelCount: json['modelCount'] as num? ?? 0,
  models:
      (json['models'] as List<dynamic>?)
          ?.map(
            (e) => WarehouseModelStockModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <WarehouseModelStockModel>[],
);

Map<String, dynamic> _$WarehouseProductStockModelToJson(
  _WarehouseProductStockModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'unit': instance.unit,
  'totalCount': instance.totalCount,
  'cartonCount': instance.cartonCount,
  'individualCount': instance.individualCount,
  'modelCount': instance.modelCount,
  'models': instance.models,
};

_WarehouseModelStockModel _$WarehouseModelStockModelFromJson(
  Map<String, dynamic> json,
) => _WarehouseModelStockModel(
  name: json['name'] as String?,
  totalCount: json['totalCount'] as num? ?? 0,
  cartonCount: json['cartonCount'] as num? ?? 0,
  individualCount: json['individualCount'] as num? ?? 0,
);

Map<String, dynamic> _$WarehouseModelStockModelToJson(
  _WarehouseModelStockModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'totalCount': instance.totalCount,
  'cartonCount': instance.cartonCount,
  'individualCount': instance.individualCount,
};
