
// مدل‌های «سابقهٔ کامل محصولات» — fromJson دستی (بدون codegen)

class ProductHistoryRow {
  const ProductHistoryRow({
    required this.productId,
    required this.productName,
    required this.archived,
    required this.cartonTotal,
    required this.inStock,
    required this.shipped,
    required this.returned,
    required this.exited,
    required this.individualTotal,
    required this.individualInStock,
    this.txIn,
    this.txOut,
    this.txReturn,
    this.firstEntryAt,
    this.lastActivityAt,
  });

  final String productId;
  final String productName;
  final bool archived;

  /// کل کارتن‌ها (بسته‌ای + تکی)
  final int cartonTotal;
  final int inStock;
  final int shipped;
  final int returned;
  final int exited;

  /// کارتن‌های تکی (خروج واحدی)
  final int individualTotal;
  final int individualInStock;

  /// جمع واحدهای تراکنشی — null یعنی هیچ تراکنشی ثبت نشده
  final int? txIn;
  final int? txOut;
  final int? txReturn;

  final DateTime? firstEntryAt;
  final DateTime? lastActivityAt;

  factory ProductHistoryRow.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
    int intOf(dynamic v) => (v as num?)?.toInt() ?? 0;
    return ProductHistoryRow(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      archived: json['archived'] == true,
      cartonTotal: intOf(json['cartonTotal']),
      inStock: intOf(json['inStock']),
      shipped: intOf(json['shipped']),
      returned: intOf(json['returned']),
      exited: intOf(json['exited']),
      individualTotal: intOf(json['individualTotal']),
      individualInStock: intOf(json['individualInStock']),
      txIn: json['txIn'] == null ? null : intOf(json['txIn']),
      txOut: json['txOut'] == null ? null : intOf(json['txOut']),
      txReturn: json['txReturn'] == null ? null : intOf(json['txReturn']),
      firstEntryAt: dt(json['firstEntryAt']),
      lastActivityAt: dt(json['lastActivityAt']),
    );
  }
}

class ProductHistoryPage {
  const ProductHistoryPage({
    required this.rows,
    required this.total,
    required this.hasMore,
  });

  final List<ProductHistoryRow> rows;
  final int total;
  final bool hasMore;
}

// ─── جزئیات محصول ─────────────────────────────────────────────

class ProductHistoryDetailModel {
  const ProductHistoryDetailModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.archived,
    required this.models,
    required this.counts,
    required this.cartons,
    required this.transactions,
    required this.transfers,
    required this.truncatedCartons,
  });

  final String id;
  final String name;
  final String unit;
  final bool archived;
  final List<ProductModelBrief> models;
  final ProductHistoryCounts counts;
  final List<ProductHistoryCarton> cartons;
  final List<ProductHistoryTransaction> transactions;
  final List<ProductHistoryTransfer> transfers;

  /// آیا لیست کارتن‌ها به سقف سرور خورده (یعنی ممکن است بیشتر باشد)
  final bool truncatedCartons;

  factory ProductHistoryDetailModel.fromJson(Map<String, dynamic> json) {
    final product = (json['product'] as Map?) ?? const {};
    final counts = (json['counts'] as Map?) ?? const {};
    final truncated = (json['truncated'] as Map?) ?? const {};
    return ProductHistoryDetailModel(
      id: product['id']?.toString() ?? '',
      name: product['name']?.toString() ?? '',
      unit: product['unit']?.toString() ?? 'عدد',
      archived: product['archived'] == true,
      models: ((product['models'] as List?) ?? [])
          .map((m) => ProductModelBrief.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
      counts: ProductHistoryCounts.fromJson(Map<String, dynamic>.from(counts)),
      cartons: ((json['cartons'] as List?) ?? [])
          .map((c) => ProductHistoryCarton.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList(),
      transactions: ((json['transactions'] as List?) ?? [])
          .map((t) => ProductHistoryTransaction.fromJson(Map<String, dynamic>.from(t as Map)))
          .toList(),
      transfers: ((json['transfers'] as List?) ?? [])
          .map((t) => ProductHistoryTransfer.fromJson(Map<String, dynamic>.from(t as Map)))
          .toList(),
      truncatedCartons: truncated['cartons'] == true,
    );
  }
}

class ProductModelBrief {
  const ProductModelBrief({
    required this.id,
    required this.name,
    required this.archived,
    this.unitsPerBox,
    this.packageType,
  });

  final String id;
  final String name;
  final bool archived;
  final int? unitsPerBox;
  final String? packageType;

  factory ProductModelBrief.fromJson(Map<String, dynamic> json) =>
      ProductModelBrief(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        archived: json['archived'] == true,
        unitsPerBox: (json['unitsPerBox'] as num?)?.toInt(),
        packageType: json['packageType']?.toString(),
      );
}

class ProductHistoryCounts {
  const ProductHistoryCounts({
    required this.cartons,
    required this.inStock,
    required this.shipped,
    required this.returned,
    required this.exited,
    required this.individuals,
    required this.txIn,
    required this.txOut,
    required this.txReturn,
  });

  final int cartons;
  final int inStock;
  final int shipped;
  final int returned;
  final int exited;
  final int individuals;
  final int txIn;
  final int txOut;
  final int txReturn;

  factory ProductHistoryCounts.fromJson(Map<String, dynamic> json) {
    int intOf(dynamic v) => (v as num?)?.toInt() ?? 0;
    return ProductHistoryCounts(
      cartons: intOf(json['cartons']),
      inStock: intOf(json['inStock']),
      shipped: intOf(json['shipped']),
      returned: intOf(json['returned']),
      exited: intOf(json['exited']),
      individuals: intOf(json['individuals']),
      txIn: intOf(json['txIn']),
      txOut: intOf(json['txOut']),
      txReturn: intOf(json['txReturn']),
    );
  }
}

/// یک کارتن از سابقهٔ محصول — سریال/وضعیت/سفارش مشتری
class ProductHistoryCarton {
  const ProductHistoryCarton({
    required this.id,
    required this.isIndividual,
    required this.status,
    required this.createdAt,
    this.serialNumber,
    this.entryType,
    this.printedAt,
    this.scannedOutAt,
    this.warehouseName,
    this.modelName,
    this.order,
  });

  final String id;
  final String? serialNumber;
  final bool isIndividual;
  final String status;
  final String? entryType;
  final DateTime? createdAt;
  final DateTime? printedAt;
  final DateTime? scannedOutAt;
  final String? warehouseName;
  final String? modelName;
  final ProductHistoryOrder? order;

  factory ProductHistoryCarton.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
    return ProductHistoryCarton(
      id: json['id']?.toString() ?? '',
      serialNumber: json['serialNumber']?.toString(),
      isIndividual: json['isIndividual'] == true,
      status: json['status']?.toString() ?? 'IN_STOCK',
      entryType: json['entryType']?.toString(),
      createdAt: dt(json['createdAt']),
      printedAt: dt(json['printedAt']),
      scannedOutAt: dt(json['scannedOutAt']),
      warehouseName: json['warehouseName']?.toString(),
      modelName: json['modelName']?.toString(),
      order: json['order'] == null
          ? null
          : ProductHistoryOrder.fromJson(
              Map<String, dynamic>.from(json['order'] as Map)),
    );
  }
}

