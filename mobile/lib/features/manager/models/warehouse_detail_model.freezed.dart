// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warehouse_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WarehouseDetailModel {

 WarehouseStatsModel get stats; String? get keeperName; List<WarehouseProductStockModel> get products;
/// Create a copy of WarehouseDetailModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseDetailModelCopyWith<WarehouseDetailModel> get copyWith => _$WarehouseDetailModelCopyWithImpl<WarehouseDetailModel>(this as WarehouseDetailModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarehouseDetailModel&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.keeperName, keeperName) || other.keeperName == keeperName)&&const DeepCollectionEquality().equals(other.products, products));
}


@override
int get hashCode => Object.hash(runtimeType,stats,keeperName,const DeepCollectionEquality().hash(products));

@override
String toString() {
  return 'WarehouseDetailModel(stats: $stats, keeperName: $keeperName, products: $products)';
}


}

/// @nodoc
abstract mixin class $WarehouseDetailModelCopyWith<$Res>  {
  factory $WarehouseDetailModelCopyWith(WarehouseDetailModel value, $Res Function(WarehouseDetailModel) _then) = _$WarehouseDetailModelCopyWithImpl;
@useResult
$Res call({
 WarehouseStatsModel stats, String? keeperName, List<WarehouseProductStockModel> products
});


$WarehouseStatsModelCopyWith<$Res> get stats;

}
/// @nodoc
class _$WarehouseDetailModelCopyWithImpl<$Res>
    implements $WarehouseDetailModelCopyWith<$Res> {
  _$WarehouseDetailModelCopyWithImpl(this._self, this._then);

  final WarehouseDetailModel _self;
  final $Res Function(WarehouseDetailModel) _then;

/// Create a copy of WarehouseDetailModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stats = null,Object? keeperName = freezed,Object? products = null,}) {
  return _then(_self.copyWith(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as WarehouseStatsModel,keeperName: freezed == keeperName ? _self.keeperName : keeperName // ignore: cast_nullable_to_non_nullable
as String?,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<WarehouseProductStockModel>,
  ));
}
/// Create a copy of WarehouseDetailModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WarehouseStatsModelCopyWith<$Res> get stats {
  
  return $WarehouseStatsModelCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [WarehouseDetailModel].
extension WarehouseDetailModelPatterns on WarehouseDetailModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarehouseDetailModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarehouseDetailModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarehouseDetailModel value)  $default,){
final _that = this;
switch (_that) {
case _WarehouseDetailModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarehouseDetailModel value)?  $default,){
final _that = this;
switch (_that) {
case _WarehouseDetailModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WarehouseStatsModel stats,  String? keeperName,  List<WarehouseProductStockModel> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarehouseDetailModel() when $default != null:
return $default(_that.stats,_that.keeperName,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WarehouseStatsModel stats,  String? keeperName,  List<WarehouseProductStockModel> products)  $default,) {final _that = this;
switch (_that) {
case _WarehouseDetailModel():
return $default(_that.stats,_that.keeperName,_that.products);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WarehouseStatsModel stats,  String? keeperName,  List<WarehouseProductStockModel> products)?  $default,) {final _that = this;
switch (_that) {
case _WarehouseDetailModel() when $default != null:
return $default(_that.stats,_that.keeperName,_that.products);case _:
  return null;

}
}

}

/// @nodoc


class _WarehouseDetailModel implements WarehouseDetailModel {
  const _WarehouseDetailModel({this.stats = const WarehouseStatsModel(), this.keeperName, final  List<WarehouseProductStockModel> products = const <WarehouseProductStockModel>[]}): _products = products;
  

@override@JsonKey() final  WarehouseStatsModel stats;
@override final  String? keeperName;
 final  List<WarehouseProductStockModel> _products;
@override@JsonKey() List<WarehouseProductStockModel> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of WarehouseDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseDetailModelCopyWith<_WarehouseDetailModel> get copyWith => __$WarehouseDetailModelCopyWithImpl<_WarehouseDetailModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarehouseDetailModel&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.keeperName, keeperName) || other.keeperName == keeperName)&&const DeepCollectionEquality().equals(other._products, _products));
}


