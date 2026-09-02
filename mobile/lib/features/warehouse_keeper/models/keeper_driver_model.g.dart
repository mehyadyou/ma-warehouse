// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keeper_driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KeeperDriverModel _$KeeperDriverModelFromJson(Map<String, dynamic> json) =>
    _KeeperDriverModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      warehouseId: json['warehouseId'] as String?,
      warehouseName: json['warehouseName'] as String?,
      assignedToMe: json['assignedToMe'] as bool? ?? false,
      assignedToOther: json['assignedToOther'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$KeeperDriverModelToJson(_KeeperDriverModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'warehouseId': instance.warehouseId,
      'warehouseName': instance.warehouseName,
      'assignedToMe': instance.assignedToMe,
      'assignedToOther': instance.assignedToOther,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
