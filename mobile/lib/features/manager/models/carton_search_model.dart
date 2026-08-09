import 'package:freezed_annotation/freezed_annotation.dart';

part 'carton_search_model.freezed.dart';
part 'carton_search_model.g.dart';

@freezed
abstract class CartonSearchModel with _$CartonSearchModel {
  const factory CartonSearchModel({
    String? cartonStatus,
    String? orderStatus,
    String? orderId,
    @Default(<RelatedOrderModel>[]) List<RelatedOrderModel> relatedOrders,
    String? productName,
    String? modelName,
    String? warehouseName,
    String? serialNumber,
    String? qrUuid,
    String? createdAt,
    String? scannedOutAt,
    String? senderName,
    String? receiverName,
    String? city,
    String? driverName,
    String? deliveredAt,
  }) = _CartonSearchModel;

  factory CartonSearchModel.fromJson(Map<String, dynamic> json) =>
      _$CartonSearchModelFromJson(json);
}

@freezed
abstract class RelatedOrderModel with _$RelatedOrderModel {
  const factory RelatedOrderModel({
    @Default(CartonOrderRefModel()) CartonOrderRefModel order,
    @Default(0) num quantity,
  }) = _RelatedOrderModel;

  factory RelatedOrderModel.fromJson(Map<String, dynamic> json) =>
      _$RelatedOrderModelFromJson(json);
}

@freezed
abstract class CartonOrderRefModel with _$CartonOrderRefModel {
  const factory CartonOrderRefModel({
    String? status,
    String? senderName,
    String? receiverName,
    String? createdAt,
  }) = _CartonOrderRefModel;

  factory CartonOrderRefModel.fromJson(Map<String, dynamic> json) =>
      _$CartonOrderRefModelFromJson(json);
}
