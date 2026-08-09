// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionEntryModel _$TransactionEntryModelFromJson(
  Map<String, dynamic> json,
) => _TransactionEntryModel(
  type: json['type'] as String?,
  productName: json['productName'] as String?,
  title: json['title'] as String?,
  warehouseName: json['warehouseName'] as String?,
  userName: json['userName'] as String?,
  quantity: json['quantity'] as num? ?? 0,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$TransactionEntryModelToJson(
  _TransactionEntryModel instance,
) => <String, dynamic>{
  'type': instance.type,
  'productName': instance.productName,
  'title': instance.title,
  'warehouseName': instance.warehouseName,
  'userName': instance.userName,
  'quantity': instance.quantity,
  'createdAt': instance.createdAt,
};
