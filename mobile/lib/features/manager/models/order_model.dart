import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    @Default(0) int orderNumber,
    @Default(0) int version,
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

@freezed
abstract class OrderCountsModel with _$OrderCountsModel {
  const factory OrderCountsModel({
    @Default(0) int total,
    @Default(0) int pending,
    @Default(0) int inTransit,
    @Default(0) int delivered,
  }) = _OrderCountsModel;

  factory OrderCountsModel.fromJson(Map<String, dynamic> json) =>
      _$OrderCountsModelFromJson(json);
}

@freezed
abstract class OrdersPageModel with _$OrdersPageModel {
  const factory OrdersPageModel({
    @Default(<OrderModel>[]) List<OrderModel> orders,
    @Default(0) int page,
    @Default(0) int pageSize,
    @Default(0) int total,
    @Default(false) bool hasMore,
    @Default(OrderCountsModel()) OrderCountsModel counts,
  }) = _OrdersPageModel;

  factory OrdersPageModel.fromJson(Map<String, dynamic> json) {
    final pagination = (json['pagination'] as Map?) ?? const {};
    return OrdersPageModel(
      orders: ((json['orders'] as List?) ?? [])
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: ((pagination['page'] as num?) ?? 0).toInt(),
      pageSize: ((pagination['pageSize'] as num?) ?? 0).toInt(),
      total: ((pagination['total'] as num?) ?? 0).toInt(),
      hasMore: (pagination['hasMore'] as bool?) ?? false,
      counts: OrderCountsModel.fromJson(
        ((json['counts'] as Map?) ?? const {}).cast<String, dynamic>(),
      ),
    );
  }
}

num _toNum(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value;
  return num.tryParse(value.toString()) ?? 0;
}
