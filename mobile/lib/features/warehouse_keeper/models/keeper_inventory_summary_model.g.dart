// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keeper_inventory_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KeeperInventorySummaryModel _$KeeperInventorySummaryModelFromJson(
  Map<String, dynamic> json,
) => _KeeperInventorySummaryModel(
  totalUnits: (json['totalUnits'] as num?)?.toInt() ?? 0,
  totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
  totalModels: (json['totalModels'] as num?)?.toInt() ?? 0,
  returnedUnits: (json['returnedUnits'] as num?)?.toInt() ?? 0,
  totalCartons: (json['totalCartons'] as num?)?.toInt() ?? 0,
  shippedUnits: (json['shippedUnits'] as num?)?.toInt() ?? 0,
  products:
      (json['products'] as List<dynamic>?)
          ?.map(
            (e) =>
                KeeperInventoryProductModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <KeeperInventoryProductModel>[],
);

Map<String, dynamic> _$KeeperInventorySummaryModelToJson(
  _KeeperInventorySummaryModel instance,
) => <String, dynamic>{
  'totalUnits': instance.totalUnits,
  'totalProducts': instance.totalProducts,
  'totalModels': instance.totalModels,
  'returnedUnits': instance.returnedUnits,
  'totalCartons': instance.totalCartons,
  'shippedUnits': instance.shippedUnits,
  'products': instance.products,
};

_KeeperInventoryProductModel _$KeeperInventoryProductModelFromJson(
  Map<String, dynamic> json,
) => _KeeperInventoryProductModel(
  name: json['name'] as String? ?? '',
  unit: json['unit'] as String?,
  totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
  cartonCount: (json['cartonCount'] as num?)?.toInt() ?? 0,
  individualCount: (json['individualCount'] as num?)?.toInt() ?? 0,
  models:
      (json['models'] as List<dynamic>?)
          ?.map(
            (e) => KeeperInventoryModelRow.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <KeeperInventoryModelRow>[],
);

Map<String, dynamic> _$KeeperInventoryProductModelToJson(
  _KeeperInventoryProductModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'unit': instance.unit,
  'totalCount': instance.totalCount,
  'cartonCount': instance.cartonCount,
  'individualCount': instance.individualCount,
  'models': instance.models,
};

_KeeperInventoryModelRow _$KeeperInventoryModelRowFromJson(
  Map<String, dynamic> json,
) => _KeeperInventoryModelRow(
  name: json['name'] as String? ?? '',
  totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
  unit: json['unit'] as String?,
  cartonCount: (json['cartonCount'] as num?)?.toInt() ?? 0,
  individualCount: (json['individualCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$KeeperInventoryModelRowToJson(
  _KeeperInventoryModelRow instance,
) => <String, dynamic>{
  'name': instance.name,
  'totalCount': instance.totalCount,
  'unit': instance.unit,
  'cartonCount': instance.cartonCount,
  'individualCount': instance.individualCount,
};
