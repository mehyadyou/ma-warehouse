// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'archive_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ArchivedProductModel {

 String get id; String? get name; String? get unit; List<ArchivedVariantModel> get models; num get cartonCount;
/// Create a copy of ArchivedProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArchivedProductModelCopyWith<ArchivedProductModel> get copyWith => _$ArchivedProductModelCopyWithImpl<ArchivedProductModel>(this as ArchivedProductModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArchivedProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.models, models)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,unit,const DeepCollectionEquality().hash(models),cartonCount);

@override
String toString() {
  return 'ArchivedProductModel(id: $id, name: $name, unit: $unit, models: $models, cartonCount: $cartonCount)';
}


}

/// @nodoc
abstract mixin class $ArchivedProductModelCopyWith<$Res>  {
  factory $ArchivedProductModelCopyWith(ArchivedProductModel value, $Res Function(ArchivedProductModel) _then) = _$ArchivedProductModelCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? unit, List<ArchivedVariantModel> models, num cartonCount
});




}
/// @nodoc
class _$ArchivedProductModelCopyWithImpl<$Res>
    implements $ArchivedProductModelCopyWith<$Res> {
  _$ArchivedProductModelCopyWithImpl(this._self, this._then);

  final ArchivedProductModel _self;
  final $Res Function(ArchivedProductModel) _then;

/// Create a copy of ArchivedProductModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? unit = freezed,Object? models = null,Object? cartonCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<ArchivedVariantModel>,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [ArchivedProductModel].
extension ArchivedProductModelPatterns on ArchivedProductModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArchivedProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArchivedProductModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArchivedProductModel value)  $default,){
final _that = this;
switch (_that) {
case _ArchivedProductModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArchivedProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _ArchivedProductModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? unit,  List<ArchivedVariantModel> models,  num cartonCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArchivedProductModel() when $default != null:
return $default(_that.id,_that.name,_that.unit,_that.models,_that.cartonCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? unit,  List<ArchivedVariantModel> models,  num cartonCount)  $default,) {final _that = this;
switch (_that) {
case _ArchivedProductModel():
return $default(_that.id,_that.name,_that.unit,_that.models,_that.cartonCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? unit,  List<ArchivedVariantModel> models,  num cartonCount)?  $default,) {final _that = this;
switch (_that) {
case _ArchivedProductModel() when $default != null:
return $default(_that.id,_that.name,_that.unit,_that.models,_that.cartonCount);case _:
  return null;

}
}

}

/// @nodoc


class _ArchivedProductModel implements ArchivedProductModel {
  const _ArchivedProductModel({required this.id, this.name, this.unit, final  List<ArchivedVariantModel> models = const <ArchivedVariantModel>[], this.cartonCount = 0}): _models = models;
  

@override final  String id;
@override final  String? name;
@override final  String? unit;
 final  List<ArchivedVariantModel> _models;
@override@JsonKey() List<ArchivedVariantModel> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}

@override@JsonKey() final  num cartonCount;

/// Create a copy of ArchivedProductModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArchivedProductModelCopyWith<_ArchivedProductModel> get copyWith => __$ArchivedProductModelCopyWithImpl<_ArchivedProductModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArchivedProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other._models, _models)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,unit,const DeepCollectionEquality().hash(_models),cartonCount);

@override
String toString() {
  return 'ArchivedProductModel(id: $id, name: $name, unit: $unit, models: $models, cartonCount: $cartonCount)';
}


}

