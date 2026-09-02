// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keeper_carrier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KeeperCarrierModel _$KeeperCarrierModelFromJson(Map<String, dynamic> json) =>
    _KeeperCarrierModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$KeeperCarrierModelToJson(_KeeperCarrierModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'priority': instance.priority,
      'phone': instance.phone,
      'address': instance.address,
    };
