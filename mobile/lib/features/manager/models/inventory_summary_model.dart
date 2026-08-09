import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_summary_model.freezed.dart';
part 'inventory_summary_model.g.dart';

@freezed
abstract class InventorySummaryModel with _$InventorySummaryModel {
  const factory InventorySummaryModel({
    @Default(<InventoryRowModel>[]) List<InventoryRowModel> inventory,
    @Default(0) num totalRegisteredProducts,
    @Default(0) num totalInventoryUnits,
    @Default(0) num returnedUnits,
  }) = _InventorySummaryModel;

  factory InventorySummaryModel.fromJson(Map<String, dynamic> json) =>
      _$InventorySummaryModelFromJson(json);
}

@freezed
abstract class InventoryRowModel with _$InventoryRowModel {
  const factory InventoryRowModel({
    String? name,
    @Default(0) num totalCount,
    String? unit,
  }) = _InventoryRowModel;

  factory InventoryRowModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryRowModelFromJson(json);
}
