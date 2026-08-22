import 'package:freezed_annotation/freezed_annotation.dart';

part 'warehouse_detail_model.freezed.dart';
part 'warehouse_detail_model.g.dart';

@freezed
abstract class WarehouseDetailModel with _$WarehouseDetailModel {
  const factory WarehouseDetailModel({
    @Default(WarehouseStatsModel()) WarehouseStatsModel stats,
    String? keeperName,
    @Default(<WarehouseProductStockModel>[]) List<WarehouseProductStockModel> products,
  }) = _WarehouseDetailModel;

  factory WarehouseDetailModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'];
    final warehouse = json['warehouse'];
    final inventory = json['inventory'];
    return WarehouseDetailModel(
      stats: stats is Map
          ? WarehouseStatsModel.fromJson(Map<String, dynamic>.from(stats))
          : const WarehouseStatsModel(),
      keeperName: warehouse is Map ? warehouse['keeperName'] as String? : null,
      products: inventory is Map
          ? (inventory['products'] as List<dynamic>? ?? [])
              .map((e) => WarehouseProductStockModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }
}

@freezed
abstract class WarehouseStatsModel with _$WarehouseStatsModel {
  const factory WarehouseStatsModel({
    @Default(0) num transactionCount,
    @Default(0) num productCount,
    @Default(0) num inCount,
    @Default(0) num outCount,
    @Default(0) num inUnits,
    @Default(0) num outUnits,
    @Default(0) num returnedUnits,
    @Default(0) num totalUnits,
    @Default(0) num totalCartons,
    @Default(0) num orderCount,
    @Default(0) num activeOrderCount,
  }) = _WarehouseStatsModel;

  factory WarehouseStatsModel.fromJson(Map<String, dynamic> json) =>
      _$WarehouseStatsModelFromJson(json);
}

@freezed
abstract class WarehouseProductStockModel with _$WarehouseProductStockModel {
  const factory WarehouseProductStockModel({
    String? name,
    String? unit,
    @Default(0) num totalCount,
    @Default(0) num cartonCount,
    @Default(0) num individualCount,
    @Default(0) num modelCount,
    @Default(<WarehouseModelStockModel>[]) List<WarehouseModelStockModel> models,
  }) = _WarehouseProductStockModel;

  factory WarehouseProductStockModel.fromJson(Map<String, dynamic> json) =>
      _$WarehouseProductStockModelFromJson(json);
}

@freezed
abstract class WarehouseModelStockModel with _$WarehouseModelStockModel {
  const factory WarehouseModelStockModel({
    String? name,
    @Default(0) num totalCount,
    @Default(0) num cartonCount,
    @Default(0) num individualCount,
  }) = _WarehouseModelStockModel;

  factory WarehouseModelStockModel.fromJson(Map<String, dynamic> json) =>
      _$WarehouseModelStockModelFromJson(json);
}
