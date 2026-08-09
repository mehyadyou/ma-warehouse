// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_out_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScanOutResultModel {

 bool get valid; String get error; ScanOutCartonModel? get carton;
/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanOutResultModelCopyWith<ScanOutResultModel> get copyWith => _$ScanOutResultModelCopyWithImpl<ScanOutResultModel>(this as ScanOutResultModel, _$identity);

  /// Serializes this ScanOutResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanOutResultModel&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.error, error) || other.error == error)&&(identical(other.carton, carton) || other.carton == carton));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,valid,error,carton);

@override
String toString() {
  return 'ScanOutResultModel(valid: $valid, error: $error, carton: $carton)';
}


}

/// @nodoc
abstract mixin class $ScanOutResultModelCopyWith<$Res>  {
  factory $ScanOutResultModelCopyWith(ScanOutResultModel value, $Res Function(ScanOutResultModel) _then) = _$ScanOutResultModelCopyWithImpl;
@useResult
$Res call({
 bool valid, String error, ScanOutCartonModel? carton
});


$ScanOutCartonModelCopyWith<$Res>? get carton;

}
/// @nodoc
class _$ScanOutResultModelCopyWithImpl<$Res>
    implements $ScanOutResultModelCopyWith<$Res> {
  _$ScanOutResultModelCopyWithImpl(this._self, this._then);

  final ScanOutResultModel _self;
  final $Res Function(ScanOutResultModel) _then;

/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valid = null,Object? error = null,Object? carton = freezed,}) {
  return _then(_self.copyWith(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,carton: freezed == carton ? _self.carton : carton // ignore: cast_nullable_to_non_nullable
as ScanOutCartonModel?,
  ));
}
/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanOutCartonModelCopyWith<$Res>? get carton {
    if (_self.carton == null) {
    return null;
  }

  return $ScanOutCartonModelCopyWith<$Res>(_self.carton!, (value) {
    return _then(_self.copyWith(carton: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScanOutResultModel].
extension ScanOutResultModelPatterns on ScanOutResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanOutResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanOutResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanOutResultModel value)  $default,){
final _that = this;
switch (_that) {
case _ScanOutResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanOutResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScanOutResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool valid,  String error,  ScanOutCartonModel? carton)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanOutResultModel() when $default != null:
return $default(_that.valid,_that.error,_that.carton);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool valid,  String error,  ScanOutCartonModel? carton)  $default,) {final _that = this;
switch (_that) {
case _ScanOutResultModel():
return $default(_that.valid,_that.error,_that.carton);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool valid,  String error,  ScanOutCartonModel? carton)?  $default,) {final _that = this;
switch (_that) {
case _ScanOutResultModel() when $default != null:
return $default(_that.valid,_that.error,_that.carton);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanOutResultModel implements ScanOutResultModel {
  const _ScanOutResultModel({this.valid = false, this.error = '', this.carton});
  factory _ScanOutResultModel.fromJson(Map<String, dynamic> json) => _$ScanOutResultModelFromJson(json);

@override@JsonKey() final  bool valid;
@override@JsonKey() final  String error;
@override final  ScanOutCartonModel? carton;

/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanOutResultModelCopyWith<_ScanOutResultModel> get copyWith => __$ScanOutResultModelCopyWithImpl<_ScanOutResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanOutResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanOutResultModel&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.error, error) || other.error == error)&&(identical(other.carton, carton) || other.carton == carton));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,valid,error,carton);

@override
String toString() {
  return 'ScanOutResultModel(valid: $valid, error: $error, carton: $carton)';
}


}

