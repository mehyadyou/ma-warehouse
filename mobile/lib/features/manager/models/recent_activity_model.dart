import 'package:freezed_annotation/freezed_annotation.dart';

import 'transaction_entry_model.dart';
import 'history_entry_model.dart';

part 'recent_activity_model.freezed.dart';
part 'recent_activity_model.g.dart';

@freezed
abstract class RecentActivityData with _$RecentActivityData {
  const factory RecentActivityData({
    @Default(<TransactionEntryModel>[]) List<TransactionEntryModel> transactions,
    @Default(<HistoryEntryModel>[]) List<HistoryEntryModel> activityLog,
  }) = _RecentActivityData;

  factory RecentActivityData.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityDataFromJson(json);
}
