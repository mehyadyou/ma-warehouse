import 'package:freezed_annotation/freezed_annotation.dart';

part 'warehouse_model.freezed.dart';

@freezed
abstract class WarehouseModel with _$WarehouseModel {
  const factory WarehouseModel({
    required String id,
    required String name,
    String? address,
    String? keeperId,
    String? keeperName,
    @Default(0) int productCount,
    DateTime? createdAt,
  }) = _WarehouseModel;

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      keeperId: json['keeperId'] as String?,
      keeperName: json['keeperName'] as String?,
      productCount: json['productCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
