// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warehouse_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WarehouseModel {

 String get id; String get name; String? get address; String? get keeperId; String? get keeperName; int get productCount; DateTime? get createdAt;
/// Create a copy of WarehouseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseModelCopyWith<WarehouseModel> get copyWith => _$WarehouseModelCopyWithImpl<WarehouseModel>(this as WarehouseModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarehouseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.keeperId, keeperId) || other.keeperId == keeperId)&&(identical(other.keeperName, keeperName) || other.keeperName == keeperName)&&(identical(other.productCount, productCount) || other.productCount == productCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,address,keeperId,keeperName,productCount,createdAt);

@override
String toString() {
  return 'WarehouseModel(id: $id, name: $name, address: $address, keeperId: $keeperId, keeperName: $keeperName, productCount: $productCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WarehouseModelCopyWith<$Res>  {
  factory $WarehouseModelCopyWith(WarehouseModel value, $Res Function(WarehouseModel) _then) = _$WarehouseModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? address, String? keeperId, String? keeperName, int productCount, DateTime? createdAt
});




}
/// @nodoc
class _$WarehouseModelCopyWithImpl<$Res>
    implements $WarehouseModelCopyWith<$Res> {
  _$WarehouseModelCopyWithImpl(this._self, this._then);

  final WarehouseModel _self;
  final $Res Function(WarehouseModel) _then;

/// Create a copy of WarehouseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = freezed,Object? keeperId = freezed,Object? keeperName = freezed,Object? productCount = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,keeperId: freezed == keeperId ? _self.keeperId : keeperId // ignore: cast_nullable_to_non_nullable
as String?,keeperName: freezed == keeperName ? _self.keeperName : keeperName // ignore: cast_nullable_to_non_nullable
as String?,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WarehouseModel].
extension WarehouseModelPatterns on WarehouseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarehouseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarehouseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarehouseModel value)  $default,){
final _that = this;
switch (_that) {
case _WarehouseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarehouseModel value)?  $default,){
final _that = this;
switch (_that) {
case _WarehouseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? address,  String? keeperId,  String? keeperName,  int productCount,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarehouseModel() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.keeperId,_that.keeperName,_that.productCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? address,  String? keeperId,  String? keeperName,  int productCount,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _WarehouseModel():
return $default(_that.id,_that.name,_that.address,_that.keeperId,_that.keeperName,_that.productCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? address,  String? keeperId,  String? keeperName,  int productCount,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WarehouseModel() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.keeperId,_that.keeperName,_that.productCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _WarehouseModel implements WarehouseModel {
  const _WarehouseModel({required this.id, required this.name, this.address, this.keeperId, this.keeperName, this.productCount = 0, this.createdAt});
  

@override final  String id;
@override final  String name;
@override final  String? address;
@override final  String? keeperId;
@override final  String? keeperName;
@override@JsonKey() final  int productCount;
@override final  DateTime? createdAt;

/// Create a copy of WarehouseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseModelCopyWith<_WarehouseModel> get copyWith => __$WarehouseModelCopyWithImpl<_WarehouseModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarehouseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.keeperId, keeperId) || other.keeperId == keeperId)&&(identical(other.keeperName, keeperName) || other.keeperName == keeperName)&&(identical(other.productCount, productCount) || other.productCount == productCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,address,keeperId,keeperName,productCount,createdAt);

@override
String toString() {
  return 'WarehouseModel(id: $id, name: $name, address: $address, keeperId: $keeperId, keeperName: $keeperName, productCount: $productCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WarehouseModelCopyWith<$Res> implements $WarehouseModelCopyWith<$Res> {
  factory _$WarehouseModelCopyWith(_WarehouseModel value, $Res Function(_WarehouseModel) _then) = __$WarehouseModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? address, String? keeperId, String? keeperName, int productCount, DateTime? createdAt
});




}
/// @nodoc
class __$WarehouseModelCopyWithImpl<$Res>
    implements _$WarehouseModelCopyWith<$Res> {
  __$WarehouseModelCopyWithImpl(this._self, this._then);

  final _WarehouseModel _self;
  final $Res Function(_WarehouseModel) _then;

/// Create a copy of WarehouseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = freezed,Object? keeperId = freezed,Object? keeperName = freezed,Object? productCount = null,Object? createdAt = freezed,}) {
  return _then(_WarehouseModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,keeperId: freezed == keeperId ? _self.keeperId : keeperId // ignore: cast_nullable_to_non_nullable
as String?,keeperName: freezed == keeperName ? _self.keeperName : keeperName // ignore: cast_nullable_to_non_nullable
as String?,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
