import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_out_result_model.freezed.dart';
part 'scan_out_result_model.g.dart';

@freezed
abstract class ScanOutResultModel with _$ScanOutResultModel {
  const factory ScanOutResultModel({
    @Default(false) bool valid,
    @Default('') String error,
    ScanOutCartonModel? carton,
  }) = _ScanOutResultModel;

  factory ScanOutResultModel.fromJson(Map<String, dynamic> json) =>
      _$ScanOutResultModelFromJson(json);
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
  }) = _ScanOutCartonModel;

  factory ScanOutCartonModel.fromJson(Map<String, dynamic> json) =>
      _$ScanOutCartonModelFromJson(json);
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
