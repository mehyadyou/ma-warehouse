import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    String? senderName,
    String? receiverName,
    String? customerPhone,
    String? city,
    String? address,
    String? postalCode,
    String? shippingMethod,
    String? carrier,
    String? warehouseName,
    String? driverName,
    String? status,
    String? deliveryStatus,
    int? badgeCount,
    String? createdAt,
    String? deliveredAt,
    @Default(<OrderItemModel>[]) List<OrderItemModel> items,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}

@freezed
abstract class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    String? productId,
    String? productName,
    String? model,
    @Default(0) @JsonKey(fromJson: _toNum) num quantity,
    @JsonKey(fromJson: _toNum) num? price,
    @JsonKey(fromJson: _toNum) num? exchangeRate,
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}

num _toNum(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value;
  return num.tryParse(value.toString()) ?? 0;
}
