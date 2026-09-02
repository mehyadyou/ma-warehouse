import 'package:freezed_annotation/freezed_annotation.dart';

part 'keeper_carrier_model.freezed.dart';
part 'keeper_carrier_model.g.dart';

@freezed
abstract class KeeperCarrierModel with _$KeeperCarrierModel {
  const factory KeeperCarrierModel({
    @Default('') String id,
    @Default('') String name,
    /// اولویت باربری — مرتب‌سازی برنامهٔ بارگیری راننده بر اساس آن انجام می‌شود
    @Default(0) int priority,
    String? phone,
    String? address,
  }) = _KeeperCarrierModel;

  factory KeeperCarrierModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperCarrierModelFromJson(json);
}