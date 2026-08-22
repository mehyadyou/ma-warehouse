import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_model.freezed.dart';

/// ثبت جابه‌جایی/خروج محصول توسط مدیر — دستور دوفازی:
/// PENDING (در انتظار اجرا توسط انباردار)، DONE (تکمیل‌شده)، CANCELED (لغوشده)
@freezed
abstract class TransferModel with _$TransferModel {
  const factory TransferModel({
    required String id,
    required String fromWarehouseId,
    required String fromWarehouseName,
    String? toWarehouseId,
    String? toWarehouseName,
    required String productId,
    required String productName,
    String? modelId,
    String? modelName,
    required int quantity,
    @Default('') String description,
    @Default('PENDING') String status,
    DateTime? completedAt,
    @Default(0) int executedUnits,
    @Default(0) int remainingUnits,
    required DateTime createdAt,
  }) = _TransferModel;

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'] as String,
      fromWarehouseId: json['fromWarehouseId'] as String,
      fromWarehouseName: json['fromWarehouseName'] as String? ?? '',
      toWarehouseId: json['toWarehouseId'] as String?,
      toWarehouseName: json['toWarehouseName'] as String?,
      productId: json['productId'] as String,
      productName: json['productName'] as String? ?? '',
      modelId: json['modelId'] as String?,
      modelName: json['modelName'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      executedUnits: (json['executedUnits'] as num?)?.toInt() ?? 0,
      remainingUnits: (json['remainingUnits'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}