/// @nodoc
abstract mixin class _$ArchivedProductModelCopyWith<$Res> implements $ArchivedProductModelCopyWith<$Res> {
  factory _$ArchivedProductModelCopyWith(_ArchivedProductModel value, $Res Function(_ArchivedProductModel) _then) = __$ArchivedProductModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? unit, List<ArchivedVariantModel> models, num cartonCount
});




}
/// @nodoc
class __$ArchivedProductModelCopyWithImpl<$Res>
    implements _$ArchivedProductModelCopyWith<$Res> {
  __$ArchivedProductModelCopyWithImpl(this._self, this._then);

  final _ArchivedProductModel _self;
  final $Res Function(_ArchivedProductModel) _then;

/// Create a copy of ArchivedProductModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? unit = freezed,Object? models = null,Object? cartonCount = null,}) {
  return _then(_ArchivedProductModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<ArchivedVariantModel>,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$ArchivedVariantModel {

 String? get name;
/// Create a copy of ArchivedVariantModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArchivedVariantModelCopyWith<ArchivedVariantModel> get copyWith => _$ArchivedVariantModelCopyWithImpl<ArchivedVariantModel>(this as ArchivedVariantModel, _$identity);

  /// Serializes this ArchivedVariantModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArchivedVariantModel&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'ArchivedVariantModel(name: $name)';
}


}

/// @nodoc
abstract mixin class $ArchivedVariantModelCopyWith<$Res>  {
  factory $ArchivedVariantModelCopyWith(ArchivedVariantModel value, $Res Function(ArchivedVariantModel) _then) = _$ArchivedVariantModelCopyWithImpl;
@useResult
$Res call({
 String? name
});




}
/// @nodoc
class _$ArchivedVariantModelCopyWithImpl<$Res>
    implements $ArchivedVariantModelCopyWith<$Res> {
  _$ArchivedVariantModelCopyWithImpl(this._self, this._then);

  final ArchivedVariantModel _self;
  final $Res Function(ArchivedVariantModel) _then;

/// Create a copy of ArchivedVariantModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ArchivedVariantModel].
extension ArchivedVariantModelPatterns on ArchivedVariantModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArchivedVariantModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArchivedVariantModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArchivedVariantModel value)  $default,){
final _that = this;
switch (_that) {
case _ArchivedVariantModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArchivedVariantModel value)?  $default,){
final _that = this;
switch (_that) {
case _ArchivedVariantModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArchivedVariantModel() when $default != null:
return $default(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name)  $default,) {final _that = this;
switch (_that) {
case _ArchivedVariantModel():
return $default(_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name)?  $default,) {final _that = this;
switch (_that) {
case _ArchivedVariantModel() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ArchivedVariantModel implements ArchivedVariantModel {
  const _ArchivedVariantModel({this.name});
  factory _ArchivedVariantModel.fromJson(Map<String, dynamic> json) => _$ArchivedVariantModelFromJson(json);

@override final  String? name;

/// Create a copy of ArchivedVariantModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArchivedVariantModelCopyWith<_ArchivedVariantModel> get copyWith => __$ArchivedVariantModelCopyWithImpl<_ArchivedVariantModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArchivedVariantModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArchivedVariantModel&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'ArchivedVariantModel(name: $name)';
}


}

/// @nodoc
abstract mixin class _$ArchivedVariantModelCopyWith<$Res> implements $ArchivedVariantModelCopyWith<$Res> {
  factory _$ArchivedVariantModelCopyWith(_ArchivedVariantModel value, $Res Function(_ArchivedVariantModel) _then) = __$ArchivedVariantModelCopyWithImpl;
@override @useResult
$Res call({
 String? name
});




}
/// @nodoc
class __$ArchivedVariantModelCopyWithImpl<$Res>
    implements _$ArchivedVariantModelCopyWith<$Res> {
  __$ArchivedVariantModelCopyWithImpl(this._self, this._then);

  final _ArchivedVariantModel _self;
  final $Res Function(_ArchivedVariantModel) _then;

/// Create a copy of ArchivedVariantModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,}) {
  return _then(_ArchivedVariantModel(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ArchivedWarehouseModel {

 String get id; String? get name; num get cartonCount; num get orderCount;
/// Create a copy of ArchivedWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArchivedWarehouseModelCopyWith<ArchivedWarehouseModel> get copyWith => _$ArchivedWarehouseModelCopyWithImpl<ArchivedWarehouseModel>(this as ArchivedWarehouseModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArchivedWarehouseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,cartonCount,orderCount);

@override
String toString() {
  return 'ArchivedWarehouseModel(id: $id, name: $name, cartonCount: $cartonCount, orderCount: $orderCount)';
}


}

/// @nodoc
abstract mixin class $ArchivedWarehouseModelCopyWith<$Res>  {
  factory $ArchivedWarehouseModelCopyWith(ArchivedWarehouseModel value, $Res Function(ArchivedWarehouseModel) _then) = _$ArchivedWarehouseModelCopyWithImpl;
@useResult
$Res call({
 String id, String? name, num cartonCount, num orderCount
});




}
/// @nodoc
class _$ArchivedWarehouseModelCopyWithImpl<$Res>
    implements $ArchivedWarehouseModelCopyWith<$Res> {
  _$ArchivedWarehouseModelCopyWithImpl(this._self, this._then);

  final ArchivedWarehouseModel _self;
  final $Res Function(ArchivedWarehouseModel) _then;

/// Create a copy of ArchivedWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? cartonCount = null,Object? orderCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as num,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [ArchivedWarehouseModel].
extension ArchivedWarehouseModelPatterns on ArchivedWarehouseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArchivedWarehouseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArchivedWarehouseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArchivedWarehouseModel value)  $default,){
final _that = this;
switch (_that) {
case _ArchivedWarehouseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArchivedWarehouseModel value)?  $default,){
final _that = this;
switch (_that) {
case _ArchivedWarehouseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  num cartonCount,  num orderCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArchivedWarehouseModel() when $default != null:
return $default(_that.id,_that.name,_that.cartonCount,_that.orderCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  num cartonCount,  num orderCount)  $default,) {final _that = this;
switch (_that) {
case _ArchivedWarehouseModel():
return $default(_that.id,_that.name,_that.cartonCount,_that.orderCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  num cartonCount,  num orderCount)?  $default,) {final _that = this;
switch (_that) {
case _ArchivedWarehouseModel() when $default != null:
return $default(_that.id,_that.name,_that.cartonCount,_that.orderCount);case _:
  return null;

}
}

}

/// @nodoc


class _ArchivedWarehouseModel implements ArchivedWarehouseModel {
  const _ArchivedWarehouseModel({required this.id, this.name, this.cartonCount = 0, this.orderCount = 0});
  

@override final  String id;
@override final  String? name;
@override@JsonKey() final  num cartonCount;
@override@JsonKey() final  num orderCount;

/// Create a copy of ArchivedWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArchivedWarehouseModelCopyWith<_ArchivedWarehouseModel> get copyWith => __$ArchivedWarehouseModelCopyWithImpl<_ArchivedWarehouseModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArchivedWarehouseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,cartonCount,orderCount);

@override
String toString() {
  return 'ArchivedWarehouseModel(id: $id, name: $name, cartonCount: $cartonCount, orderCount: $orderCount)';
}


}

/// @nodoc
abstract mixin class _$ArchivedWarehouseModelCopyWith<$Res> implements $ArchivedWarehouseModelCopyWith<$Res> {
  factory _$ArchivedWarehouseModelCopyWith(_ArchivedWarehouseModel value, $Res Function(_ArchivedWarehouseModel) _then) = __$ArchivedWarehouseModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, num cartonCount, num orderCount
});




}
/// @nodoc
class __$ArchivedWarehouseModelCopyWithImpl<$Res>
    implements _$ArchivedWarehouseModelCopyWith<$Res> {
  __$ArchivedWarehouseModelCopyWithImpl(this._self, this._then);

  final _ArchivedWarehouseModel _self;
  final $Res Function(_ArchivedWarehouseModel) _then;

/// Create a copy of ArchivedWarehouseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? cartonCount = null,Object? orderCount = null,}) {
  return _then(_ArchivedWarehouseModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as num,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
