import 'package:freezed_annotation/freezed_annotation.dart';

part 'keeper_transaction_model.freezed.dart';
part 'keeper_transaction_model.g.dart';

@freezed
abstract class KeeperTransactionModel with _$KeeperTransactionModel {
  const factory KeeperTransactionModel({
    @Default('') String type,
    @Default('') String productName,
    @Default('') String userName,
    @Default(0) int quantity,
    @Default('') String createdAt,
  }) = _KeeperTransactionModel;

  factory KeeperTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$KeeperTransactionModelFromJson(json);
}
