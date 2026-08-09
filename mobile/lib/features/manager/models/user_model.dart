import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    String? name,
    String? role,
    String? phone,
    String? warehouseId,
    String? warehouseName,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final warehouse = json['warehouse'];
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      role: json['role'] as String?,
      phone: json['phone'] as String?,
      warehouseId: json['warehouseId'] as String?,
      warehouseName: warehouse is Map ? warehouse['name'] as String? : null,
    );
  }
}
