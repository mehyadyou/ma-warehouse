import 'package:freezed_annotation/freezed_annotation.dart';

part 'loading_plan_item_model.freezed.dart';
part 'loading_plan_item_model.g.dart';

@freezed
abstract class LoadingPlanItemModel with _$LoadingPlanItemModel {
  const factory LoadingPlanItemModel({
    @Default(0) int sequence,
    @Default('') String productName,
    @Default('') String modelName,
    bool? isIndividualUnit,
    int? capacityPerBox,
    String? unit,
  }) = _LoadingPlanItemModel;

  factory LoadingPlanItemModel.fromJson(Map<String, dynamic> json) =>
      _$LoadingPlanItemModelFromJson(json);
}
