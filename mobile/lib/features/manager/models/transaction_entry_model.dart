import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entry_model.freezed.dart';
part 'transaction_entry_model.g.dart';

@freezed
abstract class TransactionEntryModel with _$TransactionEntryModel {
  const factory TransactionEntryModel({
    String? type,
    String? productName,
    String? title,
    String? warehouseName,
    String? userName,
    @Default(0) num quantity,
    String? createdAt,
  }) = _TransactionEntryModel;

  factory TransactionEntryModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionEntryModelFromJson(json);
}
