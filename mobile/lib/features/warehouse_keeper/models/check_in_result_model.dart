import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_in_result_model.freezed.dart';
part 'check_in_result_model.g.dart';

@freezed
abstract class CheckInResultModel with _$CheckInResultModel {
  const factory CheckInResultModel({
    @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> cartons,
  }) = _CheckInResultModel;

  factory CheckInResultModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInResultModelFromJson(json);
}
