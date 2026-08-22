// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keeper_order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KeeperOrderModel {

 String get id; int get orderNumber; String get status; String get createdByName; String get createdAt; String get warehouseName; String get shippingMethod; String get senderName; String get receiverName; String get carrier; String get city; String get postalCode; String get address; String get customerPhone; List<KeeperOrderItemModel> get items;
/// Create a copy of KeeperOrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperOrderModelCopyWith<KeeperOrderModel> get copyWith => _$KeeperOrderModelCopyWithImpl<KeeperOrderModel>(this as KeeperOrderModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperOrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.address, address) || other.address == address)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,status,createdByName,createdAt,warehouseName,shippingMethod,senderName,receiverName,carrier,city,postalCode,address,customerPhone,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'KeeperOrderModel(id: $id, orderNumber: $orderNumber, status: $status, createdByName: $createdByName, createdAt: $createdAt, warehouseName: $warehouseName, shippingMethod: $shippingMethod, senderName: $senderName, receiverName: $receiverName, carrier: $carrier, city: $city, postalCode: $postalCode, address: $address, customerPhone: $customerPhone, items: $items)';
}


}

/// @nodoc
abstract mixin class $KeeperOrderModelCopyWith<$Res>  {
  factory $KeeperOrderModelCopyWith(KeeperOrderModel value, $Res Function(KeeperOrderModel) _then) = _$KeeperOrderModelCopyWithImpl;
@useResult
$Res call({
 String id, int orderNumber, String status, String createdByName, String createdAt, String warehouseName, String shippingMethod, String senderName, String receiverName, String carrier, String city, String postalCode, String address, String customerPhone, List<KeeperOrderItemModel> items
});




}
/// @nodoc
class _$KeeperOrderModelCopyWithImpl<$Res>
    implements $KeeperOrderModelCopyWith<$Res> {
  _$KeeperOrderModelCopyWithImpl(this._self, this._then);

  final KeeperOrderModel _self;
  final $Res Function(KeeperOrderModel) _then;

/// Create a copy of KeeperOrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? createdByName = null,Object? createdAt = null,Object? warehouseName = null,Object? shippingMethod = null,Object? senderName = null,Object? receiverName = null,Object? carrier = null,Object? city = null,Object? postalCode = null,Object? address = null,Object? customerPhone = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdByName: null == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,warehouseName: null == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String,shippingMethod: null == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,carrier: null == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<KeeperOrderItemModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperOrderModel].
extension KeeperOrderModelPatterns on KeeperOrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperOrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperOrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperOrderModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperOrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperOrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperOrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int orderNumber,  String status,  String createdByName,  String createdAt,  String warehouseName,  String shippingMethod,  String senderName,  String receiverName,  String carrier,  String city,  String postalCode,  String address,  String customerPhone,  List<KeeperOrderItemModel> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperOrderModel() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.createdByName,_that.createdAt,_that.warehouseName,_that.shippingMethod,_that.senderName,_that.receiverName,_that.carrier,_that.city,_that.postalCode,_that.address,_that.customerPhone,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int orderNumber,  String status,  String createdByName,  String createdAt,  String warehouseName,  String shippingMethod,  String senderName,  String receiverName,  String carrier,  String city,  String postalCode,  String address,  String customerPhone,  List<KeeperOrderItemModel> items)  $default,) {final _that = this;
switch (_that) {
case _KeeperOrderModel():
return $default(_that.id,_that.orderNumber,_that.status,_that.createdByName,_that.createdAt,_that.warehouseName,_that.shippingMethod,_that.senderName,_that.receiverName,_that.carrier,_that.city,_that.postalCode,_that.address,_that.customerPhone,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int orderNumber,  String status,  String createdByName,  String createdAt,  String warehouseName,  String shippingMethod,  String senderName,  String receiverName,  String carrier,  String city,  String postalCode,  String address,  String customerPhone,  List<KeeperOrderItemModel> items)?  $default,) {final _that = this;
switch (_that) {
case _KeeperOrderModel() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.createdByName,_that.createdAt,_that.warehouseName,_that.shippingMethod,_that.senderName,_that.receiverName,_that.carrier,_that.city,_that.postalCode,_that.address,_that.customerPhone,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _KeeperOrderModel implements KeeperOrderModel {
  const _KeeperOrderModel({this.id = '', this.orderNumber = 0, this.status = '', this.createdByName = '', this.createdAt = '', this.warehouseName = '', this.shippingMethod = '', this.senderName = '', this.receiverName = '', this.carrier = '', this.city = '', this.postalCode = '', this.address = '', this.customerPhone = '', final  List<KeeperOrderItemModel> items = const <KeeperOrderItemModel>[]}): _items = items;
  

@override@JsonKey() final  String id;
@override@JsonKey() final  int orderNumber;
@override@JsonKey() final  String status;
@override@JsonKey() final  String createdByName;
@override@JsonKey() final  String createdAt;
@override@JsonKey() final  String warehouseName;
@override@JsonKey() final  String shippingMethod;
@override@JsonKey() final  String senderName;
@override@JsonKey() final  String receiverName;
@override@JsonKey() final  String carrier;
@override@JsonKey() final  String city;
@override@JsonKey() final  String postalCode;
@override@JsonKey() final  String address;
@override@JsonKey() final  String customerPhone;
 final  List<KeeperOrderItemModel> _items;
@override@JsonKey() List<KeeperOrderItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of KeeperOrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperOrderModelCopyWith<_KeeperOrderModel> get copyWith => __$KeeperOrderModelCopyWithImpl<_KeeperOrderModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperOrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.address, address) || other.address == address)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,status,createdByName,createdAt,warehouseName,shippingMethod,senderName,receiverName,carrier,city,postalCode,address,customerPhone,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'KeeperOrderModel(id: $id, orderNumber: $orderNumber, status: $status, createdByName: $createdByName, createdAt: $createdAt, warehouseName: $warehouseName, shippingMethod: $shippingMethod, senderName: $senderName, receiverName: $receiverName, carrier: $carrier, city: $city, postalCode: $postalCode, address: $address, customerPhone: $customerPhone, items: $items)';
}


}

