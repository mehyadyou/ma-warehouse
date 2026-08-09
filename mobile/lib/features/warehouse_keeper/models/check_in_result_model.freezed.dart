// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckInResultModel {

 List<Map<String, dynamic>> get cartons;
/// Create a copy of CheckInResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInResultModelCopyWith<CheckInResultModel> get copyWith => _$CheckInResultModelCopyWithImpl<CheckInResultModel>(this as CheckInResultModel, _$identity);

  /// Serializes this CheckInResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInResultModel&&const DeepCollectionEquality().equals(other.cartons, cartons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(cartons));

@override
String toString() {
  return 'CheckInResultModel(cartons: $cartons)';
}


}

/// @nodoc
abstract mixin class $CheckInResultModelCopyWith<$Res>  {
  factory $CheckInResultModelCopyWith(CheckInResultModel value, $Res Function(CheckInResultModel) _then) = _$CheckInResultModelCopyWithImpl;
@useResult
$Res call({
 List<Map<String, dynamic>> cartons
});




}
/// @nodoc
class _$CheckInResultModelCopyWithImpl<$Res>
    implements $CheckInResultModelCopyWith<$Res> {
  _$CheckInResultModelCopyWithImpl(this._self, this._then);

  final CheckInResultModel _self;
  final $Res Function(CheckInResultModel) _then;

/// Create a copy of CheckInResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cartons = null,}) {
  return _then(_self.copyWith(
cartons: null == cartons ? _self.cartons : cartons // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckInResultModel].
extension CheckInResultModelPatterns on CheckInResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInResultModel value)  $default,){
final _that = this;
switch (_that) {
case _CheckInResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Map<String, dynamic>> cartons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInResultModel() when $default != null:
return $default(_that.cartons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Map<String, dynamic>> cartons)  $default,) {final _that = this;
switch (_that) {
case _CheckInResultModel():
return $default(_that.cartons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Map<String, dynamic>> cartons)?  $default,) {final _that = this;
switch (_that) {
case _CheckInResultModel() when $default != null:
return $default(_that.cartons);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckInResultModel implements CheckInResultModel {
  const _CheckInResultModel({final  List<Map<String, dynamic>> cartons = const <Map<String, dynamic>>[]}): _cartons = cartons;
  factory _CheckInResultModel.fromJson(Map<String, dynamic> json) => _$CheckInResultModelFromJson(json);

 final  List<Map<String, dynamic>> _cartons;
@override@JsonKey() List<Map<String, dynamic>> get cartons {
  if (_cartons is EqualUnmodifiableListView) return _cartons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cartons);
}


/// Create a copy of CheckInResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInResultModelCopyWith<_CheckInResultModel> get copyWith => __$CheckInResultModelCopyWithImpl<_CheckInResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInResultModel&&const DeepCollectionEquality().equals(other._cartons, _cartons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cartons));

@override
String toString() {
  return 'CheckInResultModel(cartons: $cartons)';
}


}

/// @nodoc
abstract mixin class _$CheckInResultModelCopyWith<$Res> implements $CheckInResultModelCopyWith<$Res> {
  factory _$CheckInResultModelCopyWith(_CheckInResultModel value, $Res Function(_CheckInResultModel) _then) = __$CheckInResultModelCopyWithImpl;
@override @useResult
$Res call({
 List<Map<String, dynamic>> cartons
});




}
/// @nodoc
class __$CheckInResultModelCopyWithImpl<$Res>
    implements _$CheckInResultModelCopyWith<$Res> {
  __$CheckInResultModelCopyWithImpl(this._self, this._then);

  final _CheckInResultModel _self;
  final $Res Function(_CheckInResultModel) _then;

/// Create a copy of CheckInResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cartons = null,}) {
  return _then(_CheckInResultModel(
cartons: null == cartons ? _self._cartons : cartons // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
