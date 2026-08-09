import 'package:freezed_annotation/freezed_annotation.dart';

part 'keeper_inventory_model.freezed.dart';
part 'keeper_inventory_model.g.dart';

@freezed
abstract class KeeperInventoryListModel with _$KeeperInventoryListModel {
  const factory KeeperInventoryListModel({
    @Default(<KeeperProductRowModel>[]) List<KeeperProductRowModel> products,
    @Default(<KeeperWarehouseStockRowModel>[]) List<KeeperWarehouseStockRowModel> warehouses,
  }) = _KeeperInventoryListModel;

  factory KeeperInventoryListModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperInventoryListModelFromJson(json);
}

@freezed
abstract class KeeperProductRowModel with _$KeeperProductRowModel {
  const factory KeeperProductRowModel({
    String? productId,
    String? name,
    String? unit,
    @Default(0) num totalCount,
  }) = _KeeperProductRowModel;

  factory KeeperProductRowModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperProductRowModelFromJson(json);
}

@freezed
abstract class KeeperWarehouseStockRowModel with _$KeeperWarehouseStockRowModel {
  const factory KeeperWarehouseStockRowModel({
    String? warehouseId,
    String? warehouseName,
    @Default(0) num totalCount,
    @Default(<KeeperStockItemRowModel>[]) List<KeeperStockItemRowModel> items,
  }) = _KeeperWarehouseStockRowModel;

  factory KeeperWarehouseStockRowModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperWarehouseStockRowModelFromJson(json);
}

@freezed
abstract class KeeperStockItemRowModel with _$KeeperStockItemRowModel {
  const factory KeeperStockItemRowModel({
    String? productId,
    String? name,
    String? unit,
    @Default(0) num count,
  }) = _KeeperStockItemRowModel;

  factory KeeperStockItemRowModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperStockItemRowModelFromJson(json);
}

@freezed
abstract class KeeperProductModelsData with _$KeeperProductModelsData {
  const factory KeeperProductModelsData({
    KeeperProductInfoModel? product,
    @Default(<KeeperProductModelStockModel>[]) List<KeeperProductModelStockModel> models,
  }) = _KeeperProductModelsData;

  factory KeeperProductModelsData.fromJson(Map<String, dynamic> json) =>
      _$KeeperProductModelsDataFromJson(json);
}

@freezed
abstract class KeeperProductInfoModel with _$KeeperProductInfoModel {
  const factory KeeperProductInfoModel({
    String? id,
    String? name,
    String? unit,
  }) = _KeeperProductInfoModel;

  factory KeeperProductInfoModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperProductInfoModelFromJson(json);
}

@freezed
abstract class KeeperProductModelStockModel with _$KeeperProductModelStockModel {
  const factory KeeperProductModelStockModel({
    String? modelId,
    String? name,
    String? packageType,
    num? unitsPerBox,
    @Default(0) num count,
    @Default(<KeeperModelWarehouseRowModel>[]) List<KeeperModelWarehouseRowModel> warehouses,
  }) = _KeeperProductModelStockModel;

  factory KeeperProductModelStockModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperProductModelStockModelFromJson(json);
}

@freezed
abstract class KeeperModelWarehouseRowModel with _$KeeperModelWarehouseRowModel {
  const factory KeeperModelWarehouseRowModel({
    String? warehouseId,
    String? warehouseName,
    @Default(0) num count,
  }) = _KeeperModelWarehouseRowModel;

  factory KeeperModelWarehouseRowModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperModelWarehouseRowModelFromJson(json);
}