/// @nodoc
abstract mixin class _$KeeperOrderModelCopyWith<$Res> implements $KeeperOrderModelCopyWith<$Res> {
  factory _$KeeperOrderModelCopyWith(_KeeperOrderModel value, $Res Function(_KeeperOrderModel) _then) = __$KeeperOrderModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int orderNumber, String status, String createdByName, String createdAt, String warehouseName, String shippingMethod, String senderName, String receiverName, String carrier, String city, String postalCode, String address, String customerPhone, List<KeeperOrderItemModel> items
});




}
/// @nodoc
class __$KeeperOrderModelCopyWithImpl<$Res>
    implements _$KeeperOrderModelCopyWith<$Res> {
  __$KeeperOrderModelCopyWithImpl(this._self, this._then);

  final _KeeperOrderModel _self;
  final $Res Function(_KeeperOrderModel) _then;

/// Create a copy of KeeperOrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? createdByName = null,Object? createdAt = null,Object? warehouseName = null,Object? shippingMethod = null,Object? senderName = null,Object? receiverName = null,Object? carrier = null,Object? city = null,Object? postalCode = null,Object? address = null,Object? customerPhone = null,Object? items = null,}) {
  return _then(_KeeperOrderModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdByName: null == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,warehouseName: null == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String,shippingMethod: null == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,carrier: null == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<KeeperOrderItemModel>,
  ));
}


}

/// @nodoc
mixin _$KeeperOrderItemModel {

 String get productName; String get model; int get quantity; double? get price; double? get exchangeRate;
/// Create a copy of KeeperOrderItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperOrderItemModelCopyWith<KeeperOrderItemModel> get copyWith => _$KeeperOrderItemModelCopyWithImpl<KeeperOrderItemModel>(this as KeeperOrderItemModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperOrderItemModel&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.model, model) || other.model == model)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate));
}


@override
int get hashCode => Object.hash(runtimeType,productName,model,quantity,price,exchangeRate);

