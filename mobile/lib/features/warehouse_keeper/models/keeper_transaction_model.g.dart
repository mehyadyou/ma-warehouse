// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keeper_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KeeperTransactionModel _$KeeperTransactionModelFromJson(
  Map<String, dynamic> json,
) => _KeeperTransactionModel(
  type: json['type'] as String? ?? '',
  productName: json['productName'] as String? ?? '',
  userName: json['userName'] as String? ?? '',
  quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String? ?? '',
);

Map<String, dynamic> _$KeeperTransactionModelToJson(
  _KeeperTransactionModel instance,
) => <String, dynamic>{
  'type': instance.type,
  'productName': instance.productName,
  'userName': instance.userName,
  'quantity': instance.quantity,
  'createdAt': instance.createdAt,
};
