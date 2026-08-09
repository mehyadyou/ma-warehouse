// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventorySummaryModel _$InventorySummaryModelFromJson(
  Map<String, dynamic> json,
) => _InventorySummaryModel(
  inventory:
      (json['inventory'] as List<dynamic>?)
          ?.map((e) => InventoryRowModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <InventoryRowModel>[],
  totalRegisteredProducts: json['totalRegisteredProducts'] as num? ?? 0,
  totalInventoryUnits: json['totalInventoryUnits'] as num? ?? 0,
  returnedUnits: json['returnedUnits'] as num? ?? 0,
);

Map<String, dynamic> _$InventorySummaryModelToJson(
  _InventorySummaryModel instance,
) => <String, dynamic>{
  'inventory': instance.inventory,
  'totalRegisteredProducts': instance.totalRegisteredProducts,
  'totalInventoryUnits': instance.totalInventoryUnits,
  'returnedUnits': instance.returnedUnits,
};

_InventoryRowModel _$InventoryRowModelFromJson(Map<String, dynamic> json) =>
    _InventoryRowModel(
      name: json['name'] as String?,
      totalCount: json['totalCount'] as num? ?? 0,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$InventoryRowModelToJson(_InventoryRowModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'totalCount': instance.totalCount,
      'unit': instance.unit,
    };
