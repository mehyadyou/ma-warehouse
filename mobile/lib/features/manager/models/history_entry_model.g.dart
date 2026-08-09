// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistoryEntryModel _$HistoryEntryModelFromJson(Map<String, dynamic> json) =>
    _HistoryEntryModel(
      type: json['type'] as String?,
      createdAt: json['createdAt'] as String?,
      label: json['label'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$HistoryEntryModelToJson(_HistoryEntryModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'createdAt': instance.createdAt,
      'label': instance.label,
      'userName': instance.userName,
    };
