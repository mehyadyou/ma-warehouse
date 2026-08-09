import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_models_model.freezed.dart';
part 'product_models_model.g.dart';

@freezed
abstract class ProductModelsData with _$ProductModelsData {
  const factory ProductModelsData({
    ProductModelInfo? product,
    @Default(<ProductModelStockModel>[]) List<ProductModelStockModel> models,
  }) = _ProductModelsData;

  factory ProductModelsData.fromJson(Map<String, dynamic> json) =>
      _$ProductModelsDataFromJson(json);
}

@freezed
abstract class ProductModelInfo with _$ProductModelInfo {
  const factory ProductModelInfo({
    String? id,
    String? name,
    String? unit,
  }) = _ProductModelInfo;

  factory ProductModelInfo.fromJson(Map<String, dynamic> json) =>
      _$ProductModelInfoFromJson(json);
}

@freezed
abstract class ProductModelStockModel with _$ProductModelStockModel {
  const factory ProductModelStockModel({
    String? modelId,
    String? name,
    String? packageType,
    num? unitsPerBox,
    @Default(0) num count,
    @Default(<ModelWarehouseRowModel>[]) List<ModelWarehouseRowModel> warehouses,
  }) = _ProductModelStockModel;

  factory ProductModelStockModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelStockModelFromJson(json);
}

@freezed
abstract class ModelWarehouseRowModel with _$ModelWarehouseRowModel {
  const factory ModelWarehouseRowModel({
    String? warehouseId,
    String? warehouseName,
    @Default(0) num count,
  }) = _ModelWarehouseRowModel;

  factory ModelWarehouseRowModel.fromJson(Map<String, dynamic> json) =>
      _$ModelWarehouseRowModelFromJson(json);
}
