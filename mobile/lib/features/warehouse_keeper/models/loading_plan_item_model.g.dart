// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loading_plan_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoadingPlanItemModel _$LoadingPlanItemModelFromJson(
  Map<String, dynamic> json,
) => _LoadingPlanItemModel(
  sequence: (json['sequence'] as num?)?.toInt() ?? 0,
  productName: json['productName'] as String? ?? '',
  modelName: json['modelName'] as String? ?? '',
  isIndividualUnit: json['isIndividualUnit'] as bool?,
  capacityPerBox: (json['capacityPerBox'] as num?)?.toInt(),
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$LoadingPlanItemModelToJson(
  _LoadingPlanItemModel instance,
) => <String, dynamic>{
  'sequence': instance.sequence,
  'productName': instance.productName,
  'modelName': instance.modelName,
  'isIndividualUnit': instance.isIndividualUnit,
  'capacityPerBox': instance.capacityPerBox,
  'unit': instance.unit,
};
