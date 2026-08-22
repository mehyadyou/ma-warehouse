import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_activity_model.freezed.dart';
part 'recent_activity_model.g.dart';

@freezed
abstract class RecentActivityData with _$RecentActivityData {
  const factory RecentActivityData({
    @Default(<ActivityEntryModel>[]) List<ActivityEntryModel> activities,
  }) = _RecentActivityData;

  factory RecentActivityData.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityDataFromJson(json);
}

/// یک ردیف از فید فعالیت‌های اخیر — از تراکنش یا لاگ (activityType مشخص می‌کند)
@freezed
abstract class ActivityEntryModel with _$ActivityEntryModel {
  const factory ActivityEntryModel({
    String? id,
    String? activityType,
    String? type,
    String? title,
    String? label,
    String? unit,
    @Default(0) num quantity,
    String? warehouseName,
    String? userName,
    String? createdAt,
    String? orderId,
  }) = _ActivityEntryModel;

  factory ActivityEntryModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityEntryModelFromJson(json);
}
