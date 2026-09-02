import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_out_result_model.freezed.dart';
part 'scan_out_result_model.g.dart';

@freezed
abstract class ScanOutResultModel with _$ScanOutResultModel {
  const factory ScanOutResultModel({
    @Default(false) bool valid,
    @Default('') String error,
    ScanOutCartonModel? carton,
    /// وقتی چند سفارش/دستور فعال برای همین کالا/مدل وجود دارد — لیست هدف‌های ممکن
    /// برای انتخاب صریح انباردار (خطای ۴۰۰ با همین لیست)
    List<ScanOutTargetModel>? candidates,
  }) = _ScanOutResultModel;

  factory ScanOutResultModel.fromJson(Map<String, dynamic> json) =>
      _$ScanOutResultModelFromJson(json);
}

@freezed
abstract class ScanOutTargetModel with _$ScanOutTargetModel {
  const factory ScanOutTargetModel({
    /// 'order' یا 'transfer'
    @Default('') String kind,
    @Default('') String id,
    /// مخصوص سفارش
    int? orderNumber,
    String? city,
    String? receiverName,
    String? carrier,
    String? customerPhone,
    /// مخصوص دستور خروج/جابه‌جایی
    @Default('') String productName,
    String? modelName,
    int? quantity,
    String? toWarehouseName,
  }) = _ScanOutTargetModel;

  factory ScanOutTargetModel.fromJson(Map<String, dynamic> json) =>
      _$ScanOutTargetModelFromJson(json);
}

@freezed
abstract class ScanOutCartonModel with _$ScanOutCartonModel {
  const factory ScanOutCartonModel({
    @Default('') String productName,
    @Default('') String modelName,
    String? serialNumber,
    bool? isIndividualUnit,
    int? capacityPerBox,
    String? unit,
    String? packageType,
    ScanOutTransferModel? transfer,
    /// سفارشی که این بار برای آن خروج خورده — مبنای انتخاب راننده
    ScanOutOrderModel? order,
    /// راننده‌ای که بار برایش تعریف شد (خروج دستی با انتخاب راننده)
    ScanOutDriverModel? driver,
  }) = _ScanOutCartonModel;

  factory ScanOutCartonModel.fromJson(Map<String, dynamic> json) =>
      _$ScanOutCartonModelFromJson(json);
}

@freezed
abstract class ScanOutOrderModel with _$ScanOutOrderModel {
  const factory ScanOutOrderModel({
    @Default('') String id,
    int? orderNumber,
    String? customerPhone,
    String? city,
    String? address,
  }) = _ScanOutOrderModel;

  factory ScanOutOrderModel.fromJson(Map<String, dynamic> json) =>
      _$ScanOutOrderModelFromJson(json);
}

@freezed
abstract class ScanOutDriverModel with _$ScanOutDriverModel {
  const factory ScanOutDriverModel({
    @Default('') String id,
    @Default('') String name,
  }) = _ScanOutDriverModel;

  factory ScanOutDriverModel.fromJson(Map<String, dynamic> json) =>
      _$ScanOutDriverModelFromJson(json);
}

@freezed
abstract class ScanOutTransferModel with _$ScanOutTransferModel {
  const factory ScanOutTransferModel({
    required String id,
    String? toWarehouseId,
    String? toWarehouseName,
  }) = _ScanOutTransferModel;

  factory ScanOutTransferModel.fromJson(Map<String, dynamic> json) =>
      _$ScanOutTransferModelFromJson(json);
}
