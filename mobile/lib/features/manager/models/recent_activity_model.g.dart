// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecentActivityData _$RecentActivityDataFromJson(Map<String, dynamic> json) =>
    _RecentActivityData(
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    TransactionEntryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <TransactionEntryModel>[],
      activityLog:
          (json['activityLog'] as List<dynamic>?)
              ?.map(
                (e) => HistoryEntryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <HistoryEntryModel>[],
    );

Map<String, dynamic> _$RecentActivityDataToJson(_RecentActivityData instance) =>
    <String, dynamic>{
      'transactions': instance.transactions,
      'activityLog': instance.activityLog,
    };
