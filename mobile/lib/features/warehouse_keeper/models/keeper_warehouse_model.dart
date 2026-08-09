import 'package:freezed_annotation/freezed_annotation.dart';

part 'keeper_warehouse_model.freezed.dart';
part 'keeper_warehouse_model.g.dart';

@freezed
abstract class KeeperWarehouseModel with _$KeeperWarehouseModel {
  const factory KeeperWarehouseModel({
    @Default('') String name,
    @Default('') String keeperName,
  }) = _KeeperWarehouseModel;

  factory KeeperWarehouseModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperWarehouseModelFromJson(json);
}
