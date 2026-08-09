import 'package:freezed_annotation/freezed_annotation.dart';

part 'archive_models.freezed.dart';
part 'archive_models.g.dart';

@freezed
abstract class ArchivedProductModel with _$ArchivedProductModel {
  const factory ArchivedProductModel({
    required String id,
    String? name,
    String? unit,
    @Default(<ArchivedVariantModel>[]) List<ArchivedVariantModel> models,
    @Default(0) num cartonCount,
  }) = _ArchivedProductModel;

  factory ArchivedProductModel.fromJson(Map<String, dynamic> json) {
    final count = json['_count'];
    return ArchivedProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      unit: json['unit'] as String?,
      models: (json['models'] as List<dynamic>? ?? [])
          .map((e) => ArchivedVariantModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      cartonCount: count is Map ? (count['cartons'] as num? ?? 0) : 0,
    );
  }
}

@freezed
abstract class ArchivedVariantModel with _$ArchivedVariantModel {
  const factory ArchivedVariantModel({
    String? name,
  }) = _ArchivedVariantModel;

  factory ArchivedVariantModel.fromJson(Map<String, dynamic> json) =>
      _$ArchivedVariantModelFromJson(json);
}

@freezed
abstract class ArchivedWarehouseModel with _$ArchivedWarehouseModel {
  const factory ArchivedWarehouseModel({
    required String id,
    String? name,
    @Default(0) num cartonCount,
    @Default(0) num orderCount,
  }) = _ArchivedWarehouseModel;

  factory ArchivedWarehouseModel.fromJson(Map<String, dynamic> json) {
    final count = json['_count'];
    return ArchivedWarehouseModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      cartonCount: count is Map ? (count['cartons'] as num? ?? 0) : 0,
      orderCount: count is Map ? (count['orders'] as num? ?? 0) : 0,
    );
  }
}