/// @nodoc
abstract mixin class _$ScanOutResultModelCopyWith<$Res> implements $ScanOutResultModelCopyWith<$Res> {
  factory _$ScanOutResultModelCopyWith(_ScanOutResultModel value, $Res Function(_ScanOutResultModel) _then) = __$ScanOutResultModelCopyWithImpl;
@override @useResult
$Res call({
 bool valid, String error, ScanOutCartonModel? carton
});


@override $ScanOutCartonModelCopyWith<$Res>? get carton;

}
/// @nodoc
class __$ScanOutResultModelCopyWithImpl<$Res>
    implements _$ScanOutResultModelCopyWith<$Res> {
  __$ScanOutResultModelCopyWithImpl(this._self, this._then);

  final _ScanOutResultModel _self;
  final $Res Function(_ScanOutResultModel) _then;

/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valid = null,Object? error = null,Object? carton = freezed,}) {
  return _then(_ScanOutResultModel(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,carton: freezed == carton ? _self.carton : carton // ignore: cast_nullable_to_non_nullable
as ScanOutCartonModel?,
  ));
}

/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanOutCartonModelCopyWith<$Res>? get carton {
    if (_self.carton == null) {
    return null;
  }

  return $ScanOutCartonModelCopyWith<$Res>(_self.carton!, (value) {
    return _then(_self.copyWith(carton: value));
  });
}
}


/// @nodoc
mixin _$ScanOutCartonModel {

 String get productName; String get modelName; String? get serialNumber; bool? get isIndividualUnit; int? get capacityPerBox; String? get unit; String? get packageType;
/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanOutCartonModelCopyWith<ScanOutCartonModel> get copyWith => _$ScanOutCartonModelCopyWithImpl<ScanOutCartonModel>(this as ScanOutCartonModel, _$identity);

  /// Serializes this ScanOutCartonModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanOutCartonModel&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.isIndividualUnit, isIndividualUnit) || other.isIndividualUnit == isIndividualUnit)&&(identical(other.capacityPerBox, capacityPerBox) || other.capacityPerBox == capacityPerBox)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.packageType, packageType) || other.packageType == packageType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productName,modelName,serialNumber,isIndividualUnit,capacityPerBox,unit,packageType);

@override
String toString() {
  return 'ScanOutCartonModel(productName: $productName, modelName: $modelName, serialNumber: $serialNumber, isIndividualUnit: $isIndividualUnit, capacityPerBox: $capacityPerBox, unit: $unit, packageType: $packageType)';
}


}

