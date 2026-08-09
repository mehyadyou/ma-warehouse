import 'package:freezed_annotation/freezed_annotation.dart';

part 'keeper_product_model.freezed.dart';
part 'keeper_product_model.g.dart';

@freezed
abstract class KeeperProductModel with _$KeeperProductModel {
  const factory KeeperProductModel({
    @Default('') String id,
    @Default('') String name,
    String? unit,
    @Default(<KeeperProductVariantModel>[]) List<KeeperProductVariantModel> models,
  }) = _KeeperProductModel;

  factory KeeperProductModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperProductModelFromJson(json);
}

@freezed
abstract class KeeperProductVariantModel with _$KeeperProductVariantModel {
  const factory KeeperProductVariantModel({
    @Default('') String id,
    @Default('') String name,
    num? unitsPerBox,
    String? packageType,
  }) = _KeeperProductVariantModel;

  factory KeeperProductVariantModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperProductVariantModelFromJson(json);
}
