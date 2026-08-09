// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckInResultModel _$CheckInResultModelFromJson(Map<String, dynamic> json) =>
    _CheckInResultModel(
      cartons:
          (json['cartons'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
    );

Map<String, dynamic> _$CheckInResultModelToJson(_CheckInResultModel instance) =>
    <String, dynamic>{'cartons': instance.cartons};
