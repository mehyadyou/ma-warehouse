// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoicePartyModel _$InvoicePartyModelFromJson(Map<String, dynamic> json) =>
    _InvoicePartyModel(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      economicCode: json['economicCode'] as String? ?? '',
      registerNumber: json['registerNumber'] as String? ?? '',
    );

Map<String, dynamic> _$InvoicePartyModelToJson(_InvoicePartyModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'economicCode': instance.economicCode,
      'registerNumber': instance.registerNumber,
    };

_InvoiceItemModel _$InvoiceItemModelFromJson(Map<String, dynamic> json) =>
    _InvoiceItemModel(
      description: json['description'] as String? ?? '',
      quantity: json['quantity'] as num? ?? 1,
      unit: json['unit'] as String? ?? 'عدد',
      unitPrice: json['unitPrice'] as num? ?? 0,
      discount: json['discount'] as num? ?? 0,
    );

Map<String, dynamic> _$InvoiceItemModelToJson(_InvoiceItemModel instance) =>
    <String, dynamic>{
      'description': instance.description,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'unitPrice': instance.unitPrice,
      'discount': instance.discount,
    };

_InvoiceDraftModel _$InvoiceDraftModelFromJson(Map<String, dynamic> json) =>
    _InvoiceDraftModel(
      id: json['id'] as String? ?? '',
      number: json['number'] as String? ?? '',
      dateLabel: json['dateLabel'] as String? ?? '',
      type:
          $enumDecodeNullable(_$InvoiceTypeEnumMap, json['type']) ??
          InvoiceType.simple,
      paymentMethod: json['paymentMethod'] as String? ?? 'نقدی',
      seller: json['seller'] == null
          ? const InvoicePartyModel()
          : _partyFromJson(json['seller']),
      buyer: json['buyer'] == null
          ? const InvoicePartyModel()
          : _partyFromJson(json['buyer']),
      items: json['items'] == null
          ? const <InvoiceItemModel>[]
          : _itemsFromJson(json['items']),
      includeTax: json['includeTax'] as bool? ?? false,
      taxPercent: json['taxPercent'] as num? ?? 9,
      shippingCost: json['shippingCost'] as num? ?? 0,
      notes: json['notes'] as String? ?? '',
      logoPath: json['logoPath'] as String?,
      signaturePath: json['signaturePath'] as String?,
      pdfPath: json['pdfPath'] as String?,
      sourceOrderId: json['sourceOrderId'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );

Map<String, dynamic> _$InvoiceDraftModelToJson(_InvoiceDraftModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'dateLabel': instance.dateLabel,
      'type': _$InvoiceTypeEnumMap[instance.type]!,
      'paymentMethod': instance.paymentMethod,
      'seller': _partyToJson(instance.seller),
      'buyer': _partyToJson(instance.buyer),
      'items': _itemsToJson(instance.items),
      'includeTax': instance.includeTax,
      'taxPercent': instance.taxPercent,
      'shippingCost': instance.shippingCost,
      'notes': instance.notes,
      'logoPath': instance.logoPath,
      'signaturePath': instance.signaturePath,
      'pdfPath': instance.pdfPath,
      'sourceOrderId': instance.sourceOrderId,
      'createdAt': instance.createdAt,
    };

const _$InvoiceTypeEnumMap = {
  InvoiceType.simple: 'simple',
  InvoiceType.formal: 'formal',
};