/// سفارشی که کارتن برایش ارسال شده — مشتری و تحویل
class ProductHistoryOrder {
  const ProductHistoryOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.senderName,
    this.receiverName,
    this.customerPhone,
    this.city,
    this.carrier,
    this.createdAt,
    this.deliveryStatus,
    this.deliveredAt,
    this.driverName,
  });

  final String id;
  final int orderNumber;
  final String status;
  final String? senderName;
  final String? receiverName;
  final String? customerPhone;
  final String? city;
  final String? carrier;
  final DateTime? createdAt;
  final String? deliveryStatus;
  final DateTime? deliveredAt;
  final String? driverName;

  factory ProductHistoryOrder.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
    return ProductHistoryOrder(
      id: json['id']?.toString() ?? '',
      orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      senderName: json['senderName']?.toString(),
      receiverName: json['receiverName']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      city: json['city']?.toString(),
      carrier: json['carrier']?.toString(),
      createdAt: dt(json['createdAt']),
      deliveryStatus: json['deliveryStatus']?.toString(),
      deliveredAt: dt(json['deliveredAt']),
      driverName: json['driverName']?.toString(),
    );
  }
}

class ProductHistoryTransaction {
  const ProductHistoryTransaction({
    required this.id,
    required this.type,
    required this.quantity,
    required this.warehouseName,
    required this.userName,
    required this.createdAt,
  });

  final String id;
  final String type; // IN | OUT | RETURN
  final int quantity;
  final String warehouseName;
  final String userName;
  final DateTime createdAt;

  factory ProductHistoryTransaction.fromJson(Map<String, dynamic> json) {
    return ProductHistoryTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'IN',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      warehouseName: json['warehouseName']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class ProductHistoryTransfer {
  const ProductHistoryTransfer({
    required this.id,
    required this.quantity,
    required this.status,
    required this.isExit,
    required this.fromWarehouseName,
    required this.createdByName,
    required this.createdAt,
    this.description,
    this.toWarehouseName,
    this.completedAt,
  });

  final String id;
  final int quantity;
  final String status;

  /// true = خروج از سیستم (بدون انبار مقصد)، false = جابه‌جایی بین دو انبار
  final bool isExit;
  final String fromWarehouseName;
  final String? toWarehouseName;
  final String? description;
  final String createdByName;
  final DateTime createdAt;
  final DateTime? completedAt;

  factory ProductHistoryTransfer.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
    return ProductHistoryTransfer(
      id: json['id']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      isExit: json['isExit'] == true,
      fromWarehouseName: json['fromWarehouseName']?.toString() ?? '',
      toWarehouseName: json['toWarehouseName']?.toString(),
      description: json['description']?.toString(),
      createdByName: json['createdByName']?.toString() ?? '',
      createdAt: dt(json['createdAt']) ?? DateTime.now(),
      completedAt: dt(json['completedAt']),
    );
  }
}
