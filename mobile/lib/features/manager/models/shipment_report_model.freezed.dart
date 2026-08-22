// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipment_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShipmentReportModel {

 num get totalShipments; num get totalUnits; num get totalWarehouses; ShipmentOrderModel? get lastShipment; List<ShipmentWarehouseModel> get warehouses;
/// Create a copy of ShipmentReportModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipmentReportModelCopyWith<ShipmentReportModel> get copyWith => _$ShipmentReportModelCopyWithImpl<ShipmentReportModel>(this as ShipmentReportModel, _$identity);

  /// Serializes this ShipmentReportModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShipmentReportModel&&(identical(other.totalShipments, totalShipments) || other.totalShipments == totalShipments)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.totalWarehouses, totalWarehouses) || other.totalWarehouses == totalWarehouses)&&(identical(other.lastShipment, lastShipment) || other.lastShipment == lastShipment)&&const DeepCollectionEquality().equals(other.warehouses, warehouses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalShipments,totalUnits,totalWarehouses,lastShipment,const DeepCollectionEquality().hash(warehouses));

@override
String toString() {
  return 'ShipmentReportModel(totalShipments: $totalShipments, totalUnits: $totalUnits, totalWarehouses: $totalWarehouses, lastShipment: $lastShipment, warehouses: $warehouses)';
}


}

/// @nodoc
abstract mixin class $ShipmentReportModelCopyWith<$Res>  {
  factory $ShipmentReportModelCopyWith(ShipmentReportModel value, $Res Function(ShipmentReportModel) _then) = _$ShipmentReportModelCopyWithImpl;
@useResult
$Res call({
 num totalShipments, num totalUnits, num totalWarehouses, ShipmentOrderModel? lastShipment, List<ShipmentWarehouseModel> warehouses
});


$ShipmentOrderModelCopyWith<$Res>? get lastShipment;

}
/// @nodoc
class _$ShipmentReportModelCopyWithImpl<$Res>
    implements $ShipmentReportModelCopyWith<$Res> {
  _$ShipmentReportModelCopyWithImpl(this._self, this._then);

  final ShipmentReportModel _self;
  final $Res Function(ShipmentReportModel) _then;

/// Create a copy of ShipmentReportModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalShipments = null,Object? totalUnits = null,Object? totalWarehouses = null,Object? lastShipment = freezed,Object? warehouses = null,}) {
  return _then(_self.copyWith(
totalShipments: null == totalShipments ? _self.totalShipments : totalShipments // ignore: cast_nullable_to_non_nullable
as num,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as num,totalWarehouses: null == totalWarehouses ? _self.totalWarehouses : totalWarehouses // ignore: cast_nullable_to_non_nullable
as num,lastShipment: freezed == lastShipment ? _self.lastShipment : lastShipment // ignore: cast_nullable_to_non_nullable
as ShipmentOrderModel?,warehouses: null == warehouses ? _self.warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<ShipmentWarehouseModel>,
  ));
}
/// Create a copy of ShipmentReportModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShipmentOrderModelCopyWith<$Res>? get lastShipment {
    if (_self.lastShipment == null) {
    return null;
  }

  return $ShipmentOrderModelCopyWith<$Res>(_self.lastShipment!, (value) {
    return _then(_self.copyWith(lastShipment: value));
  });
}
}


