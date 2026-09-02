import 'package:freezed_annotation/freezed_annotation.dart';

part 'keeper_driver_model.freezed.dart';
part 'keeper_driver_model.g.dart';

@freezed
abstract class KeeperDriverModel with _$KeeperDriverModel {
  const factory KeeperDriverModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String phone,
    String? avatarUrl,
    /// انباری که راننده به آن متصل است (خالی = آزاد)
    String? warehouseId,
    String? warehouseName,
    /// تیک سبز — راننده به انبارِ خودِ انباردار متصل است
    @Default(false) bool assignedToMe,
    /// کمرنگ/قفل — راننده به انبارِ دیگری متصل است
    @Default(false) bool assignedToOther,
    DateTime? createdAt,
  }) = _KeeperDriverModel;

  factory KeeperDriverModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperDriverModelFromJson(json);
}