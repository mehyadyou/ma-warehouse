// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keeper_product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KeeperProductModel {

 String get id; String get name; String? get unit; List<KeeperProductVariantModel> get models;
/// Create a copy of KeeperProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperProductModelCopyWith<KeeperProductModel> get copyWith => _$KeeperProductModelCopyWithImpl<KeeperProductModel>(this as KeeperProductModel, _$identity);

  /// Serializes this KeeperProductModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.models, models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,unit,const DeepCollectionEquality().hash(models));

@override
String toString() {
  return 'KeeperProductModel(id: $id, name: $name, unit: $unit, models: $models)';
}


}

/// @nodoc
abstract mixin class $KeeperProductModelCopyWith<$Res>  {
  factory $KeeperProductModelCopyWith(KeeperProductModel value, $Res Function(KeeperProductModel) _then) = _$KeeperProductModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? unit, List<KeeperProductVariantModel> models
});




}
/// @nodoc
class _$KeeperProductModelCopyWithImpl<$Res>
    implements $KeeperProductModelCopyWith<$Res> {
  _$KeeperProductModelCopyWithImpl(this._self, this._then);

  final KeeperProductModel _self;
  final $Res Function(KeeperProductModel) _then;

/// Create a copy of KeeperProductModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? unit = freezed,Object? models = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<KeeperProductVariantModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperProductModel].
extension KeeperProductModelPatterns on KeeperProductModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperProductModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperProductModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperProductModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperProductModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? unit,  List<KeeperProductVariantModel> models)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperProductModel() when $default != null:
return $default(_that.id,_that.name,_that.unit,_that.models);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? unit,  List<KeeperProductVariantModel> models)  $default,) {final _that = this;
switch (_that) {
case _KeeperProductModel():
return $default(_that.id,_that.name,_that.unit,_that.models);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? unit,  List<KeeperProductVariantModel> models)?  $default,) {final _that = this;
switch (_that) {
case _KeeperProductModel() when $default != null:
return $default(_that.id,_that.name,_that.unit,_that.models);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperProductModel implements KeeperProductModel {
  const _KeeperProductModel({this.id = '', this.name = '', this.unit, final  List<KeeperProductVariantModel> models = const <KeeperProductVariantModel>[]}): _models = models;
  factory _KeeperProductModel.fromJson(Map<String, dynamic> json) => _$KeeperProductModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override final  String? unit;
 final  List<KeeperProductVariantModel> _models;
@override@JsonKey() List<KeeperProductVariantModel> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}


/// Create a copy of KeeperProductModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperProductModelCopyWith<_KeeperProductModel> get copyWith => __$KeeperProductModelCopyWithImpl<_KeeperProductModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperProductModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other._models, _models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,unit,const DeepCollectionEquality().hash(_models));

@override
String toString() {
  return 'KeeperProductModel(id: $id, name: $name, unit: $unit, models: $models)';
}


}

/// @nodoc
abstract mixin class _$KeeperProductModelCopyWith<$Res> implements $KeeperProductModelCopyWith<$Res> {
  factory _$KeeperProductModelCopyWith(_KeeperProductModel value, $Res Function(_KeeperProductModel) _then) = __$KeeperProductModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? unit, List<KeeperProductVariantModel> models
});




}
/// @nodoc
class __$KeeperProductModelCopyWithImpl<$Res>
    implements _$KeeperProductModelCopyWith<$Res> {
  __$KeeperProductModelCopyWithImpl(this._self, this._then);

  final _KeeperProductModel _self;
  final $Res Function(_KeeperProductModel) _then;

/// Create a copy of KeeperProductModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? unit = freezed,Object? models = null,}) {
  return _then(_KeeperProductModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<KeeperProductVariantModel>,
  ));
}


}


/// @nodoc
mixin _$KeeperProductVariantModel {

 String get id; String get name; num? get unitsPerBox; String? get packageType;
/// Create a copy of KeeperProductVariantModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperProductVariantModelCopyWith<KeeperProductVariantModel> get copyWith => _$KeeperProductVariantModelCopyWithImpl<KeeperProductVariantModel>(this as KeeperProductVariantModel, _$identity);

  /// Serializes this KeeperProductVariantModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperProductVariantModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitsPerBox, unitsPerBox) || other.unitsPerBox == unitsPerBox)&&(identical(other.packageType, packageType) || other.packageType == packageType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,unitsPerBox,packageType);

@override
String toString() {
  return 'KeeperProductVariantModel(id: $id, name: $name, unitsPerBox: $unitsPerBox, packageType: $packageType)';
}


}

