// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keeper_carrier_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KeeperCarrierModel {

 String get id; String get name;/// اولویت باربری — مرتب‌سازی برنامهٔ بارگیری راننده بر اساس آن انجام می‌شود
 int get priority; String? get phone; String? get address;
/// Create a copy of KeeperCarrierModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperCarrierModelCopyWith<KeeperCarrierModel> get copyWith => _$KeeperCarrierModelCopyWithImpl<KeeperCarrierModel>(this as KeeperCarrierModel, _$identity);

  /// Serializes this KeeperCarrierModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperCarrierModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,priority,phone,address);

@override
String toString() {
  return 'KeeperCarrierModel(id: $id, name: $name, priority: $priority, phone: $phone, address: $address)';
}


}

/// @nodoc
abstract mixin class $KeeperCarrierModelCopyWith<$Res>  {
  factory $KeeperCarrierModelCopyWith(KeeperCarrierModel value, $Res Function(KeeperCarrierModel) _then) = _$KeeperCarrierModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, int priority, String? phone, String? address
});




}
/// @nodoc
class _$KeeperCarrierModelCopyWithImpl<$Res>
    implements $KeeperCarrierModelCopyWith<$Res> {
  _$KeeperCarrierModelCopyWithImpl(this._self, this._then);

  final KeeperCarrierModel _self;
  final $Res Function(KeeperCarrierModel) _then;

/// Create a copy of KeeperCarrierModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? priority = null,Object? phone = freezed,Object? address = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperCarrierModel].
extension KeeperCarrierModelPatterns on KeeperCarrierModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperCarrierModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperCarrierModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperCarrierModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperCarrierModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperCarrierModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperCarrierModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int priority,  String? phone,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperCarrierModel() when $default != null:
return $default(_that.id,_that.name,_that.priority,_that.phone,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int priority,  String? phone,  String? address)  $default,) {final _that = this;
switch (_that) {
case _KeeperCarrierModel():
return $default(_that.id,_that.name,_that.priority,_that.phone,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int priority,  String? phone,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _KeeperCarrierModel() when $default != null:
return $default(_that.id,_that.name,_that.priority,_that.phone,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperCarrierModel implements KeeperCarrierModel {
  const _KeeperCarrierModel({this.id = '', this.name = '', this.priority = 0, this.phone, this.address});
  factory _KeeperCarrierModel.fromJson(Map<String, dynamic> json) => _$KeeperCarrierModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
/// اولویت باربری — مرتب‌سازی برنامهٔ بارگیری راننده بر اساس آن انجام می‌شود
@override@JsonKey() final  int priority;
@override final  String? phone;
@override final  String? address;

/// Create a copy of KeeperCarrierModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperCarrierModelCopyWith<_KeeperCarrierModel> get copyWith => __$KeeperCarrierModelCopyWithImpl<_KeeperCarrierModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperCarrierModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperCarrierModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,priority,phone,address);

@override
String toString() {
  return 'KeeperCarrierModel(id: $id, name: $name, priority: $priority, phone: $phone, address: $address)';
}


}

/// @nodoc
abstract mixin class _$KeeperCarrierModelCopyWith<$Res> implements $KeeperCarrierModelCopyWith<$Res> {
  factory _$KeeperCarrierModelCopyWith(_KeeperCarrierModel value, $Res Function(_KeeperCarrierModel) _then) = __$KeeperCarrierModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int priority, String? phone, String? address
});




}
/// @nodoc
class __$KeeperCarrierModelCopyWithImpl<$Res>
    implements _$KeeperCarrierModelCopyWith<$Res> {
  __$KeeperCarrierModelCopyWithImpl(this._self, this._then);

  final _KeeperCarrierModel _self;
  final $Res Function(_KeeperCarrierModel) _then;

/// Create a copy of KeeperCarrierModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? priority = null,Object? phone = freezed,Object? address = freezed,}) {
  return _then(_KeeperCarrierModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
