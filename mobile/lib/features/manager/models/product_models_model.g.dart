// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_models_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductModelsData _$ProductModelsDataFromJson(Map<String, dynamic> json) =>
    _ProductModelsData(
      product: json['product'] == null
          ? null
          : ProductModelInfo.fromJson(json['product'] as Map<String, dynamic>),
      models:
          (json['models'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ProductModelStockModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ProductModelStockModel>[],
    );

Map<String, dynamic> _$ProductModelsDataToJson(_ProductModelsData instance) =>
    <String, dynamic>{'product': instance.product, 'models': instance.models};

_ProductModelInfo _$ProductModelInfoFromJson(Map<String, dynamic> json) =>
    _ProductModelInfo(
      id: json['id'] as String?,
      name: json['name'] as String?,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$ProductModelInfoToJson(_ProductModelInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
    };

_ProductModelStockModel _$ProductModelStockModelFromJson(
  Map<String, dynamic> json,
) => _ProductModelStockModel(
  modelId: json['modelId'] as String?,
  name: json['name'] as String?,
  packageType: json['packageType'] as String?,
  unitsPerBox: json['unitsPerBox'] as num?,
  count: json['count'] as num? ?? 0,
  warehouses:
      (json['warehouses'] as List<dynamic>?)
          ?.map(
            (e) => ModelWarehouseRowModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ModelWarehouseRowModel>[],
);

Map<String, dynamic> _$ProductModelStockModelToJson(
  _ProductModelStockModel instance,
) => <String, dynamic>{
  'modelId': instance.modelId,
  'name': instance.name,
  'packageType': instance.packageType,
  'unitsPerBox': instance.unitsPerBox,
  'count': instance.count,
  'warehouses': instance.warehouses,
};

_ModelWarehouseRowModel _$ModelWarehouseRowModelFromJson(
  Map<String, dynamic> json,
) => _ModelWarehouseRowModel(
  warehouseId: json['warehouseId'] as String?,
  warehouseName: json['warehouseName'] as String?,
  count: json['count'] as num? ?? 0,
);

Map<String, dynamic> _$ModelWarehouseRowModelToJson(
  _ModelWarehouseRowModel instance,
) => <String, dynamic>{
  'warehouseId': instance.warehouseId,
  'warehouseName': instance.warehouseName,
  'count': instance.count,
};
