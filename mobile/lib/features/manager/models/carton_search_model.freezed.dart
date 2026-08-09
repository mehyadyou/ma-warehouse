// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carton_search_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartonSearchModel {

 String? get cartonStatus; String? get orderStatus; String? get orderId; List<RelatedOrderModel> get relatedOrders; String? get productName; String? get modelName; String? get warehouseName; String? get serialNumber; String? get qrUuid; String? get createdAt; String? get scannedOutAt; String? get senderName; String? get receiverName; String? get city; String? get driverName; String? get deliveredAt;
/// Create a copy of CartonSearchModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartonSearchModelCopyWith<CartonSearchModel> get copyWith => _$CartonSearchModelCopyWithImpl<CartonSearchModel>(this as CartonSearchModel, _$identity);

  /// Serializes this CartonSearchModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartonSearchModel&&(identical(other.cartonStatus, cartonStatus) || other.cartonStatus == cartonStatus)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&const DeepCollectionEquality().equals(other.relatedOrders, relatedOrders)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.qrUuid, qrUuid) || other.qrUuid == qrUuid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.scannedOutAt, scannedOutAt) || other.scannedOutAt == scannedOutAt)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.city, city) || other.city == city)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cartonStatus,orderStatus,orderId,const DeepCollectionEquality().hash(relatedOrders),productName,modelName,warehouseName,serialNumber,qrUuid,createdAt,scannedOutAt,senderName,receiverName,city,driverName,deliveredAt);

@override
String toString() {
  return 'CartonSearchModel(cartonStatus: $cartonStatus, orderStatus: $orderStatus, orderId: $orderId, relatedOrders: $relatedOrders, productName: $productName, modelName: $modelName, warehouseName: $warehouseName, serialNumber: $serialNumber, qrUuid: $qrUuid, createdAt: $createdAt, scannedOutAt: $scannedOutAt, senderName: $senderName, receiverName: $receiverName, city: $city, driverName: $driverName, deliveredAt: $deliveredAt)';
}


}