/// Adds pattern-matching-related methods to [ShipmentReportModel].
extension ShipmentReportModelPatterns on ShipmentReportModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShipmentReportModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShipmentReportModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShipmentReportModel value)  $default,){
final _that = this;
switch (_that) {
case _ShipmentReportModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShipmentReportModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShipmentReportModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num totalShipments,  num totalUnits,  num totalWarehouses,  ShipmentOrderModel? lastShipment,  List<ShipmentWarehouseModel> warehouses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShipmentReportModel() when $default != null:
return $default(_that.totalShipments,_that.totalUnits,_that.totalWarehouses,_that.lastShipment,_that.warehouses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num totalShipments,  num totalUnits,  num totalWarehouses,  ShipmentOrderModel? lastShipment,  List<ShipmentWarehouseModel> warehouses)  $default,) {final _that = this;
switch (_that) {
case _ShipmentReportModel():
return $default(_that.totalShipments,_that.totalUnits,_that.totalWarehouses,_that.lastShipment,_that.warehouses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num totalShipments,  num totalUnits,  num totalWarehouses,  ShipmentOrderModel? lastShipment,  List<ShipmentWarehouseModel> warehouses)?  $default,) {final _that = this;
switch (_that) {
case _ShipmentReportModel() when $default != null:
return $default(_that.totalShipments,_that.totalUnits,_that.totalWarehouses,_that.lastShipment,_that.warehouses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShipmentReportModel implements ShipmentReportModel {
  const _ShipmentReportModel({this.totalShipments = 0, this.totalUnits = 0, this.totalWarehouses = 0, this.lastShipment, final  List<ShipmentWarehouseModel> warehouses = const []}): _warehouses = warehouses;
  factory _ShipmentReportModel.fromJson(Map<String, dynamic> json) => _$ShipmentReportModelFromJson(json);

@override@JsonKey() final  num totalShipments;
@override@JsonKey() final  num totalUnits;
@override@JsonKey() final  num totalWarehouses;
@override final  ShipmentOrderModel? lastShipment;
 final  List<ShipmentWarehouseModel> _warehouses;
@override@JsonKey() List<ShipmentWarehouseModel> get warehouses {
  if (_warehouses is EqualUnmodifiableListView) return _warehouses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warehouses);
}


/// Create a copy of ShipmentReportModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipmentReportModelCopyWith<_ShipmentReportModel> get copyWith => __$ShipmentReportModelCopyWithImpl<_ShipmentReportModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShipmentReportModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShipmentReportModel&&(identical(other.totalShipments, totalShipments) || other.totalShipments == totalShipments)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.totalWarehouses, totalWarehouses) || other.totalWarehouses == totalWarehouses)&&(identical(other.lastShipment, lastShipment) || other.lastShipment == lastShipment)&&const DeepCollectionEquality().equals(other._warehouses, _warehouses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalShipments,totalUnits,totalWarehouses,lastShipment,const DeepCollectionEquality().hash(_warehouses));

@override
String toString() {
  return 'ShipmentReportModel(totalShipments: $totalShipments, totalUnits: $totalUnits, totalWarehouses: $totalWarehouses, lastShipment: $lastShipment, warehouses: $warehouses)';
}


}

/// @nodoc
abstract mixin class _$ShipmentReportModelCopyWith<$Res> implements $ShipmentReportModelCopyWith<$Res> {
  factory _$ShipmentReportModelCopyWith(_ShipmentReportModel value, $Res Function(_ShipmentReportModel) _then) = __$ShipmentReportModelCopyWithImpl;
@override @useResult
$Res call({
 num totalShipments, num totalUnits, num totalWarehouses, ShipmentOrderModel? lastShipment, List<ShipmentWarehouseModel> warehouses
});


@override $ShipmentOrderModelCopyWith<$Res>? get lastShipment;

}
/// @nodoc
class __$ShipmentReportModelCopyWithImpl<$Res>
    implements _$ShipmentReportModelCopyWith<$Res> {
  __$ShipmentReportModelCopyWithImpl(this._self, this._then);

  final _ShipmentReportModel _self;
  final $Res Function(_ShipmentReportModel) _then;

/// Create a copy of ShipmentReportModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalShipments = null,Object? totalUnits = null,Object? totalWarehouses = null,Object? lastShipment = freezed,Object? warehouses = null,}) {
  return _then(_ShipmentReportModel(
totalShipments: null == totalShipments ? _self.totalShipments : totalShipments // ignore: cast_nullable_to_non_nullable
as num,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as num,totalWarehouses: null == totalWarehouses ? _self.totalWarehouses : totalWarehouses // ignore: cast_nullable_to_non_nullable
as num,lastShipment: freezed == lastShipment ? _self.lastShipment : lastShipment // ignore: cast_nullable_to_non_nullable
as ShipmentOrderModel?,warehouses: null == warehouses ? _self._warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<ShipmentWarehouseModel>,
  ));
}

/// Create a copy of ShipmentReportModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShipmentOrderModelCopyWith<$Res>? get lastShipment {
    if (_self.lastShipment == null) {
    return null;
  }

  return $ShipmentOrderModelCopyWith<$Res>(_self.lastShipment!, (value) {
    return _then(_self.copyWith(lastShipment: value));
  });
}
}


/// @nodoc
mixin _$ShipmentWarehouseModel {

 String? get warehouseId; String? get warehouseName; num get totalCount; String? get lastShipmentAt; List<ShipmentDayModel> get daily;
/// Create a copy of ShipmentWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipmentWarehouseModelCopyWith<ShipmentWarehouseModel> get copyWith => _$ShipmentWarehouseModelCopyWithImpl<ShipmentWarehouseModel>(this as ShipmentWarehouseModel, _$identity);

  /// Serializes this ShipmentWarehouseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShipmentWarehouseModel&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.lastShipmentAt, lastShipmentAt) || other.lastShipmentAt == lastShipmentAt)&&const DeepCollectionEquality().equals(other.daily, daily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseId,warehouseName,totalCount,lastShipmentAt,const DeepCollectionEquality().hash(daily));

@override
String toString() {
  return 'ShipmentWarehouseModel(warehouseId: $warehouseId, warehouseName: $warehouseName, totalCount: $totalCount, lastShipmentAt: $lastShipmentAt, daily: $daily)';
}


}

/// @nodoc
abstract mixin class $ShipmentWarehouseModelCopyWith<$Res>  {
  factory $ShipmentWarehouseModelCopyWith(ShipmentWarehouseModel value, $Res Function(ShipmentWarehouseModel) _then) = _$ShipmentWarehouseModelCopyWithImpl;
@useResult
$Res call({
 String? warehouseId, String? warehouseName, num totalCount, String? lastShipmentAt, List<ShipmentDayModel> daily
});




}
/// @nodoc
class _$ShipmentWarehouseModelCopyWithImpl<$Res>
    implements $ShipmentWarehouseModelCopyWith<$Res> {
  _$ShipmentWarehouseModelCopyWithImpl(this._self, this._then);

  final ShipmentWarehouseModel _self;
  final $Res Function(ShipmentWarehouseModel) _then;

/// Create a copy of ShipmentWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warehouseId = freezed,Object? warehouseName = freezed,Object? totalCount = null,Object? lastShipmentAt = freezed,Object? daily = null,}) {
  return _then(_self.copyWith(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,lastShipmentAt: freezed == lastShipmentAt ? _self.lastShipmentAt : lastShipmentAt // ignore: cast_nullable_to_non_nullable
as String?,daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as List<ShipmentDayModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShipmentWarehouseModel].
extension ShipmentWarehouseModelPatterns on ShipmentWarehouseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShipmentWarehouseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShipmentWarehouseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShipmentWarehouseModel value)  $default,){
final _that = this;
switch (_that) {
case _ShipmentWarehouseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShipmentWarehouseModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShipmentWarehouseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? warehouseId,  String? warehouseName,  num totalCount,  String? lastShipmentAt,  List<ShipmentDayModel> daily)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShipmentWarehouseModel() when $default != null:
return $default(_that.warehouseId,_that.warehouseName,_that.totalCount,_that.lastShipmentAt,_that.daily);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? warehouseId,  String? warehouseName,  num totalCount,  String? lastShipmentAt,  List<ShipmentDayModel> daily)  $default,) {final _that = this;
switch (_that) {
case _ShipmentWarehouseModel():
return $default(_that.warehouseId,_that.warehouseName,_that.totalCount,_that.lastShipmentAt,_that.daily);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? warehouseId,  String? warehouseName,  num totalCount,  String? lastShipmentAt,  List<ShipmentDayModel> daily)?  $default,) {final _that = this;
switch (_that) {
case _ShipmentWarehouseModel() when $default != null:
return $default(_that.warehouseId,_that.warehouseName,_that.totalCount,_that.lastShipmentAt,_that.daily);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShipmentWarehouseModel implements ShipmentWarehouseModel {
  const _ShipmentWarehouseModel({this.warehouseId, this.warehouseName, this.totalCount = 0, this.lastShipmentAt, final  List<ShipmentDayModel> daily = const []}): _daily = daily;
  factory _ShipmentWarehouseModel.fromJson(Map<String, dynamic> json) => _$ShipmentWarehouseModelFromJson(json);

@override final  String? warehouseId;
@override final  String? warehouseName;
@override@JsonKey() final  num totalCount;
@override final  String? lastShipmentAt;
 final  List<ShipmentDayModel> _daily;
@override@JsonKey() List<ShipmentDayModel> get daily {
  if (_daily is EqualUnmodifiableListView) return _daily;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daily);
}


/// Create a copy of ShipmentWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipmentWarehouseModelCopyWith<_ShipmentWarehouseModel> get copyWith => __$ShipmentWarehouseModelCopyWithImpl<_ShipmentWarehouseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShipmentWarehouseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShipmentWarehouseModel&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.lastShipmentAt, lastShipmentAt) || other.lastShipmentAt == lastShipmentAt)&&const DeepCollectionEquality().equals(other._daily, _daily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseId,warehouseName,totalCount,lastShipmentAt,const DeepCollectionEquality().hash(_daily));

@override
String toString() {
  return 'ShipmentWarehouseModel(warehouseId: $warehouseId, warehouseName: $warehouseName, totalCount: $totalCount, lastShipmentAt: $lastShipmentAt, daily: $daily)';
}


}

/// @nodoc
abstract mixin class _$ShipmentWarehouseModelCopyWith<$Res> implements $ShipmentWarehouseModelCopyWith<$Res> {
  factory _$ShipmentWarehouseModelCopyWith(_ShipmentWarehouseModel value, $Res Function(_ShipmentWarehouseModel) _then) = __$ShipmentWarehouseModelCopyWithImpl;
@override @useResult
$Res call({
 String? warehouseId, String? warehouseName, num totalCount, String? lastShipmentAt, List<ShipmentDayModel> daily
});




}
/// @nodoc
class __$ShipmentWarehouseModelCopyWithImpl<$Res>
    implements _$ShipmentWarehouseModelCopyWith<$Res> {
  __$ShipmentWarehouseModelCopyWithImpl(this._self, this._then);

  final _ShipmentWarehouseModel _self;
  final $Res Function(_ShipmentWarehouseModel) _then;

/// Create a copy of ShipmentWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warehouseId = freezed,Object? warehouseName = freezed,Object? totalCount = null,Object? lastShipmentAt = freezed,Object? daily = null,}) {
  return _then(_ShipmentWarehouseModel(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,lastShipmentAt: freezed == lastShipmentAt ? _self.lastShipmentAt : lastShipmentAt // ignore: cast_nullable_to_non_nullable
as String?,daily: null == daily ? _self._daily : daily // ignore: cast_nullable_to_non_nullable
as List<ShipmentDayModel>,
  ));
}


}


/// @nodoc
mixin _$ShipmentDayModel {

 String? get date; num get count; List<ShipmentOrderModel> get items;
/// Create a copy of ShipmentDayModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipmentDayModelCopyWith<ShipmentDayModel> get copyWith => _$ShipmentDayModelCopyWithImpl<ShipmentDayModel>(this as ShipmentDayModel, _$identity);

  /// Serializes this ShipmentDayModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShipmentDayModel&&(identical(other.date, date) || other.date == date)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,count,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ShipmentDayModel(date: $date, count: $count, items: $items)';
}


}

