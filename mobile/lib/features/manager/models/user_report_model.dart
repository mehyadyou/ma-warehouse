import 'package:freezed_annotation/freezed_annotation.dart';

import 'history_entry_model.dart';

part 'user_report_model.freezed.dart';

@freezed
abstract class UserReportModel with _$UserReportModel {
  const factory UserReportModel({
    required UserReportUserModel user,
    @Default(UserReportStatsModel()) UserReportStatsModel stats,
    HistoryEntryModel? lastActivity,
    @Default(<HistoryEntryModel>[]) List<HistoryEntryModel> recentActivities,
  }) = _UserReportModel;

  factory UserReportModel.fromJson(Map<String, dynamic> json) {
    return UserReportModel(
      user: UserReportUserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      stats: json['stats'] is Map
          ? UserReportStatsModel.fromJson(Map<String, dynamic>.from(json['stats'] as Map))
          : const UserReportStatsModel(),
      lastActivity: json['lastActivity'] is Map
          ? HistoryEntryModel.fromJson(Map<String, dynamic>.from(json['lastActivity'] as Map))
          : null,
      recentActivities: (json['recentActivities'] as List<dynamic>? ?? [])
          .map((e) => HistoryEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

@freezed
abstract class UserReportUserModel with _$UserReportUserModel {
  const factory UserReportUserModel({
    required String id,
    String? name,
    String? phone,
    String? role,
    String? createdAt,
    String? warehouseName,
  }) = _UserReportUserModel;

  factory UserReportUserModel.fromJson(Map<String, dynamic> json) {
    final warehouse = json['warehouse'];
    return UserReportUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      createdAt: json['createdAt'] as String?,
      warehouseName: warehouse is Map ? warehouse['name'] as String? : null,
    );
  }
}

@freezed
abstract class UserReportStatsModel with _$UserReportStatsModel {
  const factory UserReportStatsModel({
    @Default(0) num totalCheckins,
    @Default(0) num totalUnits,
    @Default(0) num totalReturns,
    @Default(0) num totalOrders,
    @Default(0) num totalDeliveries,
  }) = _UserReportStatsModel;

  factory UserReportStatsModel.fromJson(Map<String, dynamic> json) {
    return UserReportStatsModel(
      totalCheckins: json['totalCheckins'] as num? ?? 0,
      totalUnits: json['totalUnits'] as num? ?? 0,
      totalReturns: json['totalReturns'] as num? ?? 0,
      totalOrders: json['totalOrders'] as num? ?? 0,
      totalDeliveries: json['totalDeliveries'] as num? ?? 0,
    );
  }
}