/// @nodoc
abstract mixin class $CartonSearchModelCopyWith<$Res>  {
  factory $CartonSearchModelCopyWith(CartonSearchModel value, $Res Function(CartonSearchModel) _then) = _$CartonSearchModelCopyWithImpl;
@useResult
$Res call({
 String? cartonStatus, String? orderStatus, String? orderId, List<RelatedOrderModel> relatedOrders, String? productName, String? modelName, String? warehouseName, String? serialNumber, String? qrUuid, String? createdAt, String? scannedOutAt, String? senderName, String? receiverName, String? city, String? driverName, String? deliveredAt
});




}
/// @nodoc
class _$CartonSearchModelCopyWithImpl<$Res>
    implements $CartonSearchModelCopyWith<$Res> {
  _$CartonSearchModelCopyWithImpl(this._self, this._then);

  final CartonSearchModel _self;
  final $Res Function(CartonSearchModel) _then;

/// Create a copy of CartonSearchModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cartonStatus = freezed,Object? orderStatus = freezed,Object? orderId = freezed,Object? relatedOrders = null,Object? productName = freezed,Object? modelName = freezed,Object? warehouseName = freezed,Object? serialNumber = freezed,Object? qrUuid = freezed,Object? createdAt = freezed,Object? scannedOutAt = freezed,Object? senderName = freezed,Object? receiverName = freezed,Object? city = freezed,Object? driverName = freezed,Object? deliveredAt = freezed,}) {
  return _then(_self.copyWith(
cartonStatus: freezed == cartonStatus ? _self.cartonStatus : cartonStatus // ignore: cast_nullable_to_non_nullable
as String?,orderStatus: freezed == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as String?,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,relatedOrders: null == relatedOrders ? _self.relatedOrders : relatedOrders // ignore: cast_nullable_to_non_nullable
as List<RelatedOrderModel>,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,qrUuid: freezed == qrUuid ? _self.qrUuid : qrUuid // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,scannedOutAt: freezed == scannedOutAt ? _self.scannedOutAt : scannedOutAt // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartonSearchModel].
extension CartonSearchModelPatterns on CartonSearchModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartonSearchModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartonSearchModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartonSearchModel value)  $default,){
final _that = this;
switch (_that) {
case _CartonSearchModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartonSearchModel value)?  $default,){
final _that = this;
switch (_that) {
case _CartonSearchModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? cartonStatus,  String? orderStatus,  String? orderId,  List<RelatedOrderModel> relatedOrders,  String? productName,  String? modelName,  String? warehouseName,  String? serialNumber,  String? qrUuid,  String? createdAt,  String? scannedOutAt,  String? senderName,  String? receiverName,  String? city,  String? driverName,  String? deliveredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartonSearchModel() when $default != null:
return $default(_that.cartonStatus,_that.orderStatus,_that.orderId,_that.relatedOrders,_that.productName,_that.modelName,_that.warehouseName,_that.serialNumber,_that.qrUuid,_that.createdAt,_that.scannedOutAt,_that.senderName,_that.receiverName,_that.city,_that.driverName,_that.deliveredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? cartonStatus,  String? orderStatus,  String? orderId,  List<RelatedOrderModel> relatedOrders,  String? productName,  String? modelName,  String? warehouseName,  String? serialNumber,  String? qrUuid,  String? createdAt,  String? scannedOutAt,  String? senderName,  String? receiverName,  String? city,  String? driverName,  String? deliveredAt)  $default,) {final _that = this;
switch (_that) {
case _CartonSearchModel():
return $default(_that.cartonStatus,_that.orderStatus,_that.orderId,_that.relatedOrders,_that.productName,_that.modelName,_that.warehouseName,_that.serialNumber,_that.qrUuid,_that.createdAt,_that.scannedOutAt,_that.senderName,_that.receiverName,_that.city,_that.driverName,_that.deliveredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? cartonStatus,  String? orderStatus,  String? orderId,  List<RelatedOrderModel> relatedOrders,  String? productName,  String? modelName,  String? warehouseName,  String? serialNumber,  String? qrUuid,  String? createdAt,  String? scannedOutAt,  String? senderName,  String? receiverName,  String? city,  String? driverName,  String? deliveredAt)?  $default,) {final _that = this;
switch (_that) {
case _CartonSearchModel() when $default != null:
return $default(_that.cartonStatus,_that.orderStatus,_that.orderId,_that.relatedOrders,_that.productName,_that.modelName,_that.warehouseName,_that.serialNumber,_that.qrUuid,_that.createdAt,_that.scannedOutAt,_that.senderName,_that.receiverName,_that.city,_that.driverName,_that.deliveredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartonSearchModel implements CartonSearchModel {
  const _CartonSearchModel({this.cartonStatus, this.orderStatus, this.orderId, final  List<RelatedOrderModel> relatedOrders = const <RelatedOrderModel>[], this.productName, this.modelName, this.warehouseName, this.serialNumber, this.qrUuid, this.createdAt, this.scannedOutAt, this.senderName, this.receiverName, this.city, this.driverName, this.deliveredAt}): _relatedOrders = relatedOrders;
  factory _CartonSearchModel.fromJson(Map<String, dynamic> json) => _$CartonSearchModelFromJson(json);

@override final  String? cartonStatus;
@override final  String? orderStatus;
@override final  String? orderId;
 final  List<RelatedOrderModel> _relatedOrders;
@override@JsonKey() List<RelatedOrderModel> get relatedOrders {
  if (_relatedOrders is EqualUnmodifiableListView) return _relatedOrders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relatedOrders);
}

@override final  String? productName;
@override final  String? modelName;
@override final  String? warehouseName;
@override final  String? serialNumber;
@override final  String? qrUuid;
@override final  String? createdAt;
@override final  String? scannedOutAt;
@override final  String? senderName;
@override final  String? receiverName;
@override final  String? city;
@override final  String? driverName;
@override final  String? deliveredAt;

/// Create a copy of CartonSearchModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartonSearchModelCopyWith<_CartonSearchModel> get copyWith => __$CartonSearchModelCopyWithImpl<_CartonSearchModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartonSearchModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartonSearchModel&&(identical(other.cartonStatus, cartonStatus) || other.cartonStatus == cartonStatus)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&const DeepCollectionEquality().equals(other._relatedOrders, _relatedOrders)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.qrUuid, qrUuid) || other.qrUuid == qrUuid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.scannedOutAt, scannedOutAt) || other.scannedOutAt == scannedOutAt)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.city, city) || other.city == city)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cartonStatus,orderStatus,orderId,const DeepCollectionEquality().hash(_relatedOrders),productName,modelName,warehouseName,serialNumber,qrUuid,createdAt,scannedOutAt,senderName,receiverName,city,driverName,deliveredAt);

@override
String toString() {
  return 'CartonSearchModel(cartonStatus: $cartonStatus, orderStatus: $orderStatus, orderId: $orderId, relatedOrders: $relatedOrders, productName: $productName, modelName: $modelName, warehouseName: $warehouseName, serialNumber: $serialNumber, qrUuid: $qrUuid, createdAt: $createdAt, scannedOutAt: $scannedOutAt, senderName: $senderName, receiverName: $receiverName, city: $city, driverName: $driverName, deliveredAt: $deliveredAt)';
}


}

/// @nodoc
abstract mixin class _$CartonSearchModelCopyWith<$Res> implements $CartonSearchModelCopyWith<$Res> {
  factory _$CartonSearchModelCopyWith(_CartonSearchModel value, $Res Function(_CartonSearchModel) _then) = __$CartonSearchModelCopyWithImpl;
@override @useResult
$Res call({
 String? cartonStatus, String? orderStatus, String? orderId, List<RelatedOrderModel> relatedOrders, String? productName, String? modelName, String? warehouseName, String? serialNumber, String? qrUuid, String? createdAt, String? scannedOutAt, String? senderName, String? receiverName, String? city, String? driverName, String? deliveredAt
});




}
/// @nodoc
class __$CartonSearchModelCopyWithImpl<$Res>
    implements _$CartonSearchModelCopyWith<$Res> {
  __$CartonSearchModelCopyWithImpl(this._self, this._then);

  final _CartonSearchModel _self;
  final $Res Function(_CartonSearchModel) _then;

/// Create a copy of CartonSearchModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cartonStatus = freezed,Object? orderStatus = freezed,Object? orderId = freezed,Object? relatedOrders = null,Object? productName = freezed,Object? modelName = freezed,Object? warehouseName = freezed,Object? serialNumber = freezed,Object? qrUuid = freezed,Object? createdAt = freezed,Object? scannedOutAt = freezed,Object? senderName = freezed,Object? receiverName = freezed,Object? city = freezed,Object? driverName = freezed,Object? deliveredAt = freezed,}) {
  return _then(_CartonSearchModel(
cartonStatus: freezed == cartonStatus ? _self.cartonStatus : cartonStatus // ignore: cast_nullable_to_non_nullable
as String?,orderStatus: freezed == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as String?,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,relatedOrders: null == relatedOrders ? _self._relatedOrders : relatedOrders // ignore: cast_nullable_to_non_nullable
as List<RelatedOrderModel>,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,qrUuid: freezed == qrUuid ? _self.qrUuid : qrUuid // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,scannedOutAt: freezed == scannedOutAt ? _self.scannedOutAt : scannedOutAt // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RelatedOrderModel {

 CartonOrderRefModel get order; num get quantity;
/// Create a copy of RelatedOrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelatedOrderModelCopyWith<RelatedOrderModel> get copyWith => _$RelatedOrderModelCopyWithImpl<RelatedOrderModel>(this as RelatedOrderModel, _$identity);

  /// Serializes this RelatedOrderModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelatedOrderModel&&(identical(other.order, order) || other.order == order)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,order,quantity);

@override
String toString() {
  return 'RelatedOrderModel(order: $order, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $RelatedOrderModelCopyWith<$Res>  {
  factory $RelatedOrderModelCopyWith(RelatedOrderModel value, $Res Function(RelatedOrderModel) _then) = _$RelatedOrderModelCopyWithImpl;
@useResult
$Res call({
 CartonOrderRefModel order, num quantity
});


$CartonOrderRefModelCopyWith<$Res> get order;

}
/// @nodoc
class _$RelatedOrderModelCopyWithImpl<$Res>
    implements $RelatedOrderModelCopyWith<$Res> {
  _$RelatedOrderModelCopyWithImpl(this._self, this._then);

  final RelatedOrderModel _self;
  final $Res Function(RelatedOrderModel) _then;

/// Create a copy of RelatedOrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as CartonOrderRefModel,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,
  ));
}
/// Create a copy of RelatedOrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartonOrderRefModelCopyWith<$Res> get order {
  
  return $CartonOrderRefModelCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}


/// Adds pattern-matching-related methods to [RelatedOrderModel].
extension RelatedOrderModelPatterns on RelatedOrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RelatedOrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RelatedOrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RelatedOrderModel value)  $default,){
final _that = this;
switch (_that) {
case _RelatedOrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RelatedOrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _RelatedOrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CartonOrderRefModel order,  num quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RelatedOrderModel() when $default != null:
return $default(_that.order,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CartonOrderRefModel order,  num quantity)  $default,) {final _that = this;
switch (_that) {
case _RelatedOrderModel():
return $default(_that.order,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CartonOrderRefModel order,  num quantity)?  $default,) {final _that = this;
switch (_that) {
case _RelatedOrderModel() when $default != null:
return $default(_that.order,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RelatedOrderModel implements RelatedOrderModel {
  const _RelatedOrderModel({this.order = const CartonOrderRefModel(), this.quantity = 0});
  factory _RelatedOrderModel.fromJson(Map<String, dynamic> json) => _$RelatedOrderModelFromJson(json);

@override@JsonKey() final  CartonOrderRefModel order;
@override@JsonKey() final  num quantity;

/// Create a copy of RelatedOrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelatedOrderModelCopyWith<_RelatedOrderModel> get copyWith => __$RelatedOrderModelCopyWithImpl<_RelatedOrderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RelatedOrderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RelatedOrderModel&&(identical(other.order, order) || other.order == order)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,order,quantity);

@override
String toString() {
  return 'RelatedOrderModel(order: $order, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$RelatedOrderModelCopyWith<$Res> implements $RelatedOrderModelCopyWith<$Res> {
  factory _$RelatedOrderModelCopyWith(_RelatedOrderModel value, $Res Function(_RelatedOrderModel) _then) = __$RelatedOrderModelCopyWithImpl;
@override @useResult
$Res call({
 CartonOrderRefModel order, num quantity
});


@override $CartonOrderRefModelCopyWith<$Res> get order;

}
/// @nodoc
class __$RelatedOrderModelCopyWithImpl<$Res>
    implements _$RelatedOrderModelCopyWith<$Res> {
  __$RelatedOrderModelCopyWithImpl(this._self, this._then);

  final _RelatedOrderModel _self;
  final $Res Function(_RelatedOrderModel) _then;

/// Create a copy of RelatedOrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = null,Object? quantity = null,}) {
  return _then(_RelatedOrderModel(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as CartonOrderRefModel,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

/// Create a copy of RelatedOrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartonOrderRefModelCopyWith<$Res> get order {
  
  return $CartonOrderRefModelCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}


/// @nodoc
mixin _$CartonOrderRefModel {

 String? get status; String? get senderName; String? get receiverName; String? get createdAt;
/// Create a copy of CartonOrderRefModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartonOrderRefModelCopyWith<CartonOrderRefModel> get copyWith => _$CartonOrderRefModelCopyWithImpl<CartonOrderRefModel>(this as CartonOrderRefModel, _$identity);

  /// Serializes this CartonOrderRefModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartonOrderRefModel&&(identical(other.status, status) || other.status == status)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,senderName,receiverName,createdAt);

@override
String toString() {
  return 'CartonOrderRefModel(status: $status, senderName: $senderName, receiverName: $receiverName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CartonOrderRefModelCopyWith<$Res>  {
  factory $CartonOrderRefModelCopyWith(CartonOrderRefModel value, $Res Function(CartonOrderRefModel) _then) = _$CartonOrderRefModelCopyWithImpl;
@useResult
$Res call({
 String? status, String? senderName, String? receiverName, String? createdAt
});




}
/// @nodoc
class _$CartonOrderRefModelCopyWithImpl<$Res>
    implements $CartonOrderRefModelCopyWith<$Res> {
  _$CartonOrderRefModelCopyWithImpl(this._self, this._then);

  final CartonOrderRefModel _self;
  final $Res Function(CartonOrderRefModel) _then;

/// Create a copy of CartonOrderRefModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? senderName = freezed,Object? receiverName = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartonOrderRefModel].
extension CartonOrderRefModelPatterns on CartonOrderRefModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartonOrderRefModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartonOrderRefModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartonOrderRefModel value)  $default,){
final _that = this;
switch (_that) {
case _CartonOrderRefModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartonOrderRefModel value)?  $default,){
final _that = this;
switch (_that) {
case _CartonOrderRefModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? status,  String? senderName,  String? receiverName,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartonOrderRefModel() when $default != null:
return $default(_that.status,_that.senderName,_that.receiverName,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? status,  String? senderName,  String? receiverName,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _CartonOrderRefModel():
return $default(_that.status,_that.senderName,_that.receiverName,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? status,  String? senderName,  String? receiverName,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CartonOrderRefModel() when $default != null:
return $default(_that.status,_that.senderName,_that.receiverName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartonOrderRefModel implements CartonOrderRefModel {
  const _CartonOrderRefModel({this.status, this.senderName, this.receiverName, this.createdAt});
  factory _CartonOrderRefModel.fromJson(Map<String, dynamic> json) => _$CartonOrderRefModelFromJson(json);

@override final  String? status;
@override final  String? senderName;
@override final  String? receiverName;
@override final  String? createdAt;

/// Create a copy of CartonOrderRefModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartonOrderRefModelCopyWith<_CartonOrderRefModel> get copyWith => __$CartonOrderRefModelCopyWithImpl<_CartonOrderRefModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartonOrderRefModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartonOrderRefModel&&(identical(other.status, status) || other.status == status)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,senderName,receiverName,createdAt);

@override
String toString() {
  return 'CartonOrderRefModel(status: $status, senderName: $senderName, receiverName: $receiverName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CartonOrderRefModelCopyWith<$Res> implements $CartonOrderRefModelCopyWith<$Res> {
  factory _$CartonOrderRefModelCopyWith(_CartonOrderRefModel value, $Res Function(_CartonOrderRefModel) _then) = __$CartonOrderRefModelCopyWithImpl;
@override @useResult
$Res call({
 String? status, String? senderName, String? receiverName, String? createdAt
});




}
/// @nodoc
class __$CartonOrderRefModelCopyWithImpl<$Res>
    implements _$CartonOrderRefModelCopyWith<$Res> {
  __$CartonOrderRefModelCopyWithImpl(this._self, this._then);

  final _CartonOrderRefModel _self;
  final $Res Function(_CartonOrderRefModel) _then;

/// Create a copy of CartonOrderRefModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? senderName = freezed,Object? receiverName = freezed,Object? createdAt = freezed,}) {
  return _then(_CartonOrderRefModel(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
