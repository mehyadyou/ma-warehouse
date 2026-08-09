// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warehouse_inventory_row_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WarehouseInventoryRowModel {

 String? get warehouseName; String? get productName; num get count;
/// Create a copy of WarehouseInventoryRowModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseInventoryRowModelCopyWith<WarehouseInventoryRowModel> get copyWith => _$WarehouseInventoryRowModelCopyWithImpl<WarehouseInventoryRowModel>(this as WarehouseInventoryRowModel, _$identity);

  /// Serializes this WarehouseInventoryRowModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarehouseInventoryRowModel&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseName,productName,count);

@override
String toString() {
  return 'WarehouseInventoryRowModel(warehouseName: $warehouseName, productName: $productName, count: $count)';
}


}

/// @nodoc
abstract mixin class $WarehouseInventoryRowModelCopyWith<$Res>  {
  factory $WarehouseInventoryRowModelCopyWith(WarehouseInventoryRowModel value, $Res Function(WarehouseInventoryRowModel) _then) = _$WarehouseInventoryRowModelCopyWithImpl;
@useResult
$Res call({
 String? warehouseName, String? productName, num count
});




}
/// @nodoc
class _$WarehouseInventoryRowModelCopyWithImpl<$Res>
    implements $WarehouseInventoryRowModelCopyWith<$Res> {
  _$WarehouseInventoryRowModelCopyWithImpl(this._self, this._then);

  final WarehouseInventoryRowModel _self;
  final $Res Function(WarehouseInventoryRowModel) _then;

/// Create a copy of WarehouseInventoryRowModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warehouseName = freezed,Object? productName = freezed,Object? count = null,}) {
  return _then(_self.copyWith(
warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [WarehouseInventoryRowModel].
extension WarehouseInventoryRowModelPatterns on WarehouseInventoryRowModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarehouseInventoryRowModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarehouseInventoryRowModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarehouseInventoryRowModel value)  $default,){
final _that = this;
switch (_that) {
case _WarehouseInventoryRowModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarehouseInventoryRowModel value)?  $default,){
final _that = this;
switch (_that) {
case _WarehouseInventoryRowModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? warehouseName,  String? productName,  num count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarehouseInventoryRowModel() when $default != null:
return $default(_that.warehouseName,_that.productName,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? warehouseName,  String? productName,  num count)  $default,) {final _that = this;
switch (_that) {
case _WarehouseInventoryRowModel():
return $default(_that.warehouseName,_that.productName,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? warehouseName,  String? productName,  num count)?  $default,) {final _that = this;
switch (_that) {
case _WarehouseInventoryRowModel() when $default != null:
return $default(_that.warehouseName,_that.productName,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WarehouseInventoryRowModel implements WarehouseInventoryRowModel {
  const _WarehouseInventoryRowModel({this.warehouseName, this.productName, this.count = 0});
  factory _WarehouseInventoryRowModel.fromJson(Map<String, dynamic> json) => _$WarehouseInventoryRowModelFromJson(json);

@override final  String? warehouseName;
@override final  String? productName;
@override@JsonKey() final  num count;

/// Create a copy of WarehouseInventoryRowModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseInventoryRowModelCopyWith<_WarehouseInventoryRowModel> get copyWith => __$WarehouseInventoryRowModelCopyWithImpl<_WarehouseInventoryRowModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WarehouseInventoryRowModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarehouseInventoryRowModel&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseName,productName,count);

@override
String toString() {
  return 'WarehouseInventoryRowModel(warehouseName: $warehouseName, productName: $productName, count: $count)';
}


}

/// @nodoc
abstract mixin class _$WarehouseInventoryRowModelCopyWith<$Res> implements $WarehouseInventoryRowModelCopyWith<$Res> {
  factory _$WarehouseInventoryRowModelCopyWith(_WarehouseInventoryRowModel value, $Res Function(_WarehouseInventoryRowModel) _then) = __$WarehouseInventoryRowModelCopyWithImpl;
@override @useResult
$Res call({
 String? warehouseName, String? productName, num count
});




}
/// @nodoc
class __$WarehouseInventoryRowModelCopyWithImpl<$Res>
    implements _$WarehouseInventoryRowModelCopyWith<$Res> {
  __$WarehouseInventoryRowModelCopyWithImpl(this._self, this._then);

  final _WarehouseInventoryRowModel _self;
  final $Res Function(_WarehouseInventoryRowModel) _then;

/// Create a copy of WarehouseInventoryRowModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warehouseName = freezed,Object? productName = freezed,Object? count = null,}) {
  return _then(_WarehouseInventoryRowModel(
warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
