// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manager_inventory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ManagerInventoryModel _$ManagerInventoryModelFromJson(
  Map<String, dynamic> json,
) => _ManagerInventoryModel(
  products:
      (json['products'] as List<dynamic>?)
          ?.map(
            (e) => ManagerProductRowModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ManagerProductRowModel>[],
  warehouses:
      (json['warehouses'] as List<dynamic>?)
          ?.map(
            (e) => WarehouseStockRowModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <WarehouseStockRowModel>[],
);

Map<String, dynamic> _$ManagerInventoryModelToJson(
  _ManagerInventoryModel instance,
) => <String, dynamic>{
  'products': instance.products,
  'warehouses': instance.warehouses,
};

_ManagerProductRowModel _$ManagerProductRowModelFromJson(
  Map<String, dynamic> json,
) => _ManagerProductRowModel(
  productId: json['productId'] as String?,
  name: json['name'] as String?,
  unit: json['unit'] as String?,
  totalCount: json['totalCount'] as num? ?? 0,
);

Map<String, dynamic> _$ManagerProductRowModelToJson(
  _ManagerProductRowModel instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'name': instance.name,
  'unit': instance.unit,
  'totalCount': instance.totalCount,
};

_WarehouseStockRowModel _$WarehouseStockRowModelFromJson(
  Map<String, dynamic> json,
) => _WarehouseStockRowModel(
  warehouseName: json['warehouseName'] as String?,
  totalCount: json['totalCount'] as num? ?? 0,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => StockItemRowModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StockItemRowModel>[],
);

Map<String, dynamic> _$WarehouseStockRowModelToJson(
  _WarehouseStockRowModel instance,
) => <String, dynamic>{
  'warehouseName': instance.warehouseName,
  'totalCount': instance.totalCount,
  'items': instance.items,
};

_StockItemRowModel _$StockItemRowModelFromJson(Map<String, dynamic> json) =>
    _StockItemRowModel(
      productId: json['productId'] as String?,
      name: json['name'] as String?,
      unit: json['unit'] as String?,
      count: json['count'] as num? ?? 0,
    );

Map<String, dynamic> _$StockItemRowModelToJson(_StockItemRowModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'unit': instance.unit,
      'count': instance.count,
    };