/// @nodoc
abstract mixin class $KeeperProductVariantModelCopyWith<$Res>  {
  factory $KeeperProductVariantModelCopyWith(KeeperProductVariantModel value, $Res Function(KeeperProductVariantModel) _then) = _$KeeperProductVariantModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, num? unitsPerBox, String? packageType
});




}
/// @nodoc
class _$KeeperProductVariantModelCopyWithImpl<$Res>
    implements $KeeperProductVariantModelCopyWith<$Res> {
  _$KeeperProductVariantModelCopyWithImpl(this._self, this._then);

  final KeeperProductVariantModel _self;
  final $Res Function(KeeperProductVariantModel) _then;

/// Create a copy of KeeperProductVariantModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? unitsPerBox = freezed,Object? packageType = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitsPerBox: freezed == unitsPerBox ? _self.unitsPerBox : unitsPerBox // ignore: cast_nullable_to_non_nullable
as num?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperProductVariantModel].
extension KeeperProductVariantModelPatterns on KeeperProductVariantModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperProductVariantModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperProductVariantModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperProductVariantModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperProductVariantModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperProductVariantModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperProductVariantModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  num? unitsPerBox,  String? packageType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperProductVariantModel() when $default != null:
return $default(_that.id,_that.name,_that.unitsPerBox,_that.packageType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  num? unitsPerBox,  String? packageType)  $default,) {final _that = this;
switch (_that) {
case _KeeperProductVariantModel():
return $default(_that.id,_that.name,_that.unitsPerBox,_that.packageType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  num? unitsPerBox,  String? packageType)?  $default,) {final _that = this;
switch (_that) {
case _KeeperProductVariantModel() when $default != null:
return $default(_that.id,_that.name,_that.unitsPerBox,_that.packageType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperProductVariantModel implements KeeperProductVariantModel {
  const _KeeperProductVariantModel({this.id = '', this.name = '', this.unitsPerBox, this.packageType});
  factory _KeeperProductVariantModel.fromJson(Map<String, dynamic> json) => _$KeeperProductVariantModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override final  num? unitsPerBox;
@override final  String? packageType;

/// Create a copy of KeeperProductVariantModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperProductVariantModelCopyWith<_KeeperProductVariantModel> get copyWith => __$KeeperProductVariantModelCopyWithImpl<_KeeperProductVariantModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperProductVariantModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperProductVariantModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitsPerBox, unitsPerBox) || other.unitsPerBox == unitsPerBox)&&(identical(other.packageType, packageType) || other.packageType == packageType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,unitsPerBox,packageType);

@override
String toString() {
  return 'KeeperProductVariantModel(id: $id, name: $name, unitsPerBox: $unitsPerBox, packageType: $packageType)';
}


}

/// @nodoc
abstract mixin class _$KeeperProductVariantModelCopyWith<$Res> implements $KeeperProductVariantModelCopyWith<$Res> {
  factory _$KeeperProductVariantModelCopyWith(_KeeperProductVariantModel value, $Res Function(_KeeperProductVariantModel) _then) = __$KeeperProductVariantModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, num? unitsPerBox, String? packageType
});




}
/// @nodoc
class __$KeeperProductVariantModelCopyWithImpl<$Res>
    implements _$KeeperProductVariantModelCopyWith<$Res> {
  __$KeeperProductVariantModelCopyWithImpl(this._self, this._then);

  final _KeeperProductVariantModel _self;
  final $Res Function(_KeeperProductVariantModel) _then;

/// Create a copy of KeeperProductVariantModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? unitsPerBox = freezed,Object? packageType = freezed,}) {
  return _then(_KeeperProductVariantModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitsPerBox: freezed == unitsPerBox ? _self.unitsPerBox : unitsPerBox // ignore: cast_nullable_to_non_nullable
as num?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
