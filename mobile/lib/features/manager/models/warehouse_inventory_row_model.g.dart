// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_inventory_row_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WarehouseInventoryRowModel _$WarehouseInventoryRowModelFromJson(
  Map<String, dynamic> json,
) => _WarehouseInventoryRowModel(
  warehouseName: json['warehouseName'] as String?,
  productName: json['productName'] as String?,
  count: json['count'] as num? ?? 0,
);

Map<String, dynamic> _$WarehouseInventoryRowModelToJson(
  _WarehouseInventoryRowModel instance,
) => <String, dynamic>{
  'warehouseName': instance.warehouseName,
  'productName': instance.productName,
  'count': instance.count,
};