@override
int get hashCode => Object.hash(runtimeType,stats,keeperName,const DeepCollectionEquality().hash(_products));

@override
String toString() {
  return 'WarehouseDetailModel(stats: $stats, keeperName: $keeperName, products: $products)';
}


}

/// @nodoc
abstract mixin class _$WarehouseDetailModelCopyWith<$Res> implements $WarehouseDetailModelCopyWith<$Res> {
  factory _$WarehouseDetailModelCopyWith(_WarehouseDetailModel value, $Res Function(_WarehouseDetailModel) _then) = __$WarehouseDetailModelCopyWithImpl;
@override @useResult
$Res call({
 WarehouseStatsModel stats, String? keeperName, List<WarehouseProductStockModel> products
});


@override $WarehouseStatsModelCopyWith<$Res> get stats;

}
/// @nodoc
class __$WarehouseDetailModelCopyWithImpl<$Res>
    implements _$WarehouseDetailModelCopyWith<$Res> {
  __$WarehouseDetailModelCopyWithImpl(this._self, this._then);

  final _WarehouseDetailModel _self;
  final $Res Function(_WarehouseDetailModel) _then;

/// Create a copy of WarehouseDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stats = null,Object? keeperName = freezed,Object? products = null,}) {
  return _then(_WarehouseDetailModel(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as WarehouseStatsModel,keeperName: freezed == keeperName ? _self.keeperName : keeperName // ignore: cast_nullable_to_non_nullable
as String?,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<WarehouseProductStockModel>,
  ));
}

/// Create a copy of WarehouseDetailModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WarehouseStatsModelCopyWith<$Res> get stats {
  
  return $WarehouseStatsModelCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// @nodoc
mixin _$WarehouseStatsModel {

 num get transactionCount; num get productCount; num get inCount; num get outCount; num get inUnits; num get outUnits; num get returnedUnits; num get totalUnits; num get totalCartons; num get orderCount; num get activeOrderCount;
/// Create a copy of WarehouseStatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseStatsModelCopyWith<WarehouseStatsModel> get copyWith => _$WarehouseStatsModelCopyWithImpl<WarehouseStatsModel>(this as WarehouseStatsModel, _$identity);

  /// Serializes this WarehouseStatsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarehouseStatsModel&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.productCount, productCount) || other.productCount == productCount)&&(identical(other.inCount, inCount) || other.inCount == inCount)&&(identical(other.outCount, outCount) || other.outCount == outCount)&&(identical(other.inUnits, inUnits) || other.inUnits == inUnits)&&(identical(other.outUnits, outUnits) || other.outUnits == outUnits)&&(identical(other.returnedUnits, returnedUnits) || other.returnedUnits == returnedUnits)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.totalCartons, totalCartons) || other.totalCartons == totalCartons)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount)&&(identical(other.activeOrderCount, activeOrderCount) || other.activeOrderCount == activeOrderCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactionCount,productCount,inCount,outCount,inUnits,outUnits,returnedUnits,totalUnits,totalCartons,orderCount,activeOrderCount);

@override
String toString() {
  return 'WarehouseStatsModel(transactionCount: $transactionCount, productCount: $productCount, inCount: $inCount, outCount: $outCount, inUnits: $inUnits, outUnits: $outUnits, returnedUnits: $returnedUnits, totalUnits: $totalUnits, totalCartons: $totalCartons, orderCount: $orderCount, activeOrderCount: $activeOrderCount)';
}


}

