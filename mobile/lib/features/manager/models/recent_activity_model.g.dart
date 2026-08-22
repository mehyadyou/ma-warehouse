// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecentActivityData _$RecentActivityDataFromJson(Map<String, dynamic> json) =>
    _RecentActivityData(
      activities:
          (json['activities'] as List<dynamic>?)
              ?.map(
                (e) => ActivityEntryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ActivityEntryModel>[],
    );

Map<String, dynamic> _$RecentActivityDataToJson(_RecentActivityData instance) =>
    <String, dynamic>{'activities': instance.activities};

_ActivityEntryModel _$ActivityEntryModelFromJson(Map<String, dynamic> json) =>
    _ActivityEntryModel(
      id: json['id'] as String?,
      activityType: json['activityType'] as String?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      label: json['label'] as String?,
      unit: json['unit'] as String?,
      quantity: json['quantity'] as num? ?? 0,
      warehouseName: json['warehouseName'] as String?,
      userName: json['userName'] as String?,
      createdAt: json['createdAt'] as String?,
      orderId: json['orderId'] as String?,
    );

Map<String, dynamic> _$ActivityEntryModelToJson(_ActivityEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activityType': instance.activityType,
      'type': instance.type,
      'title': instance.title,
      'label': instance.label,
      'unit': instance.unit,
      'quantity': instance.quantity,
      'warehouseName': instance.warehouseName,
      'userName': instance.userName,
      'createdAt': instance.createdAt,
      'orderId': instance.orderId,
    };
