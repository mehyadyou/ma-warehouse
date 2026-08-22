import 'package:freezed_annotation/freezed_annotation.dart';

part 'shipment_report_model.freezed.dart';
part 'shipment_report_model.g.dart';

@freezed
abstract class ShipmentReportModel with _$ShipmentReportModel {
  const factory ShipmentReportModel({
    @Default(0) num totalShipments,
    @Default(0) num totalUnits,
    @Default(0) num totalWarehouses,
    ShipmentOrderModel? lastShipment,
    @Default([]) List<ShipmentWarehouseModel> warehouses,
  }) = _ShipmentReportModel;

  factory ShipmentReportModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentReportModelFromJson(json);
}

@freezed
abstract class ShipmentWarehouseModel with _$ShipmentWarehouseModel {
  const factory ShipmentWarehouseModel({
    String? warehouseId,
    String? warehouseName,
    @Default(0) num totalCount,
    String? lastShipmentAt,
    @Default([]) List<ShipmentDayModel> daily,
  }) = _ShipmentWarehouseModel;

  factory ShipmentWarehouseModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentWarehouseModelFromJson(json);
}

@freezed
abstract class ShipmentDayModel with _$ShipmentDayModel {
  const factory ShipmentDayModel({
    String? date,
    @Default(0) num count,
    @Default([]) List<ShipmentOrderModel> items,
  }) = _ShipmentDayModel;

  factory ShipmentDayModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentDayModelFromJson(json);
}

@freezed
abstract class ShipmentOrderModel with _$ShipmentOrderModel {
  const factory ShipmentOrderModel({
    String? orderId,
    String? warehouseId,
    String? warehouseName,
    String? status,
    String? city,
    String? receiverName,
    String? senderName,
    String? carrier,
    String? createdByName,
    String? createdAt,
    @Default(0) num totalUnits,
    @Default([]) List<ShipmentItemModel> items,
  }) = _ShipmentOrderModel;

  factory ShipmentOrderModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentOrderModelFromJson(json);
}

@freezed
abstract class ShipmentItemModel with _$ShipmentItemModel {
  const factory ShipmentItemModel({
    String? productName,
    @Default(0) num quantity,
    String? unit,
  }) = _ShipmentItemModel;

  factory ShipmentItemModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentItemModelFromJson(json);
}