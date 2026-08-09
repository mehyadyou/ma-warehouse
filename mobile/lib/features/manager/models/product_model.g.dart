// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductModel _$ProductModelFromJson(Map<String, dynamic> json) =>
    _ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String?,
      models:
          (json['models'] as List<dynamic>?)
              ?.map(
                (e) => ProductVariantModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProductModelToJson(_ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
      'models': instance.models,
    };

_ProductVariantModel _$ProductVariantModelFromJson(Map<String, dynamic> json) =>
    _ProductVariantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: _toDouble(json['price']),
      unitsPerBox: _toNum(json['unitsPerBox']),
      packageType: json['packageType'] as String?,
    );

Map<String, dynamic> _$ProductVariantModelToJson(
  _ProductVariantModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'unitsPerBox': instance.unitsPerBox,
  'packageType': instance.packageType,
};
