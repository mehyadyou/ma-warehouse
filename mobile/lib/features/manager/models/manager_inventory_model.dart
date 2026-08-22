import 'package:freezed_annotation/freezed_annotation.dart';

part 'manager_inventory_model.freezed.dart';
part 'manager_inventory_model.g.dart';

@freezed
abstract class ManagerInventoryModel with _$ManagerInventoryModel {
  const factory ManagerInventoryModel({
    @Default(<ManagerProductRowModel>[]) List<ManagerProductRowModel> products,
    @Default(<WarehouseStockRowModel>[])
    List<WarehouseStockRowModel> warehouses,
    @Default(0) int total,
    @Default(0) int page,
    @Default(0) int pageSize,
    @Default(false) bool hasMore,
  }) = _ManagerInventoryModel;

  factory ManagerInventoryModel.fromJson(Map<String, dynamic> json) =>
      _$ManagerInventoryModelFromJson(json);
}

@freezed
abstract class ManagerProductRowModel with _$ManagerProductRowModel {
  const factory ManagerProductRowModel({
    String? productId,
    String? name,
    String? unit,
    @Default(0) num totalCount,
    @Default(0) int modelCount,
    @Default(<String>[]) List<String> modelNames,
  }) = _ManagerProductRowModel;

  factory ManagerProductRowModel.fromJson(Map<String, dynamic> json) =>
      _$ManagerProductRowModelFromJson(json);
}

@freezed
abstract class WarehouseStockRowModel with _$WarehouseStockRowModel {
  const factory WarehouseStockRowModel({
    String? warehouseId,
    String? warehouseName,
    @Default(0) num totalCount,
    @Default(0) int totalItems,
    @Default(<StockItemRowModel>[]) List<StockItemRowModel> items,
  }) = _WarehouseStockRowModel;

  factory WarehouseStockRowModel.fromJson(Map<String, dynamic> json) =>
      _$WarehouseStockRowModelFromJson(json);
}

@freezed
abstract class StockItemRowModel with _$StockItemRowModel {
  const factory StockItemRowModel({
    String? productId,
    String? name,
    String? unit,
    @Default(0) num count,
  }) = _StockItemRowModel;

  factory StockItemRowModel.fromJson(Map<String, dynamic> json) =>
      _$StockItemRowModelFromJson(json);
}
