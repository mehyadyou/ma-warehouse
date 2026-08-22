// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvoicePartyModel {

 String get name; String get phone; String get address; String get economicCode; String get registerNumber;
/// Create a copy of InvoicePartyModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoicePartyModelCopyWith<InvoicePartyModel> get copyWith => _$InvoicePartyModelCopyWithImpl<InvoicePartyModel>(this as InvoicePartyModel, _$identity);

  /// Serializes this InvoicePartyModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoicePartyModel&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.economicCode, economicCode) || other.economicCode == economicCode)&&(identical(other.registerNumber, registerNumber) || other.registerNumber == registerNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,phone,address,economicCode,registerNumber);

@override
String toString() {
  return 'InvoicePartyModel(name: $name, phone: $phone, address: $address, economicCode: $economicCode, registerNumber: $registerNumber)';
}


}

/// @nodoc
abstract mixin class $InvoicePartyModelCopyWith<$Res>  {
  factory $InvoicePartyModelCopyWith(InvoicePartyModel value, $Res Function(InvoicePartyModel) _then) = _$InvoicePartyModelCopyWithImpl;
@useResult
$Res call({
 String name, String phone, String address, String economicCode, String registerNumber
});




}
/// @nodoc
class _$InvoicePartyModelCopyWithImpl<$Res>
    implements $InvoicePartyModelCopyWith<$Res> {
  _$InvoicePartyModelCopyWithImpl(this._self, this._then);

  final InvoicePartyModel _self;
  final $Res Function(InvoicePartyModel) _then;

/// Create a copy of InvoicePartyModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? phone = null,Object? address = null,Object? economicCode = null,Object? registerNumber = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,economicCode: null == economicCode ? _self.economicCode : economicCode // ignore: cast_nullable_to_non_nullable
as String,registerNumber: null == registerNumber ? _self.registerNumber : registerNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoicePartyModel].
extension InvoicePartyModelPatterns on InvoicePartyModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoicePartyModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoicePartyModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoicePartyModel value)  $default,){
final _that = this;
switch (_that) {
case _InvoicePartyModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoicePartyModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvoicePartyModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String phone,  String address,  String economicCode,  String registerNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoicePartyModel() when $default != null:
return $default(_that.name,_that.phone,_that.address,_that.economicCode,_that.registerNumber);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String phone,  String address,  String economicCode,  String registerNumber)  $default,) {final _that = this;
switch (_that) {
case _InvoicePartyModel():
return $default(_that.name,_that.phone,_that.address,_that.economicCode,_that.registerNumber);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String phone,  String address,  String economicCode,  String registerNumber)?  $default,) {final _that = this;
switch (_that) {
case _InvoicePartyModel() when $default != null:
return $default(_that.name,_that.phone,_that.address,_that.economicCode,_that.registerNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoicePartyModel implements InvoicePartyModel {
  const _InvoicePartyModel({this.name = '', this.phone = '', this.address = '', this.economicCode = '', this.registerNumber = ''});
  factory _InvoicePartyModel.fromJson(Map<String, dynamic> json) => _$InvoicePartyModelFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String address;
@override@JsonKey() final  String economicCode;
@override@JsonKey() final  String registerNumber;

/// Create a copy of InvoicePartyModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoicePartyModelCopyWith<_InvoicePartyModel> get copyWith => __$InvoicePartyModelCopyWithImpl<_InvoicePartyModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoicePartyModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoicePartyModel&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.economicCode, economicCode) || other.economicCode == economicCode)&&(identical(other.registerNumber, registerNumber) || other.registerNumber == registerNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,phone,address,economicCode,registerNumber);

@override
String toString() {
  return 'InvoicePartyModel(name: $name, phone: $phone, address: $address, economicCode: $economicCode, registerNumber: $registerNumber)';
}


}

/// @nodoc
abstract mixin class _$InvoicePartyModelCopyWith<$Res> implements $InvoicePartyModelCopyWith<$Res> {
  factory _$InvoicePartyModelCopyWith(_InvoicePartyModel value, $Res Function(_InvoicePartyModel) _then) = __$InvoicePartyModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String phone, String address, String economicCode, String registerNumber
});




}
/// @nodoc
class __$InvoicePartyModelCopyWithImpl<$Res>
    implements _$InvoicePartyModelCopyWith<$Res> {
  __$InvoicePartyModelCopyWithImpl(this._self, this._then);

  final _InvoicePartyModel _self;
  final $Res Function(_InvoicePartyModel) _then;

/// Create a copy of InvoicePartyModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? phone = null,Object? address = null,Object? economicCode = null,Object? registerNumber = null,}) {
  return _then(_InvoicePartyModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,economicCode: null == economicCode ? _self.economicCode : economicCode // ignore: cast_nullable_to_non_nullable
as String,registerNumber: null == registerNumber ? _self.registerNumber : registerNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$InvoiceItemModel {

 String get description; num get quantity; String get unit; num get unitPrice; num get discount;
/// Create a copy of InvoiceItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceItemModelCopyWith<InvoiceItemModel> get copyWith => _$InvoiceItemModelCopyWithImpl<InvoiceItemModel>(this as InvoiceItemModel, _$identity);

  /// Serializes this InvoiceItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceItemModel&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.discount, discount) || other.discount == discount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,quantity,unit,unitPrice,discount);

@override
String toString() {
  return 'InvoiceItemModel(description: $description, quantity: $quantity, unit: $unit, unitPrice: $unitPrice, discount: $discount)';
}


}

/// @nodoc
abstract mixin class $InvoiceItemModelCopyWith<$Res>  {
  factory $InvoiceItemModelCopyWith(InvoiceItemModel value, $Res Function(InvoiceItemModel) _then) = _$InvoiceItemModelCopyWithImpl;
@useResult
$Res call({
 String description, num quantity, String unit, num unitPrice, num discount
});




}
/// @nodoc
class _$InvoiceItemModelCopyWithImpl<$Res>
    implements $InvoiceItemModelCopyWith<$Res> {
  _$InvoiceItemModelCopyWithImpl(this._self, this._then);

  final InvoiceItemModel _self;
  final $Res Function(InvoiceItemModel) _then;

/// Create a copy of InvoiceItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? quantity = null,Object? unit = null,Object? unitPrice = null,Object? discount = null,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as num,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceItemModel].
extension InvoiceItemModelPatterns on InvoiceItemModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceItemModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceItemModel value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceItemModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceItemModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String description,  num quantity,  String unit,  num unitPrice,  num discount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceItemModel() when $default != null:
return $default(_that.description,_that.quantity,_that.unit,_that.unitPrice,_that.discount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String description,  num quantity,  String unit,  num unitPrice,  num discount)  $default,) {final _that = this;
switch (_that) {
case _InvoiceItemModel():
return $default(_that.description,_that.quantity,_that.unit,_that.unitPrice,_that.discount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String description,  num quantity,  String unit,  num unitPrice,  num discount)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceItemModel() when $default != null:
return $default(_that.description,_that.quantity,_that.unit,_that.unitPrice,_that.discount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceItemModel extends InvoiceItemModel {
  const _InvoiceItemModel({this.description = '', this.quantity = 1, this.unit = 'عدد', this.unitPrice = 0, this.discount = 0}): super._();
  factory _InvoiceItemModel.fromJson(Map<String, dynamic> json) => _$InvoiceItemModelFromJson(json);

@override@JsonKey() final  String description;
@override@JsonKey() final  num quantity;
@override@JsonKey() final  String unit;
@override@JsonKey() final  num unitPrice;
@override@JsonKey() final  num discount;

/// Create a copy of InvoiceItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceItemModelCopyWith<_InvoiceItemModel> get copyWith => __$InvoiceItemModelCopyWithImpl<_InvoiceItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceItemModel&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.discount, discount) || other.discount == discount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,quantity,unit,unitPrice,discount);

@override
String toString() {
  return 'InvoiceItemModel(description: $description, quantity: $quantity, unit: $unit, unitPrice: $unitPrice, discount: $discount)';
}


}

/// @nodoc
abstract mixin class _$InvoiceItemModelCopyWith<$Res> implements $InvoiceItemModelCopyWith<$Res> {
  factory _$InvoiceItemModelCopyWith(_InvoiceItemModel value, $Res Function(_InvoiceItemModel) _then) = __$InvoiceItemModelCopyWithImpl;
@override @useResult
$Res call({
 String description, num quantity, String unit, num unitPrice, num discount
});




}
/// @nodoc
class __$InvoiceItemModelCopyWithImpl<$Res>
    implements _$InvoiceItemModelCopyWith<$Res> {
  __$InvoiceItemModelCopyWithImpl(this._self, this._then);

  final _InvoiceItemModel _self;
  final $Res Function(_InvoiceItemModel) _then;

/// Create a copy of InvoiceItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? quantity = null,Object? unit = null,Object? unitPrice = null,Object? discount = null,}) {
  return _then(_InvoiceItemModel(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as num,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$InvoiceDraftModel {

 String get id; String get number; String get dateLabel; InvoiceType get type; String get paymentMethod;@JsonKey(toJson: _partyToJson, fromJson: _partyFromJson) InvoicePartyModel get seller;@JsonKey(toJson: _partyToJson, fromJson: _partyFromJson) InvoicePartyModel get buyer;@JsonKey(toJson: _itemsToJson, fromJson: _itemsFromJson) List<InvoiceItemModel> get items; bool get includeTax; num get taxPercent; num get shippingCost; String get notes; String? get logoPath; String? get signaturePath; String? get pdfPath; String? get sourceOrderId; String get createdAt;
/// Create a copy of InvoiceDraftModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceDraftModelCopyWith<InvoiceDraftModel> get copyWith => _$InvoiceDraftModelCopyWithImpl<InvoiceDraftModel>(this as InvoiceDraftModel, _$identity);

  /// Serializes this InvoiceDraftModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceDraftModel&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.dateLabel, dateLabel) || other.dateLabel == dateLabel)&&(identical(other.type, type) || other.type == type)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.buyer, buyer) || other.buyer == buyer)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.includeTax, includeTax) || other.includeTax == includeTax)&&(identical(other.taxPercent, taxPercent) || other.taxPercent == taxPercent)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.signaturePath, signaturePath) || other.signaturePath == signaturePath)&&(identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath)&&(identical(other.sourceOrderId, sourceOrderId) || other.sourceOrderId == sourceOrderId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,dateLabel,type,paymentMethod,seller,buyer,const DeepCollectionEquality().hash(items),includeTax,taxPercent,shippingCost,notes,logoPath,signaturePath,pdfPath,sourceOrderId,createdAt);

@override
String toString() {
  return 'InvoiceDraftModel(id: $id, number: $number, dateLabel: $dateLabel, type: $type, paymentMethod: $paymentMethod, seller: $seller, buyer: $buyer, items: $items, includeTax: $includeTax, taxPercent: $taxPercent, shippingCost: $shippingCost, notes: $notes, logoPath: $logoPath, signaturePath: $signaturePath, pdfPath: $pdfPath, sourceOrderId: $sourceOrderId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InvoiceDraftModelCopyWith<$Res>  {
  factory $InvoiceDraftModelCopyWith(InvoiceDraftModel value, $Res Function(InvoiceDraftModel) _then) = _$InvoiceDraftModelCopyWithImpl;
@useResult
$Res call({
 String id, String number, String dateLabel, InvoiceType type, String paymentMethod,@JsonKey(toJson: _partyToJson, fromJson: _partyFromJson) InvoicePartyModel seller,@JsonKey(toJson: _partyToJson, fromJson: _partyFromJson) InvoicePartyModel buyer,@JsonKey(toJson: _itemsToJson, fromJson: _itemsFromJson) List<InvoiceItemModel> items, bool includeTax, num taxPercent, num shippingCost, String notes, String? logoPath, String? signaturePath, String? pdfPath, String? sourceOrderId, String createdAt
});


$InvoicePartyModelCopyWith<$Res> get seller;$InvoicePartyModelCopyWith<$Res> get buyer;

}
/// @nodoc
class _$InvoiceDraftModelCopyWithImpl<$Res>
    implements $InvoiceDraftModelCopyWith<$Res> {
  _$InvoiceDraftModelCopyWithImpl(this._self, this._then);

  final InvoiceDraftModel _self;
  final $Res Function(InvoiceDraftModel) _then;

/// Create a copy of InvoiceDraftModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? dateLabel = null,Object? type = null,Object? paymentMethod = null,Object? seller = null,Object? buyer = null,Object? items = null,Object? includeTax = null,Object? taxPercent = null,Object? shippingCost = null,Object? notes = null,Object? logoPath = freezed,Object? signaturePath = freezed,Object? pdfPath = freezed,Object? sourceOrderId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,dateLabel: null == dateLabel ? _self.dateLabel : dateLabel // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InvoiceType,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,seller: null == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as InvoicePartyModel,buyer: null == buyer ? _self.buyer : buyer // ignore: cast_nullable_to_non_nullable
as InvoicePartyModel,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<InvoiceItemModel>,includeTax: null == includeTax ? _self.includeTax : includeTax // ignore: cast_nullable_to_non_nullable
as bool,taxPercent: null == taxPercent ? _self.taxPercent : taxPercent // ignore: cast_nullable_to_non_nullable
as num,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as num,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,signaturePath: freezed == signaturePath ? _self.signaturePath : signaturePath // ignore: cast_nullable_to_non_nullable
as String?,pdfPath: freezed == pdfPath ? _self.pdfPath : pdfPath // ignore: cast_nullable_to_non_nullable
as String?,sourceOrderId: freezed == sourceOrderId ? _self.sourceOrderId : sourceOrderId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of InvoiceDraftModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InvoicePartyModelCopyWith<$Res> get seller {
  
  return $InvoicePartyModelCopyWith<$Res>(_self.seller, (value) {
    return _then(_self.copyWith(seller: value));
  });
}/// Create a copy of InvoiceDraftModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InvoicePartyModelCopyWith<$Res> get buyer {
  
  return $InvoicePartyModelCopyWith<$Res>(_self.buyer, (value) {
    return _then(_self.copyWith(buyer: value));
  });
}
}


/// Adds pattern-matching-related methods to [InvoiceDraftModel].
extension InvoiceDraftModelPatterns on InvoiceDraftModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceDraftModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceDraftModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceDraftModel value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceDraftModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceDraftModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceDraftModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String number,  String dateLabel,  InvoiceType type,  String paymentMethod, @JsonKey(toJson: _partyToJson, fromJson: _partyFromJson)  InvoicePartyModel seller, @JsonKey(toJson: _partyToJson, fromJson: _partyFromJson)  InvoicePartyModel buyer, @JsonKey(toJson: _itemsToJson, fromJson: _itemsFromJson)  List<InvoiceItemModel> items,  bool includeTax,  num taxPercent,  num shippingCost,  String notes,  String? logoPath,  String? signaturePath,  String? pdfPath,  String? sourceOrderId,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceDraftModel() when $default != null:
return $default(_that.id,_that.number,_that.dateLabel,_that.type,_that.paymentMethod,_that.seller,_that.buyer,_that.items,_that.includeTax,_that.taxPercent,_that.shippingCost,_that.notes,_that.logoPath,_that.signaturePath,_that.pdfPath,_that.sourceOrderId,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String number,  String dateLabel,  InvoiceType type,  String paymentMethod, @JsonKey(toJson: _partyToJson, fromJson: _partyFromJson)  InvoicePartyModel seller, @JsonKey(toJson: _partyToJson, fromJson: _partyFromJson)  InvoicePartyModel buyer, @JsonKey(toJson: _itemsToJson, fromJson: _itemsFromJson)  List<InvoiceItemModel> items,  bool includeTax,  num taxPercent,  num shippingCost,  String notes,  String? logoPath,  String? signaturePath,  String? pdfPath,  String? sourceOrderId,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _InvoiceDraftModel():
return $default(_that.id,_that.number,_that.dateLabel,_that.type,_that.paymentMethod,_that.seller,_that.buyer,_that.items,_that.includeTax,_that.taxPercent,_that.shippingCost,_that.notes,_that.logoPath,_that.signaturePath,_that.pdfPath,_that.sourceOrderId,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String number,  String dateLabel,  InvoiceType type,  String paymentMethod, @JsonKey(toJson: _partyToJson, fromJson: _partyFromJson)  InvoicePartyModel seller, @JsonKey(toJson: _partyToJson, fromJson: _partyFromJson)  InvoicePartyModel buyer, @JsonKey(toJson: _itemsToJson, fromJson: _itemsFromJson)  List<InvoiceItemModel> items,  bool includeTax,  num taxPercent,  num shippingCost,  String notes,  String? logoPath,  String? signaturePath,  String? pdfPath,  String? sourceOrderId,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceDraftModel() when $default != null:
return $default(_that.id,_that.number,_that.dateLabel,_that.type,_that.paymentMethod,_that.seller,_that.buyer,_that.items,_that.includeTax,_that.taxPercent,_that.shippingCost,_that.notes,_that.logoPath,_that.signaturePath,_that.pdfPath,_that.sourceOrderId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceDraftModel extends InvoiceDraftModel {
  const _InvoiceDraftModel({this.id = '', this.number = '', this.dateLabel = '', this.type = InvoiceType.simple, this.paymentMethod = 'نقدی', @JsonKey(toJson: _partyToJson, fromJson: _partyFromJson) this.seller = const InvoicePartyModel(), @JsonKey(toJson: _partyToJson, fromJson: _partyFromJson) this.buyer = const InvoicePartyModel(), @JsonKey(toJson: _itemsToJson, fromJson: _itemsFromJson) final  List<InvoiceItemModel> items = const <InvoiceItemModel>[], this.includeTax = false, this.taxPercent = 9, this.shippingCost = 0, this.notes = '', this.logoPath, this.signaturePath, this.pdfPath, this.sourceOrderId, this.createdAt = ''}): _items = items,super._();
  factory _InvoiceDraftModel.fromJson(Map<String, dynamic> json) => _$InvoiceDraftModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String number;
@override@JsonKey() final  String dateLabel;
@override@JsonKey() final  InvoiceType type;
@override@JsonKey() final  String paymentMethod;
@override@JsonKey(toJson: _partyToJson, fromJson: _partyFromJson) final  InvoicePartyModel seller;
@override@JsonKey(toJson: _partyToJson, fromJson: _partyFromJson) final  InvoicePartyModel buyer;
 final  List<InvoiceItemModel> _items;
@override@JsonKey(toJson: _itemsToJson, fromJson: _itemsFromJson) List<InvoiceItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool includeTax;
@override@JsonKey() final  num taxPercent;
@override@JsonKey() final  num shippingCost;
@override@JsonKey() final  String notes;
@override final  String? logoPath;
@override final  String? signaturePath;
@override final  String? pdfPath;
@override final  String? sourceOrderId;
@override@JsonKey() final  String createdAt;

/// Create a copy of InvoiceDraftModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceDraftModelCopyWith<_InvoiceDraftModel> get copyWith => __$InvoiceDraftModelCopyWithImpl<_InvoiceDraftModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceDraftModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceDraftModel&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.dateLabel, dateLabel) || other.dateLabel == dateLabel)&&(identical(other.type, type) || other.type == type)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.buyer, buyer) || other.buyer == buyer)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.includeTax, includeTax) || other.includeTax == includeTax)&&(identical(other.taxPercent, taxPercent) || other.taxPercent == taxPercent)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.signaturePath, signaturePath) || other.signaturePath == signaturePath)&&(identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath)&&(identical(other.sourceOrderId, sourceOrderId) || other.sourceOrderId == sourceOrderId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,dateLabel,type,paymentMethod,seller,buyer,const DeepCollectionEquality().hash(_items),includeTax,taxPercent,shippingCost,notes,logoPath,signaturePath,pdfPath,sourceOrderId,createdAt);

@override
String toString() {
  return 'InvoiceDraftModel(id: $id, number: $number, dateLabel: $dateLabel, type: $type, paymentMethod: $paymentMethod, seller: $seller, buyer: $buyer, items: $items, includeTax: $includeTax, taxPercent: $taxPercent, shippingCost: $shippingCost, notes: $notes, logoPath: $logoPath, signaturePath: $signaturePath, pdfPath: $pdfPath, sourceOrderId: $sourceOrderId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceDraftModelCopyWith<$Res> implements $InvoiceDraftModelCopyWith<$Res> {
  factory _$InvoiceDraftModelCopyWith(_InvoiceDraftModel value, $Res Function(_InvoiceDraftModel) _then) = __$InvoiceDraftModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String number, String dateLabel, InvoiceType type, String paymentMethod,@JsonKey(toJson: _partyToJson, fromJson: _partyFromJson) InvoicePartyModel seller,@JsonKey(toJson: _partyToJson, fromJson: _partyFromJson) InvoicePartyModel buyer,@JsonKey(toJson: _itemsToJson, fromJson: _itemsFromJson) List<InvoiceItemModel> items, bool includeTax, num taxPercent, num shippingCost, String notes, String? logoPath, String? signaturePath, String? pdfPath, String? sourceOrderId, String createdAt
});


@override $InvoicePartyModelCopyWith<$Res> get seller;@override $InvoicePartyModelCopyWith<$Res> get buyer;

}
/// @nodoc
class __$InvoiceDraftModelCopyWithImpl<$Res>
    implements _$InvoiceDraftModelCopyWith<$Res> {
  __$InvoiceDraftModelCopyWithImpl(this._self, this._then);

  final _InvoiceDraftModel _self;
  final $Res Function(_InvoiceDraftModel) _then;

/// Create a copy of InvoiceDraftModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? dateLabel = null,Object? type = null,Object? paymentMethod = null,Object? seller = null,Object? buyer = null,Object? items = null,Object? includeTax = null,Object? taxPercent = null,Object? shippingCost = null,Object? notes = null,Object? logoPath = freezed,Object? signaturePath = freezed,Object? pdfPath = freezed,Object? sourceOrderId = freezed,Object? createdAt = null,}) {
  return _then(_InvoiceDraftModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,dateLabel: null == dateLabel ? _self.dateLabel : dateLabel // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InvoiceType,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,seller: null == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as InvoicePartyModel,buyer: null == buyer ? _self.buyer : buyer // ignore: cast_nullable_to_non_nullable
as InvoicePartyModel,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<InvoiceItemModel>,includeTax: null == includeTax ? _self.includeTax : includeTax // ignore: cast_nullable_to_non_nullable
as bool,taxPercent: null == taxPercent ? _self.taxPercent : taxPercent // ignore: cast_nullable_to_non_nullable
as num,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as num,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,signaturePath: freezed == signaturePath ? _self.signaturePath : signaturePath // ignore: cast_nullable_to_non_nullable
as String?,pdfPath: freezed == pdfPath ? _self.pdfPath : pdfPath // ignore: cast_nullable_to_non_nullable
as String?,sourceOrderId: freezed == sourceOrderId ? _self.sourceOrderId : sourceOrderId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of InvoiceDraftModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InvoicePartyModelCopyWith<$Res> get seller {
  
  return $InvoicePartyModelCopyWith<$Res>(_self.seller, (value) {
    return _then(_self.copyWith(seller: value));
  });
}/// Create a copy of InvoiceDraftModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InvoicePartyModelCopyWith<$Res> get buyer {
  
  return $InvoicePartyModelCopyWith<$Res>(_self.buyer, (value) {
    return _then(_self.copyWith(buyer: value));
  });
}
}

// dart format on
