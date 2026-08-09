// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderModel {

 String get id; String? get senderName; String? get receiverName; String? get customerPhone; String? get city; String? get address; String? get postalCode; String? get shippingMethod; String? get carrier; String? get warehouseName; String? get driverName; String? get status; String? get deliveryStatus; int? get badgeCount; String? get createdAt; String? get deliveredAt; List<OrderItemModel> get items;
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderModelCopyWith<OrderModel> get copyWith => _$OrderModelCopyWithImpl<OrderModel>(this as OrderModel, _$identity);

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.city, city) || other.city == city)&&(identical(other.address, address) || other.address == address)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryStatus, deliveryStatus) || other.deliveryStatus == deliveryStatus)&&(identical(other.badgeCount, badgeCount) || other.badgeCount == badgeCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderName,receiverName,customerPhone,city,address,postalCode,shippingMethod,carrier,warehouseName,driverName,status,deliveryStatus,badgeCount,createdAt,deliveredAt,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'OrderModel(id: $id, senderName: $senderName, receiverName: $receiverName, customerPhone: $customerPhone, city: $city, address: $address, postalCode: $postalCode, shippingMethod: $shippingMethod, carrier: $carrier, warehouseName: $warehouseName, driverName: $driverName, status: $status, deliveryStatus: $deliveryStatus, badgeCount: $badgeCount, createdAt: $createdAt, deliveredAt: $deliveredAt, items: $items)';
}


}

/// @nodoc
abstract mixin class $OrderModelCopyWith<$Res>  {
  factory $OrderModelCopyWith(OrderModel value, $Res Function(OrderModel) _then) = _$OrderModelCopyWithImpl;
@useResult
$Res call({
 String id, String? senderName, String? receiverName, String? customerPhone, String? city, String? address, String? postalCode, String? shippingMethod, String? carrier, String? warehouseName, String? driverName, String? status, String? deliveryStatus, int? badgeCount, String? createdAt, String? deliveredAt, List<OrderItemModel> items
});




}
/// @nodoc
class _$OrderModelCopyWithImpl<$Res>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._self, this._then);

  final OrderModel _self;
  final $Res Function(OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderName = freezed,Object? receiverName = freezed,Object? customerPhone = freezed,Object? city = freezed,Object? address = freezed,Object? postalCode = freezed,Object? shippingMethod = freezed,Object? carrier = freezed,Object? warehouseName = freezed,Object? driverName = freezed,Object? status = freezed,Object? deliveryStatus = freezed,Object? badgeCount = freezed,Object? createdAt = freezed,Object? deliveredAt = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,shippingMethod: freezed == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String?,carrier: freezed == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,deliveryStatus: freezed == deliveryStatus ? _self.deliveryStatus : deliveryStatus // ignore: cast_nullable_to_non_nullable
as String?,badgeCount: freezed == badgeCount ? _self.badgeCount : badgeCount // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderModel].
extension OrderModelPatterns on OrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? senderName,  String? receiverName,  String? customerPhone,  String? city,  String? address,  String? postalCode,  String? shippingMethod,  String? carrier,  String? warehouseName,  String? driverName,  String? status,  String? deliveryStatus,  int? badgeCount,  String? createdAt,  String? deliveredAt,  List<OrderItemModel> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.senderName,_that.receiverName,_that.customerPhone,_that.city,_that.address,_that.postalCode,_that.shippingMethod,_that.carrier,_that.warehouseName,_that.driverName,_that.status,_that.deliveryStatus,_that.badgeCount,_that.createdAt,_that.deliveredAt,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? senderName,  String? receiverName,  String? customerPhone,  String? city,  String? address,  String? postalCode,  String? shippingMethod,  String? carrier,  String? warehouseName,  String? driverName,  String? status,  String? deliveryStatus,  int? badgeCount,  String? createdAt,  String? deliveredAt,  List<OrderItemModel> items)  $default,) {final _that = this;
switch (_that) {
case _OrderModel():
return $default(_that.id,_that.senderName,_that.receiverName,_that.customerPhone,_that.city,_that.address,_that.postalCode,_that.shippingMethod,_that.carrier,_that.warehouseName,_that.driverName,_that.status,_that.deliveryStatus,_that.badgeCount,_that.createdAt,_that.deliveredAt,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? senderName,  String? receiverName,  String? customerPhone,  String? city,  String? address,  String? postalCode,  String? shippingMethod,  String? carrier,  String? warehouseName,  String? driverName,  String? status,  String? deliveryStatus,  int? badgeCount,  String? createdAt,  String? deliveredAt,  List<OrderItemModel> items)?  $default,) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.senderName,_that.receiverName,_that.customerPhone,_that.city,_that.address,_that.postalCode,_that.shippingMethod,_that.carrier,_that.warehouseName,_that.driverName,_that.status,_that.deliveryStatus,_that.badgeCount,_that.createdAt,_that.deliveredAt,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderModel implements OrderModel {
  const _OrderModel({required this.id, this.senderName, this.receiverName, this.customerPhone, this.city, this.address, this.postalCode, this.shippingMethod, this.carrier, this.warehouseName, this.driverName, this.status, this.deliveryStatus, this.badgeCount, this.createdAt, this.deliveredAt, final  List<OrderItemModel> items = const <OrderItemModel>[]}): _items = items;
  factory _OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

@override final  String id;
@override final  String? senderName;
@override final  String? receiverName;
@override final  String? customerPhone;
@override final  String? city;
@override final  String? address;
@override final  String? postalCode;
@override final  String? shippingMethod;
@override final  String? carrier;
@override final  String? warehouseName;
@override final  String? driverName;
@override final  String? status;
@override final  String? deliveryStatus;
@override final  int? badgeCount;
@override final  String? createdAt;
@override final  String? deliveredAt;
 final  List<OrderItemModel> _items;
@override@JsonKey() List<OrderItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderModelCopyWith<_OrderModel> get copyWith => __$OrderModelCopyWithImpl<_OrderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.city, city) || other.city == city)&&(identical(other.address, address) || other.address == address)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryStatus, deliveryStatus) || other.deliveryStatus == deliveryStatus)&&(identical(other.badgeCount, badgeCount) || other.badgeCount == badgeCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderName,receiverName,customerPhone,city,address,postalCode,shippingMethod,carrier,warehouseName,driverName,status,deliveryStatus,badgeCount,createdAt,deliveredAt,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'OrderModel(id: $id, senderName: $senderName, receiverName: $receiverName, customerPhone: $customerPhone, city: $city, address: $address, postalCode: $postalCode, shippingMethod: $shippingMethod, carrier: $carrier, warehouseName: $warehouseName, driverName: $driverName, status: $status, deliveryStatus: $deliveryStatus, badgeCount: $badgeCount, createdAt: $createdAt, deliveredAt: $deliveredAt, items: $items)';
}


}

