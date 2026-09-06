// مدل‌های گزارش عملکرد انباردار — بدون codegen (کلاس‌های ساده با fromJson دستی).

class KeeperReportSummary {
  final int inUnits;
  final int outUnits;
  final int returnUnits;
  final int outCount;
  final int checkinCount;
  final int returnReceivedCount;
  final int ordersShipped;
  final int transfersExecuted;
  final int driverAssignments;
  final int myActions;

  const KeeperReportSummary({
    required this.inUnits,
    required this.outUnits,
    required this.returnUnits,
    required this.outCount,
    required this.checkinCount,
    required this.returnReceivedCount,
    required this.ordersShipped,
    required this.transfersExecuted,
    required this.driverAssignments,
    required this.myActions,
  });

  factory KeeperReportSummary.fromJson(Map<String, dynamic> json) {
    int n(String key) => (json[key] as num?)?.toInt() ?? 0;
    return KeeperReportSummary(
      inUnits: n('inUnits'),
      outUnits: n('outUnits'),
      returnUnits: n('returnUnits'),
      outCount: n('outCount'),
      checkinCount: n('checkinCount'),
      returnReceivedCount: n('returnReceivedCount'),
      ordersShipped: n('ordersShipped'),
      transfersExecuted: n('transfersExecuted'),
      driverAssignments: n('driverAssignments'),
      myActions: n('myActions'),
    );
  }
}

class KeeperDailyPoint {
  final String date; // YYYY-MM-DD
  final int inUnits;
  final int outUnits;

  const KeeperDailyPoint({
    required this.date,
    required this.inUnits,
    required this.outUnits,
  });

  factory KeeperDailyPoint.fromJson(Map<String, dynamic> json) {
    return KeeperDailyPoint(
      date: json['date'] as String? ?? '',
      inUnits: (json['inUnits'] as num?)?.toInt() ?? 0,
      outUnits: (json['outUnits'] as num?)?.toInt() ?? 0,
    );
  }
}

class KeeperStatusCount {
  final String status;
  final int count;

  const KeeperStatusCount({required this.status, required this.count});

  factory KeeperStatusCount.fromJson(Map<String, dynamic> json) {
    return KeeperStatusCount(
      status: json['status'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class KeeperProductUnits {
  final String name;
  final int units;

  const KeeperProductUnits({required this.name, required this.units});

  factory KeeperProductUnits.fromJson(Map<String, dynamic> json) {
    return KeeperProductUnits(
      name: json['name'] as String? ?? 'نامشخص',
      units: (json['units'] as num?)?.toInt() ?? 0,
    );
  }
}

class KeeperActivityItem {
  final String type;
  final String label;
  final String createdAt; // ISO

  const KeeperActivityItem({
    required this.type,
    required this.label,
    required this.createdAt,
  });

  factory KeeperActivityItem.fromJson(Map<String, dynamic> json) {
    return KeeperActivityItem(
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class KeeperReportsData {
  final KeeperReportSummary summary;
  final List<KeeperDailyPoint> daily;
  final List<KeeperStatusCount> ordersByStatus;
  final List<KeeperProductUnits> topIn;
  final List<KeeperProductUnits> topOut;
  final List<KeeperActivityItem> recent;

  const KeeperReportsData({
    required this.summary,
    required this.daily,
    required this.ordersByStatus,
    required this.topIn,
    required this.topOut,
    required this.recent,
  });

  factory KeeperReportsData.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (json[key] as List? ?? [])
            .whereType<Map>()
            .map((e) => parse(Map<String, dynamic>.from(e)))
            .toList();

    return KeeperReportsData(
      summary: KeeperReportSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map? ?? {}),
      ),
      daily: list('daily', KeeperDailyPoint.fromJson),
      ordersByStatus: list('ordersByStatus', KeeperStatusCount.fromJson),
      topIn: list('topIn', KeeperProductUnits.fromJson),
      topOut: list('topOut', KeeperProductUnits.fromJson),
      recent: list('recent', KeeperActivityItem.fromJson),
    );
  }
}