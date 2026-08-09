// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keeper_warehouse_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KeeperWarehouseModel {

 String get name; String get keeperName;
/// Create a copy of KeeperWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperWarehouseModelCopyWith<KeeperWarehouseModel> get copyWith => _$KeeperWarehouseModelCopyWithImpl<KeeperWarehouseModel>(this as KeeperWarehouseModel, _$identity);

  /// Serializes this KeeperWarehouseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperWarehouseModel&&(identical(other.name, name) || other.name == name)&&(identical(other.keeperName, keeperName) || other.keeperName == keeperName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,keeperName);

@override
String toString() {
  return 'KeeperWarehouseModel(name: $name, keeperName: $keeperName)';
}


}

/// @nodoc
abstract mixin class $KeeperWarehouseModelCopyWith<$Res>  {
  factory $KeeperWarehouseModelCopyWith(KeeperWarehouseModel value, $Res Function(KeeperWarehouseModel) _then) = _$KeeperWarehouseModelCopyWithImpl;
@useResult
$Res call({
 String name, String keeperName
});




}
/// @nodoc
class _$KeeperWarehouseModelCopyWithImpl<$Res>
    implements $KeeperWarehouseModelCopyWith<$Res> {
  _$KeeperWarehouseModelCopyWithImpl(this._self, this._then);

  final KeeperWarehouseModel _self;
  final $Res Function(KeeperWarehouseModel) _then;

/// Create a copy of KeeperWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? keeperName = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,keeperName: null == keeperName ? _self.keeperName : keeperName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperWarehouseModel].
extension KeeperWarehouseModelPatterns on KeeperWarehouseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperWarehouseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperWarehouseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperWarehouseModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperWarehouseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperWarehouseModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperWarehouseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String keeperName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperWarehouseModel() when $default != null:
return $default(_that.name,_that.keeperName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String keeperName)  $default,) {final _that = this;
switch (_that) {
case _KeeperWarehouseModel():
return $default(_that.name,_that.keeperName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String keeperName)?  $default,) {final _that = this;
switch (_that) {
case _KeeperWarehouseModel() when $default != null:
return $default(_that.name,_that.keeperName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperWarehouseModel implements KeeperWarehouseModel {
  const _KeeperWarehouseModel({this.name = '', this.keeperName = ''});
  factory _KeeperWarehouseModel.fromJson(Map<String, dynamic> json) => _$KeeperWarehouseModelFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String keeperName;

/// Create a copy of KeeperWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperWarehouseModelCopyWith<_KeeperWarehouseModel> get copyWith => __$KeeperWarehouseModelCopyWithImpl<_KeeperWarehouseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperWarehouseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperWarehouseModel&&(identical(other.name, name) || other.name == name)&&(identical(other.keeperName, keeperName) || other.keeperName == keeperName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,keeperName);

@override
String toString() {
  return 'KeeperWarehouseModel(name: $name, keeperName: $keeperName)';
}


}

/// @nodoc
abstract mixin class _$KeeperWarehouseModelCopyWith<$Res> implements $KeeperWarehouseModelCopyWith<$Res> {
  factory _$KeeperWarehouseModelCopyWith(_KeeperWarehouseModel value, $Res Function(_KeeperWarehouseModel) _then) = __$KeeperWarehouseModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String keeperName
});




}
/// @nodoc
class __$KeeperWarehouseModelCopyWithImpl<$Res>
    implements _$KeeperWarehouseModelCopyWith<$Res> {
  __$KeeperWarehouseModelCopyWithImpl(this._self, this._then);

  final _KeeperWarehouseModel _self;
  final $Res Function(_KeeperWarehouseModel) _then;

/// Create a copy of KeeperWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? keeperName = null,}) {
  return _then(_KeeperWarehouseModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,keeperName: null == keeperName ? _self.keeperName : keeperName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