/// @nodoc
abstract mixin class _$OrderModelCopyWith<$Res> implements $OrderModelCopyWith<$Res> {
  factory _$OrderModelCopyWith(_OrderModel value, $Res Function(_OrderModel) _then) = __$OrderModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? senderName, String? receiverName, String? customerPhone, String? city, String? address, String? postalCode, String? shippingMethod, String? carrier, String? warehouseName, String? driverName, String? status, String? deliveryStatus, int? badgeCount, String? createdAt, String? deliveredAt, List<OrderItemModel> items
});




}
/// @nodoc
class __$OrderModelCopyWithImpl<$Res>
    implements _$OrderModelCopyWith<$Res> {
  __$OrderModelCopyWithImpl(this._self, this._then);

  final _OrderModel _self;
  final $Res Function(_OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderName = freezed,Object? receiverName = freezed,Object? customerPhone = freezed,Object? city = freezed,Object? address = freezed,Object? postalCode = freezed,Object? shippingMethod = freezed,Object? carrier = freezed,Object? warehouseName = freezed,Object? driverName = freezed,Object? status = freezed,Object? deliveryStatus = freezed,Object? badgeCount = freezed,Object? createdAt = freezed,Object? deliveredAt = freezed,Object? items = null,}) {
  return _then(_OrderModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,shippingMethod: freezed == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String?,carrier: freezed == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,deliveryStatus: freezed == deliveryStatus ? _self.deliveryStatus : deliveryStatus // ignore: cast_nullable_to_non_nullable
as String?,badgeCount: freezed == badgeCount ? _self.badgeCount : badgeCount // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemModel>,
  ));
}


}


/// @nodoc
mixin _$OrderItemModel {

 String? get productId; String? get productName; String? get model;@JsonKey(fromJson: _toNum) num get quantity;@JsonKey(fromJson: _toNum) num? get price;@JsonKey(fromJson: _toNum) num? get exchangeRate;
/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemModelCopyWith<OrderItemModel> get copyWith => _$OrderItemModelCopyWithImpl<OrderItemModel>(this as OrderItemModel, _$identity);

  /// Serializes this OrderItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItemModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.model, model) || other.model == model)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,model,quantity,price,exchangeRate);

@override
String toString() {
  return 'OrderItemModel(productId: $productId, productName: $productName, model: $model, quantity: $quantity, price: $price, exchangeRate: $exchangeRate)';
}


}