/// @nodoc
abstract mixin class $ShipmentDayModelCopyWith<$Res>  {
  factory $ShipmentDayModelCopyWith(ShipmentDayModel value, $Res Function(ShipmentDayModel) _then) = _$ShipmentDayModelCopyWithImpl;
@useResult
$Res call({
 String? date, num count, List<ShipmentOrderModel> items
});




}
/// @nodoc
class _$ShipmentDayModelCopyWithImpl<$Res>
    implements $ShipmentDayModelCopyWith<$Res> {
  _$ShipmentDayModelCopyWithImpl(this._self, this._then);

  final ShipmentDayModel _self;
  final $Res Function(ShipmentDayModel) _then;

/// Create a copy of ShipmentDayModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = freezed,Object? count = null,Object? items = null,}) {
  return _then(_self.copyWith(
date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ShipmentOrderModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShipmentDayModel].
extension ShipmentDayModelPatterns on ShipmentDayModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShipmentDayModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShipmentDayModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShipmentDayModel value)  $default,){
final _that = this;
switch (_that) {
case _ShipmentDayModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShipmentDayModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShipmentDayModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? date,  num count,  List<ShipmentOrderModel> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShipmentDayModel() when $default != null:
return $default(_that.date,_that.count,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? date,  num count,  List<ShipmentOrderModel> items)  $default,) {final _that = this;
switch (_that) {
case _ShipmentDayModel():
return $default(_that.date,_that.count,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? date,  num count,  List<ShipmentOrderModel> items)?  $default,) {final _that = this;
switch (_that) {
case _ShipmentDayModel() when $default != null:
return $default(_that.date,_that.count,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShipmentDayModel implements ShipmentDayModel {
  const _ShipmentDayModel({this.date, this.count = 0, final  List<ShipmentOrderModel> items = const []}): _items = items;
  factory _ShipmentDayModel.fromJson(Map<String, dynamic> json) => _$ShipmentDayModelFromJson(json);

@override final  String? date;
@override@JsonKey() final  num count;
 final  List<ShipmentOrderModel> _items;
@override@JsonKey() List<ShipmentOrderModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ShipmentDayModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipmentDayModelCopyWith<_ShipmentDayModel> get copyWith => __$ShipmentDayModelCopyWithImpl<_ShipmentDayModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShipmentDayModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShipmentDayModel&&(identical(other.date, date) || other.date == date)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,count,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ShipmentDayModel(date: $date, count: $count, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ShipmentDayModelCopyWith<$Res> implements $ShipmentDayModelCopyWith<$Res> {
  factory _$ShipmentDayModelCopyWith(_ShipmentDayModel value, $Res Function(_ShipmentDayModel) _then) = __$ShipmentDayModelCopyWithImpl;
@override @useResult
$Res call({
 String? date, num count, List<ShipmentOrderModel> items
});




}
/// @nodoc
class __$ShipmentDayModelCopyWithImpl<$Res>
    implements _$ShipmentDayModelCopyWith<$Res> {
  __$ShipmentDayModelCopyWithImpl(this._self, this._then);

  final _ShipmentDayModel _self;
  final $Res Function(_ShipmentDayModel) _then;

/// Create a copy of ShipmentDayModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = freezed,Object? count = null,Object? items = null,}) {
  return _then(_ShipmentDayModel(
date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ShipmentOrderModel>,
  ));
}


}


/// @nodoc
mixin _$ShipmentOrderModel {

 String? get orderId; String? get warehouseId; String? get warehouseName; String? get status; String? get city; String? get receiverName; String? get senderName; String? get carrier; String? get createdByName; String? get createdAt; num get totalUnits; List<ShipmentItemModel> get items;
/// Create a copy of ShipmentOrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipmentOrderModelCopyWith<ShipmentOrderModel> get copyWith => _$ShipmentOrderModelCopyWithImpl<ShipmentOrderModel>(this as ShipmentOrderModel, _$identity);

  /// Serializes this ShipmentOrderModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShipmentOrderModel&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.status, status) || other.status == status)&&(identical(other.city, city) || other.city == city)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,warehouseId,warehouseName,status,city,receiverName,senderName,carrier,createdByName,createdAt,totalUnits,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ShipmentOrderModel(orderId: $orderId, warehouseId: $warehouseId, warehouseName: $warehouseName, status: $status, city: $city, receiverName: $receiverName, senderName: $senderName, carrier: $carrier, createdByName: $createdByName, createdAt: $createdAt, totalUnits: $totalUnits, items: $items)';
}


}

/// @nodoc
abstract mixin class $ShipmentOrderModelCopyWith<$Res>  {
  factory $ShipmentOrderModelCopyWith(ShipmentOrderModel value, $Res Function(ShipmentOrderModel) _then) = _$ShipmentOrderModelCopyWithImpl;
@useResult
$Res call({
 String? orderId, String? warehouseId, String? warehouseName, String? status, String? city, String? receiverName, String? senderName, String? carrier, String? createdByName, String? createdAt, num totalUnits, List<ShipmentItemModel> items
});




}
/// @nodoc
class _$ShipmentOrderModelCopyWithImpl<$Res>
    implements $ShipmentOrderModelCopyWith<$Res> {
  _$ShipmentOrderModelCopyWithImpl(this._self, this._then);

  final ShipmentOrderModel _self;
  final $Res Function(ShipmentOrderModel) _then;

/// Create a copy of ShipmentOrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = freezed,Object? warehouseId = freezed,Object? warehouseName = freezed,Object? status = freezed,Object? city = freezed,Object? receiverName = freezed,Object? senderName = freezed,Object? carrier = freezed,Object? createdByName = freezed,Object? createdAt = freezed,Object? totalUnits = null,Object? items = null,}) {
  return _then(_self.copyWith(
orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,carrier: freezed == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as num,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ShipmentItemModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShipmentOrderModel].
extension ShipmentOrderModelPatterns on ShipmentOrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShipmentOrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShipmentOrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShipmentOrderModel value)  $default,){
final _that = this;
switch (_that) {
case _ShipmentOrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShipmentOrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShipmentOrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? orderId,  String? warehouseId,  String? warehouseName,  String? status,  String? city,  String? receiverName,  String? senderName,  String? carrier,  String? createdByName,  String? createdAt,  num totalUnits,  List<ShipmentItemModel> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShipmentOrderModel() when $default != null:
return $default(_that.orderId,_that.warehouseId,_that.warehouseName,_that.status,_that.city,_that.receiverName,_that.senderName,_that.carrier,_that.createdByName,_that.createdAt,_that.totalUnits,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? orderId,  String? warehouseId,  String? warehouseName,  String? status,  String? city,  String? receiverName,  String? senderName,  String? carrier,  String? createdByName,  String? createdAt,  num totalUnits,  List<ShipmentItemModel> items)  $default,) {final _that = this;
switch (_that) {
case _ShipmentOrderModel():
return $default(_that.orderId,_that.warehouseId,_that.warehouseName,_that.status,_that.city,_that.receiverName,_that.senderName,_that.carrier,_that.createdByName,_that.createdAt,_that.totalUnits,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? orderId,  String? warehouseId,  String? warehouseName,  String? status,  String? city,  String? receiverName,  String? senderName,  String? carrier,  String? createdByName,  String? createdAt,  num totalUnits,  List<ShipmentItemModel> items)?  $default,) {final _that = this;
switch (_that) {
case _ShipmentOrderModel() when $default != null:
return $default(_that.orderId,_that.warehouseId,_that.warehouseName,_that.status,_that.city,_that.receiverName,_that.senderName,_that.carrier,_that.createdByName,_that.createdAt,_that.totalUnits,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShipmentOrderModel implements ShipmentOrderModel {
  const _ShipmentOrderModel({this.orderId, this.warehouseId, this.warehouseName, this.status, this.city, this.receiverName, this.senderName, this.carrier, this.createdByName, this.createdAt, this.totalUnits = 0, final  List<ShipmentItemModel> items = const []}): _items = items;
  factory _ShipmentOrderModel.fromJson(Map<String, dynamic> json) => _$ShipmentOrderModelFromJson(json);

@override final  String? orderId;
@override final  String? warehouseId;
@override final  String? warehouseName;
@override final  String? status;
@override final  String? city;
@override final  String? receiverName;
@override final  String? senderName;
@override final  String? carrier;
@override final  String? createdByName;
@override final  String? createdAt;
@override@JsonKey() final  num totalUnits;
 final  List<ShipmentItemModel> _items;
@override@JsonKey() List<ShipmentItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ShipmentOrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipmentOrderModelCopyWith<_ShipmentOrderModel> get copyWith => __$ShipmentOrderModelCopyWithImpl<_ShipmentOrderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShipmentOrderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShipmentOrderModel&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.status, status) || other.status == status)&&(identical(other.city, city) || other.city == city)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,warehouseId,warehouseName,status,city,receiverName,senderName,carrier,createdByName,createdAt,totalUnits,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ShipmentOrderModel(orderId: $orderId, warehouseId: $warehouseId, warehouseName: $warehouseName, status: $status, city: $city, receiverName: $receiverName, senderName: $senderName, carrier: $carrier, createdByName: $createdByName, createdAt: $createdAt, totalUnits: $totalUnits, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ShipmentOrderModelCopyWith<$Res> implements $ShipmentOrderModelCopyWith<$Res> {
  factory _$ShipmentOrderModelCopyWith(_ShipmentOrderModel value, $Res Function(_ShipmentOrderModel) _then) = __$ShipmentOrderModelCopyWithImpl;
@override @useResult
$Res call({
 String? orderId, String? warehouseId, String? warehouseName, String? status, String? city, String? receiverName, String? senderName, String? carrier, String? createdByName, String? createdAt, num totalUnits, List<ShipmentItemModel> items
});




}
/// @nodoc
class __$ShipmentOrderModelCopyWithImpl<$Res>
    implements _$ShipmentOrderModelCopyWith<$Res> {
  __$ShipmentOrderModelCopyWithImpl(this._self, this._then);

  final _ShipmentOrderModel _self;
  final $Res Function(_ShipmentOrderModel) _then;

/// Create a copy of ShipmentOrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = freezed,Object? warehouseId = freezed,Object? warehouseName = freezed,Object? status = freezed,Object? city = freezed,Object? receiverName = freezed,Object? senderName = freezed,Object? carrier = freezed,Object? createdByName = freezed,Object? createdAt = freezed,Object? totalUnits = null,Object? items = null,}) {
  return _then(_ShipmentOrderModel(
orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,carrier: freezed == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as num,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ShipmentItemModel>,
  ));
}


}


/// @nodoc
mixin _$ShipmentItemModel {

 String? get productName; num get quantity; String? get unit;
/// Create a copy of ShipmentItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipmentItemModelCopyWith<ShipmentItemModel> get copyWith => _$ShipmentItemModelCopyWithImpl<ShipmentItemModel>(this as ShipmentItemModel, _$identity);

  /// Serializes this ShipmentItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShipmentItemModel&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productName,quantity,unit);

@override
String toString() {
  return 'ShipmentItemModel(productName: $productName, quantity: $quantity, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $ShipmentItemModelCopyWith<$Res>  {
  factory $ShipmentItemModelCopyWith(ShipmentItemModel value, $Res Function(ShipmentItemModel) _then) = _$ShipmentItemModelCopyWithImpl;
@useResult
$Res call({
 String? productName, num quantity, String? unit
});




}
/// @nodoc
class _$ShipmentItemModelCopyWithImpl<$Res>
    implements $ShipmentItemModelCopyWith<$Res> {
  _$ShipmentItemModelCopyWithImpl(this._self, this._then);

  final ShipmentItemModel _self;
  final $Res Function(ShipmentItemModel) _then;

/// Create a copy of ShipmentItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productName = freezed,Object? quantity = null,Object? unit = freezed,}) {
  return _then(_self.copyWith(
productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShipmentItemModel].
extension ShipmentItemModelPatterns on ShipmentItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShipmentItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShipmentItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShipmentItemModel value)  $default,){
final _that = this;
switch (_that) {
case _ShipmentItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShipmentItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShipmentItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? productName,  num quantity,  String? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShipmentItemModel() when $default != null:
return $default(_that.productName,_that.quantity,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? productName,  num quantity,  String? unit)  $default,) {final _that = this;
switch (_that) {
case _ShipmentItemModel():
return $default(_that.productName,_that.quantity,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? productName,  num quantity,  String? unit)?  $default,) {final _that = this;
switch (_that) {
case _ShipmentItemModel() when $default != null:
return $default(_that.productName,_that.quantity,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShipmentItemModel implements ShipmentItemModel {
  const _ShipmentItemModel({this.productName, this.quantity = 0, this.unit});
  factory _ShipmentItemModel.fromJson(Map<String, dynamic> json) => _$ShipmentItemModelFromJson(json);

@override final  String? productName;
@override@JsonKey() final  num quantity;
@override final  String? unit;

/// Create a copy of ShipmentItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipmentItemModelCopyWith<_ShipmentItemModel> get copyWith => __$ShipmentItemModelCopyWithImpl<_ShipmentItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShipmentItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShipmentItemModel&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productName,quantity,unit);

@override
String toString() {
  return 'ShipmentItemModel(productName: $productName, quantity: $quantity, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$ShipmentItemModelCopyWith<$Res> implements $ShipmentItemModelCopyWith<$Res> {
  factory _$ShipmentItemModelCopyWith(_ShipmentItemModel value, $Res Function(_ShipmentItemModel) _then) = __$ShipmentItemModelCopyWithImpl;
@override @useResult
$Res call({
 String? productName, num quantity, String? unit
});




}
/// @nodoc
class __$ShipmentItemModelCopyWithImpl<$Res>
    implements _$ShipmentItemModelCopyWith<$Res> {
  __$ShipmentItemModelCopyWithImpl(this._self, this._then);

  final _ShipmentItemModel _self;
  final $Res Function(_ShipmentItemModel) _then;

/// Create a copy of ShipmentItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productName = freezed,Object? quantity = null,Object? unit = freezed,}) {
  return _then(_ShipmentItemModel(
productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
