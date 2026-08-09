// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keeper_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KeeperProductModel _$KeeperProductModelFromJson(Map<String, dynamic> json) =>
    _KeeperProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String?,
      models:
          (json['models'] as List<dynamic>?)
              ?.map(
                (e) => KeeperProductVariantModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <KeeperProductVariantModel>[],
    );

Map<String, dynamic> _$KeeperProductModelToJson(_KeeperProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
      'models': instance.models,
    };

_KeeperProductVariantModel _$KeeperProductVariantModelFromJson(
  Map<String, dynamic> json,
) => _KeeperProductVariantModel(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  unitsPerBox: json['unitsPerBox'] as num?,
  packageType: json['packageType'] as String?,
);

Map<String, dynamic> _$KeeperProductVariantModelToJson(
  _KeeperProductVariantModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'unitsPerBox': instance.unitsPerBox,
  'packageType': instance.packageType,
};
