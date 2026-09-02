// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keeper_driver_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KeeperDriverModel {

 String get id; String get name; String get phone; String? get avatarUrl;/// انباری که راننده به آن متصل است (خالی = آزاد)
 String? get warehouseId; String? get warehouseName;/// تیک سبز — راننده به انبارِ خودِ انباردار متصل است
 bool get assignedToMe;/// کمرنگ/قفل — راننده به انبارِ دیگری متصل است
 bool get assignedToOther; DateTime? get createdAt;
/// Create a copy of KeeperDriverModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperDriverModelCopyWith<KeeperDriverModel> get copyWith => _$KeeperDriverModelCopyWithImpl<KeeperDriverModel>(this as KeeperDriverModel, _$identity);

  /// Serializes this KeeperDriverModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperDriverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.assignedToMe, assignedToMe) || other.assignedToMe == assignedToMe)&&(identical(other.assignedToOther, assignedToOther) || other.assignedToOther == assignedToOther)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,avatarUrl,warehouseId,warehouseName,assignedToMe,assignedToOther,createdAt);

@override
String toString() {
  return 'KeeperDriverModel(id: $id, name: $name, phone: $phone, avatarUrl: $avatarUrl, warehouseId: $warehouseId, warehouseName: $warehouseName, assignedToMe: $assignedToMe, assignedToOther: $assignedToOther, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $KeeperDriverModelCopyWith<$Res>  {
  factory $KeeperDriverModelCopyWith(KeeperDriverModel value, $Res Function(KeeperDriverModel) _then) = _$KeeperDriverModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String phone, String? avatarUrl, String? warehouseId, String? warehouseName, bool assignedToMe, bool assignedToOther, DateTime? createdAt
});




}
/// @nodoc
class _$KeeperDriverModelCopyWithImpl<$Res>
    implements $KeeperDriverModelCopyWith<$Res> {
  _$KeeperDriverModelCopyWithImpl(this._self, this._then);

  final KeeperDriverModel _self;
  final $Res Function(KeeperDriverModel) _then;

/// Create a copy of KeeperDriverModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? avatarUrl = freezed,Object? warehouseId = freezed,Object? warehouseName = freezed,Object? assignedToMe = null,Object? assignedToOther = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,assignedToMe: null == assignedToMe ? _self.assignedToMe : assignedToMe // ignore: cast_nullable_to_non_nullable
as bool,assignedToOther: null == assignedToOther ? _self.assignedToOther : assignedToOther // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperDriverModel].
extension KeeperDriverModelPatterns on KeeperDriverModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperDriverModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperDriverModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperDriverModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperDriverModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperDriverModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperDriverModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String phone,  String? avatarUrl,  String? warehouseId,  String? warehouseName,  bool assignedToMe,  bool assignedToOther,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperDriverModel() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.avatarUrl,_that.warehouseId,_that.warehouseName,_that.assignedToMe,_that.assignedToOther,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String phone,  String? avatarUrl,  String? warehouseId,  String? warehouseName,  bool assignedToMe,  bool assignedToOther,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _KeeperDriverModel():
return $default(_that.id,_that.name,_that.phone,_that.avatarUrl,_that.warehouseId,_that.warehouseName,_that.assignedToMe,_that.assignedToOther,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String phone,  String? avatarUrl,  String? warehouseId,  String? warehouseName,  bool assignedToMe,  bool assignedToOther,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _KeeperDriverModel() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.avatarUrl,_that.warehouseId,_that.warehouseName,_that.assignedToMe,_that.assignedToOther,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperDriverModel implements KeeperDriverModel {
  const _KeeperDriverModel({this.id = '', this.name = '', this.phone = '', this.avatarUrl, this.warehouseId, this.warehouseName, this.assignedToMe = false, this.assignedToOther = false, this.createdAt});
  factory _KeeperDriverModel.fromJson(Map<String, dynamic> json) => _$KeeperDriverModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String phone;
@override final  String? avatarUrl;
/// انباری که راننده به آن متصل است (خالی = آزاد)
@override final  String? warehouseId;
@override final  String? warehouseName;
/// تیک سبز — راننده به انبارِ خودِ انباردار متصل است
@override@JsonKey() final  bool assignedToMe;
/// کمرنگ/قفل — راننده به انبارِ دیگری متصل است
@override@JsonKey() final  bool assignedToOther;
@override final  DateTime? createdAt;

/// Create a copy of KeeperDriverModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperDriverModelCopyWith<_KeeperDriverModel> get copyWith => __$KeeperDriverModelCopyWithImpl<_KeeperDriverModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperDriverModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperDriverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.assignedToMe, assignedToMe) || other.assignedToMe == assignedToMe)&&(identical(other.assignedToOther, assignedToOther) || other.assignedToOther == assignedToOther)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,avatarUrl,warehouseId,warehouseName,assignedToMe,assignedToOther,createdAt);

@override
String toString() {
  return 'KeeperDriverModel(id: $id, name: $name, phone: $phone, avatarUrl: $avatarUrl, warehouseId: $warehouseId, warehouseName: $warehouseName, assignedToMe: $assignedToMe, assignedToOther: $assignedToOther, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$KeeperDriverModelCopyWith<$Res> implements $KeeperDriverModelCopyWith<$Res> {
  factory _$KeeperDriverModelCopyWith(_KeeperDriverModel value, $Res Function(_KeeperDriverModel) _then) = __$KeeperDriverModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String phone, String? avatarUrl, String? warehouseId, String? warehouseName, bool assignedToMe, bool assignedToOther, DateTime? createdAt
});




}
/// @nodoc
class __$KeeperDriverModelCopyWithImpl<$Res>
    implements _$KeeperDriverModelCopyWith<$Res> {
  __$KeeperDriverModelCopyWithImpl(this._self, this._then);

  final _KeeperDriverModel _self;
  final $Res Function(_KeeperDriverModel) _then;

/// Create a copy of KeeperDriverModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? avatarUrl = freezed,Object? warehouseId = freezed,Object? warehouseName = freezed,Object? assignedToMe = null,Object? assignedToOther = null,Object? createdAt = freezed,}) {
  return _then(_KeeperDriverModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,assignedToMe: null == assignedToMe ? _self.assignedToMe : assignedToMe // ignore: cast_nullable_to_non_nullable
as bool,assignedToOther: null == assignedToOther ? _self.assignedToOther : assignedToOther // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
