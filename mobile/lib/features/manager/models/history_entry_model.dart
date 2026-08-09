import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_entry_model.freezed.dart';
part 'history_entry_model.g.dart';

@freezed
abstract class HistoryEntryModel with _$HistoryEntryModel {
  const factory HistoryEntryModel({
    String? type,
    String? createdAt,
    String? label,
    String? userName,
  }) = _HistoryEntryModel;

  factory HistoryEntryModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryEntryModelFromJson(json);
}
