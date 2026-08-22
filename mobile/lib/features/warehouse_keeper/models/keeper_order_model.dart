import 'package:freezed_annotation/freezed_annotation.dart';

part 'keeper_order_model.freezed.dart';

@freezed
abstract class KeeperOrderModel with _$KeeperOrderModel {
  const factory KeeperOrderModel({
    @Default('') String id,
    @Default(0) int orderNumber,
    @Default('') String status,
    @Default('') String createdByName,
    @Default('') String createdAt,
    @Default('') String warehouseName,
    @Default('') String shippingMethod,
    @Default('') String senderName,
    @Default('') String receiverName,
    @Default('') String carrier,
    @Default('') String city,
    @Default('') String postalCode,
    @Default('') String address,
    @Default('') String customerPhone,
    @Default(<KeeperOrderItemModel>[]) List<KeeperOrderItemModel> items,
  }) = _KeeperOrderModel;

  factory KeeperOrderModel.fromJson(Map<String, dynamic> json) {
    return KeeperOrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      createdByName: json['createdByName']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      warehouseName: json['warehouseName']?.toString() ?? '',
      shippingMethod: json['shippingMethod']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      receiverName: json['receiverName']?.toString() ?? '',
      carrier: json['carrier']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) =>
              KeeperOrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

@freezed
abstract class KeeperOrderItemModel with _$KeeperOrderItemModel {
  const factory KeeperOrderItemModel({
    @Default('') String productName,
    @Default('') String model,
    @Default(0) int quantity,
    double? price,
    double? exchangeRate,
  }) = _KeeperOrderItemModel;

  factory KeeperOrderItemModel.fromJson(Map<String, dynamic> json) {
    return KeeperOrderItemModel(
      productName: json['productName']?.toString() ??
          json['product']?['name']?.toString() ??
          '',
      model: json['model']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: _toDouble(json['price']),
      exchangeRate: _toDouble(json['exchangeRate']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
