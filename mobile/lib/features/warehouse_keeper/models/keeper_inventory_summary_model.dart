import 'package:freezed_annotation/freezed_annotation.dart';

part 'keeper_inventory_summary_model.freezed.dart';
part 'keeper_inventory_summary_model.g.dart';

@freezed
abstract class KeeperInventorySummaryModel with _$KeeperInventorySummaryModel {
  const factory KeeperInventorySummaryModel({
    @Default(0) int totalUnits,
    @Default(0) int totalProducts,
    @Default(0) int totalModels,
    @Default(0) int returnedUnits,
    @Default(0) int totalCartons,
    @Default(0) int shippedUnits,
    @Default(<KeeperInventoryProductModel>[]) List<KeeperInventoryProductModel> products,
  }) = _KeeperInventorySummaryModel;

  factory KeeperInventorySummaryModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperInventorySummaryModelFromJson(json);
}

@freezed
abstract class KeeperInventoryProductModel with _$KeeperInventoryProductModel {
  const factory KeeperInventoryProductModel({
    @Default('') String name,
    String? unit,
    @Default(0) int totalCount,
    @Default(0) int cartonCount,
    @Default(0) int individualCount,
    @Default(<KeeperInventoryModelRow>[]) List<KeeperInventoryModelRow> models,
  }) = _KeeperInventoryProductModel;

  factory KeeperInventoryProductModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperInventoryProductModelFromJson(json);
}

@freezed
abstract class KeeperInventoryModelRow with _$KeeperInventoryModelRow {
  const factory KeeperInventoryModelRow({
    @Default('') String name,
    @Default(0) int totalCount,
    String? unit,
    @Default(0) int cartonCount,
    @Default(0) int individualCount,
  }) = _KeeperInventoryModelRow;

  factory KeeperInventoryModelRow.fromJson(Map<String, dynamic> json) =>
      _$KeeperInventoryModelRowFromJson(json);
}