@override
String toString() {
  return 'KeeperOrderItemModel(productName: $productName, model: $model, quantity: $quantity, price: $price, exchangeRate: $exchangeRate)';
}


}

/// @nodoc
abstract mixin class $KeeperOrderItemModelCopyWith<$Res>  {
  factory $KeeperOrderItemModelCopyWith(KeeperOrderItemModel value, $Res Function(KeeperOrderItemModel) _then) = _$KeeperOrderItemModelCopyWithImpl;
@useResult
$Res call({
 String productName, String model, int quantity, double? price, double? exchangeRate
});




}
/// @nodoc
class _$KeeperOrderItemModelCopyWithImpl<$Res>
    implements $KeeperOrderItemModelCopyWith<$Res> {
  _$KeeperOrderItemModelCopyWithImpl(this._self, this._then);

  final KeeperOrderItemModel _self;
  final $Res Function(KeeperOrderItemModel) _then;

/// Create a copy of KeeperOrderItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productName = null,Object? model = null,Object? quantity = null,Object? price = freezed,Object? exchangeRate = freezed,}) {
  return _then(_self.copyWith(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,exchangeRate: freezed == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperOrderItemModel].
extension KeeperOrderItemModelPatterns on KeeperOrderItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperOrderItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperOrderItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperOrderItemModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperOrderItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperOrderItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperOrderItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productName,  String model,  int quantity,  double? price,  double? exchangeRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperOrderItemModel() when $default != null:
return $default(_that.productName,_that.model,_that.quantity,_that.price,_that.exchangeRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productName,  String model,  int quantity,  double? price,  double? exchangeRate)  $default,) {final _that = this;
switch (_that) {
case _KeeperOrderItemModel():
return $default(_that.productName,_that.model,_that.quantity,_that.price,_that.exchangeRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productName,  String model,  int quantity,  double? price,  double? exchangeRate)?  $default,) {final _that = this;
switch (_that) {
case _KeeperOrderItemModel() when $default != null:
return $default(_that.productName,_that.model,_that.quantity,_that.price,_that.exchangeRate);case _:
  return null;

}
}

}

/// @nodoc


class _KeeperOrderItemModel implements KeeperOrderItemModel {
  const _KeeperOrderItemModel({this.productName = '', this.model = '', this.quantity = 0, this.price, this.exchangeRate});
  

@override@JsonKey() final  String productName;
@override@JsonKey() final  String model;
@override@JsonKey() final  int quantity;
@override final  double? price;
@override final  double? exchangeRate;

/// Create a copy of KeeperOrderItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperOrderItemModelCopyWith<_KeeperOrderItemModel> get copyWith => __$KeeperOrderItemModelCopyWithImpl<_KeeperOrderItemModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperOrderItemModel&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.model, model) || other.model == model)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate));
}


@override
int get hashCode => Object.hash(runtimeType,productName,model,quantity,price,exchangeRate);

@override
String toString() {
  return 'KeeperOrderItemModel(productName: $productName, model: $model, quantity: $quantity, price: $price, exchangeRate: $exchangeRate)';
}


}

/// @nodoc
abstract mixin class _$KeeperOrderItemModelCopyWith<$Res> implements $KeeperOrderItemModelCopyWith<$Res> {
  factory _$KeeperOrderItemModelCopyWith(_KeeperOrderItemModel value, $Res Function(_KeeperOrderItemModel) _then) = __$KeeperOrderItemModelCopyWithImpl;
@override @useResult
$Res call({
 String productName, String model, int quantity, double? price, double? exchangeRate
});




}
/// @nodoc
class __$KeeperOrderItemModelCopyWithImpl<$Res>
    implements _$KeeperOrderItemModelCopyWith<$Res> {
  __$KeeperOrderItemModelCopyWithImpl(this._self, this._then);

  final _KeeperOrderItemModel _self;
  final $Res Function(_KeeperOrderItemModel) _then;

/// Create a copy of KeeperOrderItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productName = null,Object? model = null,Object? quantity = null,Object? price = freezed,Object? exchangeRate = freezed,}) {
  return _then(_KeeperOrderItemModel(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,exchangeRate: freezed == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