/// @nodoc
abstract mixin class $OrderItemModelCopyWith<$Res>  {
  factory $OrderItemModelCopyWith(OrderItemModel value, $Res Function(OrderItemModel) _then) = _$OrderItemModelCopyWithImpl;
@useResult
$Res call({
 String? productId, String? productName, String? model,@JsonKey(fromJson: _toNum) num quantity,@JsonKey(fromJson: _toNum) num? price,@JsonKey(fromJson: _toNum) num? exchangeRate
});




}
/// @nodoc
class _$OrderItemModelCopyWithImpl<$Res>
    implements $OrderItemModelCopyWith<$Res> {
  _$OrderItemModelCopyWithImpl(this._self, this._then);

  final OrderItemModel _self;
  final $Res Function(OrderItemModel) _then;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = freezed,Object? productName = freezed,Object? model = freezed,Object? quantity = null,Object? price = freezed,Object? exchangeRate = freezed,}) {
  return _then(_self.copyWith(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as num?,exchangeRate: freezed == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItemModel].
extension OrderItemModelPatterns on OrderItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItemModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? productId,  String? productName,  String? model, @JsonKey(fromJson: _toNum)  num quantity, @JsonKey(fromJson: _toNum)  num? price, @JsonKey(fromJson: _toNum)  num? exchangeRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
return $default(_that.productId,_that.productName,_that.model,_that.quantity,_that.price,_that.exchangeRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? productId,  String? productName,  String? model, @JsonKey(fromJson: _toNum)  num quantity, @JsonKey(fromJson: _toNum)  num? price, @JsonKey(fromJson: _toNum)  num? exchangeRate)  $default,) {final _that = this;
switch (_that) {
case _OrderItemModel():
return $default(_that.productId,_that.productName,_that.model,_that.quantity,_that.price,_that.exchangeRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? productId,  String? productName,  String? model, @JsonKey(fromJson: _toNum)  num quantity, @JsonKey(fromJson: _toNum)  num? price, @JsonKey(fromJson: _toNum)  num? exchangeRate)?  $default,) {final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
return $default(_that.productId,_that.productName,_that.model,_that.quantity,_that.price,_that.exchangeRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItemModel implements OrderItemModel {
  const _OrderItemModel({this.productId, this.productName, this.model, @JsonKey(fromJson: _toNum) this.quantity = 0, @JsonKey(fromJson: _toNum) this.price, @JsonKey(fromJson: _toNum) this.exchangeRate});
  factory _OrderItemModel.fromJson(Map<String, dynamic> json) => _$OrderItemModelFromJson(json);

@override final  String? productId;
@override final  String? productName;
@override final  String? model;
@override@JsonKey(fromJson: _toNum) final  num quantity;
@override@JsonKey(fromJson: _toNum) final  num? price;
@override@JsonKey(fromJson: _toNum) final  num? exchangeRate;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemModelCopyWith<_OrderItemModel> get copyWith => __$OrderItemModelCopyWithImpl<_OrderItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItemModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.model, model) || other.model == model)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,model,quantity,price,exchangeRate);

@override
String toString() {
  return 'OrderItemModel(productId: $productId, productName: $productName, model: $model, quantity: $quantity, price: $price, exchangeRate: $exchangeRate)';
}


}

/// @nodoc
abstract mixin class _$OrderItemModelCopyWith<$Res> implements $OrderItemModelCopyWith<$Res> {
  factory _$OrderItemModelCopyWith(_OrderItemModel value, $Res Function(_OrderItemModel) _then) = __$OrderItemModelCopyWithImpl;
@override @useResult
$Res call({
 String? productId, String? productName, String? model,@JsonKey(fromJson: _toNum) num quantity,@JsonKey(fromJson: _toNum) num? price,@JsonKey(fromJson: _toNum) num? exchangeRate
});




}
/// @nodoc
class __$OrderItemModelCopyWithImpl<$Res>
    implements _$OrderItemModelCopyWith<$Res> {
  __$OrderItemModelCopyWithImpl(this._self, this._then);

  final _OrderItemModel _self;
  final $Res Function(_OrderItemModel) _then;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? productName = freezed,Object? model = freezed,Object? quantity = null,Object? price = freezed,Object? exchangeRate = freezed,}) {
  return _then(_OrderItemModel(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as num?,exchangeRate: freezed == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}


}

// dart format on
