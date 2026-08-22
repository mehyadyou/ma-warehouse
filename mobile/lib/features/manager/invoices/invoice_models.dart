import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_models.freezed.dart';
part 'invoice_models.g.dart';

/// نوع فاکتور: ساده یا رسمی (رسمی شامل کد اقتصادی، شماره ثبت و مالیات است)
enum InvoiceType { simple, formal }

Map<String, dynamic> _partyToJson(InvoicePartyModel party) => party.toJson();
InvoicePartyModel _partyFromJson(Object? json) =>
    InvoicePartyModel.fromJson(json as Map<String, dynamic>);

List<Map<String, dynamic>> _itemsToJson(List<InvoiceItemModel> items) =>
    items.map((item) => item.toJson()).toList();
List<InvoiceItemModel> _itemsFromJson(Object? json) => (json as List)
    .map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
    .toList();

/// طرف فاکتور (فروشنده یا خریدار)
@freezed
abstract class InvoicePartyModel with _$InvoicePartyModel {
  const factory InvoicePartyModel({
    @Default('') String name,
    @Default('') String phone,
    @Default('') String address,
    @Default('') String economicCode,
    @Default('') String registerNumber,
  }) = _InvoicePartyModel;

  factory InvoicePartyModel.fromJson(Map<String, dynamic> json) =>
      _$InvoicePartyModelFromJson(json);

  @override
  Map<String, dynamic> toJson();
}

/// یک ردیف از اقلام فاکتور
@freezed
abstract class InvoiceItemModel with _$InvoiceItemModel {
  const factory InvoiceItemModel({
    @Default('') String description,
    @Default(1) num quantity,
    @Default('عدد') String unit,
    @Default(0) num unitPrice,
    @Default(0) num discount,
  }) = _InvoiceItemModel;

  const InvoiceItemModel._();

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemModelFromJson(json);

  @override
  Map<String, dynamic> toJson();

  /// جمع ردیف = (تعداد × قیمت واحد) − تخفیف
  num get rowTotal => (quantity * unitPrice) - discount;
}

/// پیش‌نویس یا فاکتور ذخیره‌شده
@freezed
abstract class InvoiceDraftModel with _$InvoiceDraftModel {
  const factory InvoiceDraftModel({
    @Default('') String id,
    @Default('') String number,
    @Default('') String dateLabel,
    @Default(InvoiceType.simple) InvoiceType type,
    @Default('نقدی') String paymentMethod,
    @JsonKey(toJson: _partyToJson, fromJson: _partyFromJson)
    @Default(InvoicePartyModel())
    InvoicePartyModel seller,
    @JsonKey(toJson: _partyToJson, fromJson: _partyFromJson)
    @Default(InvoicePartyModel())
    InvoicePartyModel buyer,
    @JsonKey(toJson: _itemsToJson, fromJson: _itemsFromJson)
    @Default(<InvoiceItemModel>[])
    List<InvoiceItemModel> items,
    @Default(false) bool includeTax,
    @Default(9) num taxPercent,
    @Default(0) num shippingCost,
    @Default('') String notes,
    String? logoPath,
    String? signaturePath,
    String? pdfPath,
    String? sourceOrderId,
    @Default('') String createdAt,
  }) = _InvoiceDraftModel;

  const InvoiceDraftModel._();

  factory InvoiceDraftModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceDraftModelFromJson(json);

  /// جمع اقلام پس از کسر تخفیف‌ها
  num get subtotal => items.fold(0, (sum, item) => sum + item.rowTotal);

  /// مالیات ارزش افزوده (فقط در فاکتور رسمی با تیک «ارزش افزوده»)
  num get taxAmount =>
      includeTax && type == InvoiceType.formal
          ? (subtotal * taxPercent / 100)
          : 0;

  /// مبلغ نهایی فاکتور
  num get grandTotal => subtotal + taxAmount + shippingCost;

  bool get isEmpty =>
      seller.name.trim().isEmpty &&
      buyer.name.trim().isEmpty &&
      items.isEmpty;

  InvoiceDraftModel copyWithResetId() => copyWith(
        id: '',
        pdfPath: null,
        createdAt: '',
      );
}