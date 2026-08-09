// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistoryEntryModel {

 String? get type; String? get createdAt; String? get label; String? get userName;
/// Create a copy of HistoryEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryEntryModelCopyWith<HistoryEntryModel> get copyWith => _$HistoryEntryModelCopyWithImpl<HistoryEntryModel>(this as HistoryEntryModel, _$identity);

  /// Serializes this HistoryEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryEntryModel&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.label, label) || other.label == label)&&(identical(other.userName, userName) || other.userName == userName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,createdAt,label,userName);

@override
String toString() {
  return 'HistoryEntryModel(type: $type, createdAt: $createdAt, label: $label, userName: $userName)';
}


}

/// @nodoc
abstract mixin class $HistoryEntryModelCopyWith<$Res>  {
  factory $HistoryEntryModelCopyWith(HistoryEntryModel value, $Res Function(HistoryEntryModel) _then) = _$HistoryEntryModelCopyWithImpl;
@useResult
$Res call({
 String? type, String? createdAt, String? label, String? userName
});




}
/// @nodoc
class _$HistoryEntryModelCopyWithImpl<$Res>
    implements $HistoryEntryModelCopyWith<$Res> {
  _$HistoryEntryModelCopyWithImpl(this._self, this._then);

  final HistoryEntryModel _self;
  final $Res Function(HistoryEntryModel) _then;

/// Create a copy of HistoryEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? createdAt = freezed,Object? label = freezed,Object? userName = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryEntryModel].
extension HistoryEntryModelPatterns on HistoryEntryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryEntryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _HistoryEntryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryEntryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  String? createdAt,  String? label,  String? userName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryEntryModel() when $default != null:
return $default(_that.type,_that.createdAt,_that.label,_that.userName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  String? createdAt,  String? label,  String? userName)  $default,) {final _that = this;
switch (_that) {
case _HistoryEntryModel():
return $default(_that.type,_that.createdAt,_that.label,_that.userName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  String? createdAt,  String? label,  String? userName)?  $default,) {final _that = this;
switch (_that) {
case _HistoryEntryModel() when $default != null:
return $default(_that.type,_that.createdAt,_that.label,_that.userName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoryEntryModel implements HistoryEntryModel {
  const _HistoryEntryModel({this.type, this.createdAt, this.label, this.userName});
  factory _HistoryEntryModel.fromJson(Map<String, dynamic> json) => _$HistoryEntryModelFromJson(json);

@override final  String? type;
@override final  String? createdAt;
@override final  String? label;
@override final  String? userName;

/// Create a copy of HistoryEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryEntryModelCopyWith<_HistoryEntryModel> get copyWith => __$HistoryEntryModelCopyWithImpl<_HistoryEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryEntryModel&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.label, label) || other.label == label)&&(identical(other.userName, userName) || other.userName == userName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,createdAt,label,userName);

@override
String toString() {
  return 'HistoryEntryModel(type: $type, createdAt: $createdAt, label: $label, userName: $userName)';
}


}

/// @nodoc
abstract mixin class _$HistoryEntryModelCopyWith<$Res> implements $HistoryEntryModelCopyWith<$Res> {
  factory _$HistoryEntryModelCopyWith(_HistoryEntryModel value, $Res Function(_HistoryEntryModel) _then) = __$HistoryEntryModelCopyWithImpl;
@override @useResult
$Res call({
 String? type, String? createdAt, String? label, String? userName
});




}
/// @nodoc
class __$HistoryEntryModelCopyWithImpl<$Res>
    implements _$HistoryEntryModelCopyWith<$Res> {
  __$HistoryEntryModelCopyWithImpl(this._self, this._then);

  final _HistoryEntryModel _self;
  final $Res Function(_HistoryEntryModel) _then;

/// Create a copy of HistoryEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? createdAt = freezed,Object? label = freezed,Object? userName = freezed,}) {
  return _then(_HistoryEntryModel(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
