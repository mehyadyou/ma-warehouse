import 'package:freezed_annotation/freezed_annotation.dart';

part 'warehouse_inventory_row_model.freezed.dart';
part 'warehouse_inventory_row_model.g.dart';

@freezed
abstract class WarehouseInventoryRowModel with _$WarehouseInventoryRowModel {
  const factory WarehouseInventoryRowModel({
    String? warehouseName,
    String? productName,
    @Default(0) num count,
  }) = _WarehouseInventoryRowModel;

  factory WarehouseInventoryRowModel.fromJson(Map<String, dynamic> json) =>
      _$WarehouseInventoryRowModelFromJson(json);
}
