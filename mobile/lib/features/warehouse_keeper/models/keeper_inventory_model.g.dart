// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keeper_inventory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KeeperInventoryListModel _$KeeperInventoryListModelFromJson(
  Map<String, dynamic> json,
) => _KeeperInventoryListModel(
  products:
      (json['products'] as List<dynamic>?)
          ?.map(
            (e) => KeeperProductRowModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <KeeperProductRowModel>[],
  warehouses:
      (json['warehouses'] as List<dynamic>?)
          ?.map(
            (e) => KeeperWarehouseStockRowModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const <KeeperWarehouseStockRowModel>[],
);

Map<String, dynamic> _$KeeperInventoryListModelToJson(
  _KeeperInventoryListModel instance,
) => <String, dynamic>{
  'products': instance.products,
  'warehouses': instance.warehouses,
};

_KeeperProductRowModel _$KeeperProductRowModelFromJson(
  Map<String, dynamic> json,
) => _KeeperProductRowModel(
  productId: json['productId'] as String?,
  name: json['name'] as String?,
  unit: json['unit'] as String?,
  totalCount: json['totalCount'] as num? ?? 0,
);

Map<String, dynamic> _$KeeperProductRowModelToJson(
  _KeeperProductRowModel instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'name': instance.name,
  'unit': instance.unit,
  'totalCount': instance.totalCount,
};

_KeeperWarehouseStockRowModel _$KeeperWarehouseStockRowModelFromJson(
  Map<String, dynamic> json,
) => _KeeperWarehouseStockRowModel(
  warehouseId: json['warehouseId'] as String?,
  warehouseName: json['warehouseName'] as String?,
  totalCount: json['totalCount'] as num? ?? 0,
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) => KeeperStockItemRowModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <KeeperStockItemRowModel>[],
);

Map<String, dynamic> _$KeeperWarehouseStockRowModelToJson(
  _KeeperWarehouseStockRowModel instance,
) => <String, dynamic>{
  'warehouseId': instance.warehouseId,
  'warehouseName': instance.warehouseName,
  'totalCount': instance.totalCount,
  'items': instance.items,
};

_KeeperStockItemRowModel _$KeeperStockItemRowModelFromJson(
  Map<String, dynamic> json,
) => _KeeperStockItemRowModel(
  productId: json['productId'] as String?,
  name: json['name'] as String?,
  unit: json['unit'] as String?,
  count: json['count'] as num? ?? 0,
);

Map<String, dynamic> _$KeeperStockItemRowModelToJson(
  _KeeperStockItemRowModel instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'name': instance.name,
  'unit': instance.unit,
  'count': instance.count,
};

_KeeperProductModelsData _$KeeperProductModelsDataFromJson(
  Map<String, dynamic> json,
) => _KeeperProductModelsData(
  product: json['product'] == null
      ? null
      : KeeperProductInfoModel.fromJson(
          json['product'] as Map<String, dynamic>,
        ),
  models:
      (json['models'] as List<dynamic>?)
          ?.map(
            (e) => KeeperProductModelStockModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const <KeeperProductModelStockModel>[],
);

Map<String, dynamic> _$KeeperProductModelsDataToJson(
  _KeeperProductModelsData instance,
) => <String, dynamic>{'product': instance.product, 'models': instance.models};

_KeeperProductInfoModel _$KeeperProductInfoModelFromJson(
  Map<String, dynamic> json,
) => _KeeperProductInfoModel(
  id: json['id'] as String?,
  name: json['name'] as String?,
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$KeeperProductInfoModelToJson(
  _KeeperProductInfoModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'unit': instance.unit,
};

_KeeperProductModelStockModel _$KeeperProductModelStockModelFromJson(
  Map<String, dynamic> json,
) => _KeeperProductModelStockModel(
  modelId: json['modelId'] as String?,
  name: json['name'] as String?,
  packageType: json['packageType'] as String?,
  unitsPerBox: json['unitsPerBox'] as num?,
  count: json['count'] as num? ?? 0,
  warehouses:
      (json['warehouses'] as List<dynamic>?)
          ?.map(
            (e) => KeeperModelWarehouseRowModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const <KeeperModelWarehouseRowModel>[],
);

Map<String, dynamic> _$KeeperProductModelStockModelToJson(
  _KeeperProductModelStockModel instance,
) => <String, dynamic>{
  'modelId': instance.modelId,
  'name': instance.name,
  'packageType': instance.packageType,
  'unitsPerBox': instance.unitsPerBox,
  'count': instance.count,
  'warehouses': instance.warehouses,
};

_KeeperModelWarehouseRowModel _$KeeperModelWarehouseRowModelFromJson(
  Map<String, dynamic> json,
) => _KeeperModelWarehouseRowModel(
  warehouseId: json['warehouseId'] as String?,
  warehouseName: json['warehouseName'] as String?,
  count: json['count'] as num? ?? 0,
);

Map<String, dynamic> _$KeeperModelWarehouseRowModelToJson(
  _KeeperModelWarehouseRowModel instance,
) => <String, dynamic>{
  'warehouseId': instance.warehouseId,
  'warehouseName': instance.warehouseName,
  'count': instance.count,
};