/// @nodoc
abstract mixin class $ScanOutCartonModelCopyWith<$Res>  {
  factory $ScanOutCartonModelCopyWith(ScanOutCartonModel value, $Res Function(ScanOutCartonModel) _then) = _$ScanOutCartonModelCopyWithImpl;
@useResult
$Res call({
 String productName, String modelName, String? serialNumber, bool? isIndividualUnit, int? capacityPerBox, String? unit, String? packageType
});




}
/// @nodoc
class _$ScanOutCartonModelCopyWithImpl<$Res>
    implements $ScanOutCartonModelCopyWith<$Res> {
  _$ScanOutCartonModelCopyWithImpl(this._self, this._then);

  final ScanOutCartonModel _self;
  final $Res Function(ScanOutCartonModel) _then;

/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productName = null,Object? modelName = null,Object? serialNumber = freezed,Object? isIndividualUnit = freezed,Object? capacityPerBox = freezed,Object? unit = freezed,Object? packageType = freezed,}) {
  return _then(_self.copyWith(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,isIndividualUnit: freezed == isIndividualUnit ? _self.isIndividualUnit : isIndividualUnit // ignore: cast_nullable_to_non_nullable
as bool?,capacityPerBox: freezed == capacityPerBox ? _self.capacityPerBox : capacityPerBox // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScanOutCartonModel].
extension ScanOutCartonModelPatterns on ScanOutCartonModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanOutCartonModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanOutCartonModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanOutCartonModel value)  $default,){
final _that = this;
switch (_that) {
case _ScanOutCartonModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanOutCartonModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScanOutCartonModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productName,  String modelName,  String? serialNumber,  bool? isIndividualUnit,  int? capacityPerBox,  String? unit,  String? packageType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanOutCartonModel() when $default != null:
return $default(_that.productName,_that.modelName,_that.serialNumber,_that.isIndividualUnit,_that.capacityPerBox,_that.unit,_that.packageType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productName,  String modelName,  String? serialNumber,  bool? isIndividualUnit,  int? capacityPerBox,  String? unit,  String? packageType)  $default,) {final _that = this;
switch (_that) {
case _ScanOutCartonModel():
return $default(_that.productName,_that.modelName,_that.serialNumber,_that.isIndividualUnit,_that.capacityPerBox,_that.unit,_that.packageType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productName,  String modelName,  String? serialNumber,  bool? isIndividualUnit,  int? capacityPerBox,  String? unit,  String? packageType)?  $default,) {final _that = this;
switch (_that) {
case _ScanOutCartonModel() when $default != null:
return $default(_that.productName,_that.modelName,_that.serialNumber,_that.isIndividualUnit,_that.capacityPerBox,_that.unit,_that.packageType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanOutCartonModel implements ScanOutCartonModel {
  const _ScanOutCartonModel({this.productName = '', this.modelName = '', this.serialNumber, this.isIndividualUnit, this.capacityPerBox, this.unit, this.packageType});
  factory _ScanOutCartonModel.fromJson(Map<String, dynamic> json) => _$ScanOutCartonModelFromJson(json);

@override@JsonKey() final  String productName;
@override@JsonKey() final  String modelName;
@override final  String? serialNumber;
@override final  bool? isIndividualUnit;
@override final  int? capacityPerBox;
@override final  String? unit;
@override final  String? packageType;

/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanOutCartonModelCopyWith<_ScanOutCartonModel> get copyWith => __$ScanOutCartonModelCopyWithImpl<_ScanOutCartonModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanOutCartonModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanOutCartonModel&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.isIndividualUnit, isIndividualUnit) || other.isIndividualUnit == isIndividualUnit)&&(identical(other.capacityPerBox, capacityPerBox) || other.capacityPerBox == capacityPerBox)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.packageType, packageType) || other.packageType == packageType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productName,modelName,serialNumber,isIndividualUnit,capacityPerBox,unit,packageType);

@override
String toString() {
  return 'ScanOutCartonModel(productName: $productName, modelName: $modelName, serialNumber: $serialNumber, isIndividualUnit: $isIndividualUnit, capacityPerBox: $capacityPerBox, unit: $unit, packageType: $packageType)';
}


}

/// @nodoc
abstract mixin class _$ScanOutCartonModelCopyWith<$Res> implements $ScanOutCartonModelCopyWith<$Res> {
  factory _$ScanOutCartonModelCopyWith(_ScanOutCartonModel value, $Res Function(_ScanOutCartonModel) _then) = __$ScanOutCartonModelCopyWithImpl;
@override @useResult
$Res call({
 String productName, String modelName, String? serialNumber, bool? isIndividualUnit, int? capacityPerBox, String? unit, String? packageType
});




}
/// @nodoc
class __$ScanOutCartonModelCopyWithImpl<$Res>
    implements _$ScanOutCartonModelCopyWith<$Res> {
  __$ScanOutCartonModelCopyWithImpl(this._self, this._then);

  final _ScanOutCartonModel _self;
  final $Res Function(_ScanOutCartonModel) _then;

/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productName = null,Object? modelName = null,Object? serialNumber = freezed,Object? isIndividualUnit = freezed,Object? capacityPerBox = freezed,Object? unit = freezed,Object? packageType = freezed,}) {
  return _then(_ScanOutCartonModel(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,isIndividualUnit: freezed == isIndividualUnit ? _self.isIndividualUnit : isIndividualUnit // ignore: cast_nullable_to_non_nullable
as bool?,capacityPerBox: freezed == capacityPerBox ? _self.capacityPerBox : capacityPerBox // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
