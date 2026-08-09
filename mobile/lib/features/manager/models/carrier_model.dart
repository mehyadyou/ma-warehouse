import 'package:freezed_annotation/freezed_annotation.dart';

part 'carrier_model.freezed.dart';
part 'carrier_model.g.dart';

@freezed
abstract class CarrierModel with _$CarrierModel {
  const factory CarrierModel({
    String? id,
    String? name,
  }) = _CarrierModel;

  factory CarrierModel.fromJson(Map<String, dynamic> json) =>
      _$CarrierModelFromJson(json);
}
