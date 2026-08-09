// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loading_plan_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoadingPlanItemModel {

 int get sequence; String get productName; String get modelName; bool? get isIndividualUnit; int? get capacityPerBox; String? get unit;
/// Create a copy of LoadingPlanItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadingPlanItemModelCopyWith<LoadingPlanItemModel> get copyWith => _$LoadingPlanItemModelCopyWithImpl<LoadingPlanItemModel>(this as LoadingPlanItemModel, _$identity);

  /// Serializes this LoadingPlanItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadingPlanItemModel&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.isIndividualUnit, isIndividualUnit) || other.isIndividualUnit == isIndividualUnit)&&(identical(other.capacityPerBox, capacityPerBox) || other.capacityPerBox == capacityPerBox)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sequence,productName,modelName,isIndividualUnit,capacityPerBox,unit);

@override
String toString() {
  return 'LoadingPlanItemModel(sequence: $sequence, productName: $productName, modelName: $modelName, isIndividualUnit: $isIndividualUnit, capacityPerBox: $capacityPerBox, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $LoadingPlanItemModelCopyWith<$Res>  {
  factory $LoadingPlanItemModelCopyWith(LoadingPlanItemModel value, $Res Function(LoadingPlanItemModel) _then) = _$LoadingPlanItemModelCopyWithImpl;
@useResult
$Res call({
 int sequence, String productName, String modelName, bool? isIndividualUnit, int? capacityPerBox, String? unit
});




}
/// @nodoc
class _$LoadingPlanItemModelCopyWithImpl<$Res>
    implements $LoadingPlanItemModelCopyWith<$Res> {
  _$LoadingPlanItemModelCopyWithImpl(this._self, this._then);

  final LoadingPlanItemModel _self;
  final $Res Function(LoadingPlanItemModel) _then;

/// Create a copy of LoadingPlanItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sequence = null,Object? productName = null,Object? modelName = null,Object? isIndividualUnit = freezed,Object? capacityPerBox = freezed,Object? unit = freezed,}) {
  return _then(_self.copyWith(
sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,isIndividualUnit: freezed == isIndividualUnit ? _self.isIndividualUnit : isIndividualUnit // ignore: cast_nullable_to_non_nullable
as bool?,capacityPerBox: freezed == capacityPerBox ? _self.capacityPerBox : capacityPerBox // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoadingPlanItemModel].
extension LoadingPlanItemModelPatterns on LoadingPlanItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoadingPlanItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadingPlanItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoadingPlanItemModel value)  $default,){
final _that = this;
switch (_that) {
case _LoadingPlanItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoadingPlanItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _LoadingPlanItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sequence,  String productName,  String modelName,  bool? isIndividualUnit,  int? capacityPerBox,  String? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadingPlanItemModel() when $default != null:
return $default(_that.sequence,_that.productName,_that.modelName,_that.isIndividualUnit,_that.capacityPerBox,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sequence,  String productName,  String modelName,  bool? isIndividualUnit,  int? capacityPerBox,  String? unit)  $default,) {final _that = this;
switch (_that) {
case _LoadingPlanItemModel():
return $default(_that.sequence,_that.productName,_that.modelName,_that.isIndividualUnit,_that.capacityPerBox,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sequence,  String productName,  String modelName,  bool? isIndividualUnit,  int? capacityPerBox,  String? unit)?  $default,) {final _that = this;
switch (_that) {
case _LoadingPlanItemModel() when $default != null:
return $default(_that.sequence,_that.productName,_that.modelName,_that.isIndividualUnit,_that.capacityPerBox,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoadingPlanItemModel implements LoadingPlanItemModel {
  const _LoadingPlanItemModel({this.sequence = 0, this.productName = '', this.modelName = '', this.isIndividualUnit, this.capacityPerBox, this.unit});
  factory _LoadingPlanItemModel.fromJson(Map<String, dynamic> json) => _$LoadingPlanItemModelFromJson(json);

@override@JsonKey() final  int sequence;
@override@JsonKey() final  String productName;
@override@JsonKey() final  String modelName;
@override final  bool? isIndividualUnit;
@override final  int? capacityPerBox;
@override final  String? unit;

/// Create a copy of LoadingPlanItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadingPlanItemModelCopyWith<_LoadingPlanItemModel> get copyWith => __$LoadingPlanItemModelCopyWithImpl<_LoadingPlanItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoadingPlanItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadingPlanItemModel&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.isIndividualUnit, isIndividualUnit) || other.isIndividualUnit == isIndividualUnit)&&(identical(other.capacityPerBox, capacityPerBox) || other.capacityPerBox == capacityPerBox)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sequence,productName,modelName,isIndividualUnit,capacityPerBox,unit);

@override
String toString() {
  return 'LoadingPlanItemModel(sequence: $sequence, productName: $productName, modelName: $modelName, isIndividualUnit: $isIndividualUnit, capacityPerBox: $capacityPerBox, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$LoadingPlanItemModelCopyWith<$Res> implements $LoadingPlanItemModelCopyWith<$Res> {
  factory _$LoadingPlanItemModelCopyWith(_LoadingPlanItemModel value, $Res Function(_LoadingPlanItemModel) _then) = __$LoadingPlanItemModelCopyWithImpl;
@override @useResult
$Res call({
 int sequence, String productName, String modelName, bool? isIndividualUnit, int? capacityPerBox, String? unit
});




}
/// @nodoc
class __$LoadingPlanItemModelCopyWithImpl<$Res>
    implements _$LoadingPlanItemModelCopyWith<$Res> {
  __$LoadingPlanItemModelCopyWithImpl(this._self, this._then);

  final _LoadingPlanItemModel _self;
  final $Res Function(_LoadingPlanItemModel) _then;

/// Create a copy of LoadingPlanItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sequence = null,Object? productName = null,Object? modelName = null,Object? isIndividualUnit = freezed,Object? capacityPerBox = freezed,Object? unit = freezed,}) {
  return _then(_LoadingPlanItemModel(
sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,isIndividualUnit: freezed == isIndividualUnit ? _self.isIndividualUnit : isIndividualUnit // ignore: cast_nullable_to_non_nullable
as bool?,capacityPerBox: freezed == capacityPerBox ? _self.capacityPerBox : capacityPerBox // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