/// @nodoc
abstract mixin class $WarehouseStatsModelCopyWith<$Res>  {
  factory $WarehouseStatsModelCopyWith(WarehouseStatsModel value, $Res Function(WarehouseStatsModel) _then) = _$WarehouseStatsModelCopyWithImpl;
@useResult
$Res call({
 num transactionCount, num productCount, num inCount, num outCount, num inUnits, num outUnits, num returnedUnits, num totalUnits, num totalCartons, num orderCount, num activeOrderCount
});




}
/// @nodoc
class _$WarehouseStatsModelCopyWithImpl<$Res>
    implements $WarehouseStatsModelCopyWith<$Res> {
  _$WarehouseStatsModelCopyWithImpl(this._self, this._then);

  final WarehouseStatsModel _self;
  final $Res Function(WarehouseStatsModel) _then;

/// Create a copy of WarehouseStatsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionCount = null,Object? productCount = null,Object? inCount = null,Object? outCount = null,Object? inUnits = null,Object? outUnits = null,Object? returnedUnits = null,Object? totalUnits = null,Object? totalCartons = null,Object? orderCount = null,Object? activeOrderCount = null,}) {
  return _then(_self.copyWith(
transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as num,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as num,inCount: null == inCount ? _self.inCount : inCount // ignore: cast_nullable_to_non_nullable
as num,outCount: null == outCount ? _self.outCount : outCount // ignore: cast_nullable_to_non_nullable
as num,inUnits: null == inUnits ? _self.inUnits : inUnits // ignore: cast_nullable_to_non_nullable
as num,outUnits: null == outUnits ? _self.outUnits : outUnits // ignore: cast_nullable_to_non_nullable
as num,returnedUnits: null == returnedUnits ? _self.returnedUnits : returnedUnits // ignore: cast_nullable_to_non_nullable
as num,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as num,totalCartons: null == totalCartons ? _self.totalCartons : totalCartons // ignore: cast_nullable_to_non_nullable
as num,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as num,activeOrderCount: null == activeOrderCount ? _self.activeOrderCount : activeOrderCount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [WarehouseStatsModel].
extension WarehouseStatsModelPatterns on WarehouseStatsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarehouseStatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarehouseStatsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarehouseStatsModel value)  $default,){
final _that = this;
switch (_that) {
case _WarehouseStatsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarehouseStatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _WarehouseStatsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num transactionCount,  num productCount,  num inCount,  num outCount,  num inUnits,  num outUnits,  num returnedUnits,  num totalUnits,  num totalCartons,  num orderCount,  num activeOrderCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarehouseStatsModel() when $default != null:
return $default(_that.transactionCount,_that.productCount,_that.inCount,_that.outCount,_that.inUnits,_that.outUnits,_that.returnedUnits,_that.totalUnits,_that.totalCartons,_that.orderCount,_that.activeOrderCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num transactionCount,  num productCount,  num inCount,  num outCount,  num inUnits,  num outUnits,  num returnedUnits,  num totalUnits,  num totalCartons,  num orderCount,  num activeOrderCount)  $default,) {final _that = this;
switch (_that) {
case _WarehouseStatsModel():
return $default(_that.transactionCount,_that.productCount,_that.inCount,_that.outCount,_that.inUnits,_that.outUnits,_that.returnedUnits,_that.totalUnits,_that.totalCartons,_that.orderCount,_that.activeOrderCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num transactionCount,  num productCount,  num inCount,  num outCount,  num inUnits,  num outUnits,  num returnedUnits,  num totalUnits,  num totalCartons,  num orderCount,  num activeOrderCount)?  $default,) {final _that = this;
switch (_that) {
case _WarehouseStatsModel() when $default != null:
return $default(_that.transactionCount,_that.productCount,_that.inCount,_that.outCount,_that.inUnits,_that.outUnits,_that.returnedUnits,_that.totalUnits,_that.totalCartons,_that.orderCount,_that.activeOrderCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WarehouseStatsModel implements WarehouseStatsModel {
  const _WarehouseStatsModel({this.transactionCount = 0, this.productCount = 0, this.inCount = 0, this.outCount = 0, this.inUnits = 0, this.outUnits = 0, this.returnedUnits = 0, this.totalUnits = 0, this.totalCartons = 0, this.orderCount = 0, this.activeOrderCount = 0});
  factory _WarehouseStatsModel.fromJson(Map<String, dynamic> json) => _$WarehouseStatsModelFromJson(json);

@override@JsonKey() final  num transactionCount;
@override@JsonKey() final  num productCount;
@override@JsonKey() final  num inCount;
@override@JsonKey() final  num outCount;
@override@JsonKey() final  num inUnits;
@override@JsonKey() final  num outUnits;
@override@JsonKey() final  num returnedUnits;
@override@JsonKey() final  num totalUnits;
@override@JsonKey() final  num totalCartons;
@override@JsonKey() final  num orderCount;
@override@JsonKey() final  num activeOrderCount;

/// Create a copy of WarehouseStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseStatsModelCopyWith<_WarehouseStatsModel> get copyWith => __$WarehouseStatsModelCopyWithImpl<_WarehouseStatsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WarehouseStatsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarehouseStatsModel&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.productCount, productCount) || other.productCount == productCount)&&(identical(other.inCount, inCount) || other.inCount == inCount)&&(identical(other.outCount, outCount) || other.outCount == outCount)&&(identical(other.inUnits, inUnits) || other.inUnits == inUnits)&&(identical(other.outUnits, outUnits) || other.outUnits == outUnits)&&(identical(other.returnedUnits, returnedUnits) || other.returnedUnits == returnedUnits)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.totalCartons, totalCartons) || other.totalCartons == totalCartons)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount)&&(identical(other.activeOrderCount, activeOrderCount) || other.activeOrderCount == activeOrderCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactionCount,productCount,inCount,outCount,inUnits,outUnits,returnedUnits,totalUnits,totalCartons,orderCount,activeOrderCount);

@override
String toString() {
  return 'WarehouseStatsModel(transactionCount: $transactionCount, productCount: $productCount, inCount: $inCount, outCount: $outCount, inUnits: $inUnits, outUnits: $outUnits, returnedUnits: $returnedUnits, totalUnits: $totalUnits, totalCartons: $totalCartons, orderCount: $orderCount, activeOrderCount: $activeOrderCount)';
}


}

/// @nodoc
abstract mixin class _$WarehouseStatsModelCopyWith<$Res> implements $WarehouseStatsModelCopyWith<$Res> {
  factory _$WarehouseStatsModelCopyWith(_WarehouseStatsModel value, $Res Function(_WarehouseStatsModel) _then) = __$WarehouseStatsModelCopyWithImpl;
@override @useResult
$Res call({
 num transactionCount, num productCount, num inCount, num outCount, num inUnits, num outUnits, num returnedUnits, num totalUnits, num totalCartons, num orderCount, num activeOrderCount
});




}
/// @nodoc
class __$WarehouseStatsModelCopyWithImpl<$Res>
    implements _$WarehouseStatsModelCopyWith<$Res> {
  __$WarehouseStatsModelCopyWithImpl(this._self, this._then);

  final _WarehouseStatsModel _self;
  final $Res Function(_WarehouseStatsModel) _then;

/// Create a copy of WarehouseStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionCount = null,Object? productCount = null,Object? inCount = null,Object? outCount = null,Object? inUnits = null,Object? outUnits = null,Object? returnedUnits = null,Object? totalUnits = null,Object? totalCartons = null,Object? orderCount = null,Object? activeOrderCount = null,}) {
  return _then(_WarehouseStatsModel(
transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as num,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as num,inCount: null == inCount ? _self.inCount : inCount // ignore: cast_nullable_to_non_nullable
as num,outCount: null == outCount ? _self.outCount : outCount // ignore: cast_nullable_to_non_nullable
as num,inUnits: null == inUnits ? _self.inUnits : inUnits // ignore: cast_nullable_to_non_nullable
as num,outUnits: null == outUnits ? _self.outUnits : outUnits // ignore: cast_nullable_to_non_nullable
as num,returnedUnits: null == returnedUnits ? _self.returnedUnits : returnedUnits // ignore: cast_nullable_to_non_nullable
as num,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as num,totalCartons: null == totalCartons ? _self.totalCartons : totalCartons // ignore: cast_nullable_to_non_nullable
as num,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as num,activeOrderCount: null == activeOrderCount ? _self.activeOrderCount : activeOrderCount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$WarehouseProductStockModel {

 String? get name; String? get unit; num get totalCount; num get cartonCount; num get individualCount; num get modelCount; List<WarehouseModelStockModel> get models;
/// Create a copy of WarehouseProductStockModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseProductStockModelCopyWith<WarehouseProductStockModel> get copyWith => _$WarehouseProductStockModelCopyWithImpl<WarehouseProductStockModel>(this as WarehouseProductStockModel, _$identity);

  /// Serializes this WarehouseProductStockModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarehouseProductStockModel&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&(identical(other.individualCount, individualCount) || other.individualCount == individualCount)&&(identical(other.modelCount, modelCount) || other.modelCount == modelCount)&&const DeepCollectionEquality().equals(other.models, models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,unit,totalCount,cartonCount,individualCount,modelCount,const DeepCollectionEquality().hash(models));

@override
String toString() {
  return 'WarehouseProductStockModel(name: $name, unit: $unit, totalCount: $totalCount, cartonCount: $cartonCount, individualCount: $individualCount, modelCount: $modelCount, models: $models)';
}


}

/// @nodoc
abstract mixin class $WarehouseProductStockModelCopyWith<$Res>  {
  factory $WarehouseProductStockModelCopyWith(WarehouseProductStockModel value, $Res Function(WarehouseProductStockModel) _then) = _$WarehouseProductStockModelCopyWithImpl;
@useResult
$Res call({
 String? name, String? unit, num totalCount, num cartonCount, num individualCount, num modelCount, List<WarehouseModelStockModel> models
});




}
/// @nodoc
class _$WarehouseProductStockModelCopyWithImpl<$Res>
    implements $WarehouseProductStockModelCopyWith<$Res> {
  _$WarehouseProductStockModelCopyWithImpl(this._self, this._then);

  final WarehouseProductStockModel _self;
  final $Res Function(WarehouseProductStockModel) _then;

/// Create a copy of WarehouseProductStockModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? unit = freezed,Object? totalCount = null,Object? cartonCount = null,Object? individualCount = null,Object? modelCount = null,Object? models = null,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as num,individualCount: null == individualCount ? _self.individualCount : individualCount // ignore: cast_nullable_to_non_nullable
as num,modelCount: null == modelCount ? _self.modelCount : modelCount // ignore: cast_nullable_to_non_nullable
as num,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<WarehouseModelStockModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [WarehouseProductStockModel].
extension WarehouseProductStockModelPatterns on WarehouseProductStockModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarehouseProductStockModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarehouseProductStockModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarehouseProductStockModel value)  $default,){
final _that = this;
switch (_that) {
case _WarehouseProductStockModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarehouseProductStockModel value)?  $default,){
final _that = this;
switch (_that) {
case _WarehouseProductStockModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? unit,  num totalCount,  num cartonCount,  num individualCount,  num modelCount,  List<WarehouseModelStockModel> models)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarehouseProductStockModel() when $default != null:
return $default(_that.name,_that.unit,_that.totalCount,_that.cartonCount,_that.individualCount,_that.modelCount,_that.models);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? unit,  num totalCount,  num cartonCount,  num individualCount,  num modelCount,  List<WarehouseModelStockModel> models)  $default,) {final _that = this;
switch (_that) {
case _WarehouseProductStockModel():
return $default(_that.name,_that.unit,_that.totalCount,_that.cartonCount,_that.individualCount,_that.modelCount,_that.models);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? unit,  num totalCount,  num cartonCount,  num individualCount,  num modelCount,  List<WarehouseModelStockModel> models)?  $default,) {final _that = this;
switch (_that) {
case _WarehouseProductStockModel() when $default != null:
return $default(_that.name,_that.unit,_that.totalCount,_that.cartonCount,_that.individualCount,_that.modelCount,_that.models);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WarehouseProductStockModel implements WarehouseProductStockModel {
  const _WarehouseProductStockModel({this.name, this.unit, this.totalCount = 0, this.cartonCount = 0, this.individualCount = 0, this.modelCount = 0, final  List<WarehouseModelStockModel> models = const <WarehouseModelStockModel>[]}): _models = models;
  factory _WarehouseProductStockModel.fromJson(Map<String, dynamic> json) => _$WarehouseProductStockModelFromJson(json);

@override final  String? name;
@override final  String? unit;
@override@JsonKey() final  num totalCount;
@override@JsonKey() final  num cartonCount;
@override@JsonKey() final  num individualCount;
@override@JsonKey() final  num modelCount;
 final  List<WarehouseModelStockModel> _models;
@override@JsonKey() List<WarehouseModelStockModel> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}


/// Create a copy of WarehouseProductStockModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseProductStockModelCopyWith<_WarehouseProductStockModel> get copyWith => __$WarehouseProductStockModelCopyWithImpl<_WarehouseProductStockModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WarehouseProductStockModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarehouseProductStockModel&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&(identical(other.individualCount, individualCount) || other.individualCount == individualCount)&&(identical(other.modelCount, modelCount) || other.modelCount == modelCount)&&const DeepCollectionEquality().equals(other._models, _models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,unit,totalCount,cartonCount,individualCount,modelCount,const DeepCollectionEquality().hash(_models));

@override
String toString() {
  return 'WarehouseProductStockModel(name: $name, unit: $unit, totalCount: $totalCount, cartonCount: $cartonCount, individualCount: $individualCount, modelCount: $modelCount, models: $models)';
}


}

/// @nodoc
abstract mixin class _$WarehouseProductStockModelCopyWith<$Res> implements $WarehouseProductStockModelCopyWith<$Res> {
  factory _$WarehouseProductStockModelCopyWith(_WarehouseProductStockModel value, $Res Function(_WarehouseProductStockModel) _then) = __$WarehouseProductStockModelCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? unit, num totalCount, num cartonCount, num individualCount, num modelCount, List<WarehouseModelStockModel> models
});




}
/// @nodoc
class __$WarehouseProductStockModelCopyWithImpl<$Res>
    implements _$WarehouseProductStockModelCopyWith<$Res> {
  __$WarehouseProductStockModelCopyWithImpl(this._self, this._then);

  final _WarehouseProductStockModel _self;
  final $Res Function(_WarehouseProductStockModel) _then;

/// Create a copy of WarehouseProductStockModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? unit = freezed,Object? totalCount = null,Object? cartonCount = null,Object? individualCount = null,Object? modelCount = null,Object? models = null,}) {
  return _then(_WarehouseProductStockModel(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as num,individualCount: null == individualCount ? _self.individualCount : individualCount // ignore: cast_nullable_to_non_nullable
as num,modelCount: null == modelCount ? _self.modelCount : modelCount // ignore: cast_nullable_to_non_nullable
as num,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<WarehouseModelStockModel>,
  ));
}


}


/// @nodoc
mixin _$WarehouseModelStockModel {

 String? get name; num get totalCount; num get cartonCount; num get individualCount;
/// Create a copy of WarehouseModelStockModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseModelStockModelCopyWith<WarehouseModelStockModel> get copyWith => _$WarehouseModelStockModelCopyWithImpl<WarehouseModelStockModel>(this as WarehouseModelStockModel, _$identity);

  /// Serializes this WarehouseModelStockModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarehouseModelStockModel&&(identical(other.name, name) || other.name == name)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&(identical(other.individualCount, individualCount) || other.individualCount == individualCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,totalCount,cartonCount,individualCount);

@override
String toString() {
  return 'WarehouseModelStockModel(name: $name, totalCount: $totalCount, cartonCount: $cartonCount, individualCount: $individualCount)';
}


}

/// @nodoc
abstract mixin class $WarehouseModelStockModelCopyWith<$Res>  {
  factory $WarehouseModelStockModelCopyWith(WarehouseModelStockModel value, $Res Function(WarehouseModelStockModel) _then) = _$WarehouseModelStockModelCopyWithImpl;
@useResult
$Res call({
 String? name, num totalCount, num cartonCount, num individualCount
});




}
/// @nodoc
class _$WarehouseModelStockModelCopyWithImpl<$Res>
    implements $WarehouseModelStockModelCopyWith<$Res> {
  _$WarehouseModelStockModelCopyWithImpl(this._self, this._then);

  final WarehouseModelStockModel _self;
  final $Res Function(WarehouseModelStockModel) _then;

/// Create a copy of WarehouseModelStockModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? totalCount = null,Object? cartonCount = null,Object? individualCount = null,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as num,individualCount: null == individualCount ? _self.individualCount : individualCount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [WarehouseModelStockModel].
extension WarehouseModelStockModelPatterns on WarehouseModelStockModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarehouseModelStockModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarehouseModelStockModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarehouseModelStockModel value)  $default,){
final _that = this;
switch (_that) {
case _WarehouseModelStockModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarehouseModelStockModel value)?  $default,){
final _that = this;
switch (_that) {
case _WarehouseModelStockModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  num totalCount,  num cartonCount,  num individualCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarehouseModelStockModel() when $default != null:
return $default(_that.name,_that.totalCount,_that.cartonCount,_that.individualCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  num totalCount,  num cartonCount,  num individualCount)  $default,) {final _that = this;
switch (_that) {
case _WarehouseModelStockModel():
return $default(_that.name,_that.totalCount,_that.cartonCount,_that.individualCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  num totalCount,  num cartonCount,  num individualCount)?  $default,) {final _that = this;
switch (_that) {
case _WarehouseModelStockModel() when $default != null:
return $default(_that.name,_that.totalCount,_that.cartonCount,_that.individualCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WarehouseModelStockModel implements WarehouseModelStockModel {
  const _WarehouseModelStockModel({this.name, this.totalCount = 0, this.cartonCount = 0, this.individualCount = 0});
  factory _WarehouseModelStockModel.fromJson(Map<String, dynamic> json) => _$WarehouseModelStockModelFromJson(json);

@override final  String? name;
@override@JsonKey() final  num totalCount;
@override@JsonKey() final  num cartonCount;
@override@JsonKey() final  num individualCount;

/// Create a copy of WarehouseModelStockModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseModelStockModelCopyWith<_WarehouseModelStockModel> get copyWith => __$WarehouseModelStockModelCopyWithImpl<_WarehouseModelStockModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WarehouseModelStockModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarehouseModelStockModel&&(identical(other.name, name) || other.name == name)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&(identical(other.individualCount, individualCount) || other.individualCount == individualCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,totalCount,cartonCount,individualCount);

@override
String toString() {
  return 'WarehouseModelStockModel(name: $name, totalCount: $totalCount, cartonCount: $cartonCount, individualCount: $individualCount)';
}


}

/// @nodoc
abstract mixin class _$WarehouseModelStockModelCopyWith<$Res> implements $WarehouseModelStockModelCopyWith<$Res> {
  factory _$WarehouseModelStockModelCopyWith(_WarehouseModelStockModel value, $Res Function(_WarehouseModelStockModel) _then) = __$WarehouseModelStockModelCopyWithImpl;
@override @useResult
$Res call({
 String? name, num totalCount, num cartonCount, num individualCount
});




}
/// @nodoc
class __$WarehouseModelStockModelCopyWithImpl<$Res>
    implements _$WarehouseModelStockModelCopyWith<$Res> {
  __$WarehouseModelStockModelCopyWithImpl(this._self, this._then);

  final _WarehouseModelStockModel _self;
  final $Res Function(_WarehouseModelStockModel) _then;

/// Create a copy of WarehouseModelStockModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? totalCount = null,Object? cartonCount = null,Object? individualCount = null,}) {
  return _then(_WarehouseModelStockModel(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as num,individualCount: null == individualCount ? _self.individualCount : individualCount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
