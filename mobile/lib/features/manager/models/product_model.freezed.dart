// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductModel {

 String get id; String get name; String? get unit; List<ProductVariantModel> get models;
/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductModelCopyWith<ProductModel> get copyWith => _$ProductModelCopyWithImpl<ProductModel>(this as ProductModel, _$identity);

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.models, models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,unit,const DeepCollectionEquality().hash(models));

@override
String toString() {
  return 'ProductModel(id: $id, name: $name, unit: $unit, models: $models)';
}


}

/// @nodoc
abstract mixin class $ProductModelCopyWith<$Res>  {
  factory $ProductModelCopyWith(ProductModel value, $Res Function(ProductModel) _then) = _$ProductModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? unit, List<ProductVariantModel> models
});




}
/// @nodoc
class _$ProductModelCopyWithImpl<$Res>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._self, this._then);

  final ProductModel _self;
  final $Res Function(ProductModel) _then;

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? unit = freezed,Object? models = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<ProductVariantModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductModel].
extension ProductModelPatterns on ProductModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductModel value)  $default,){
final _that = this;
switch (_that) {
case _ProductModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? unit,  List<ProductVariantModel> models)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? unit,  List<ProductVariantModel> models)  $default,) {final _that = this;
switch (_that) {
case _ProductModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? unit,  List<ProductVariantModel> models)?  $default,) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.id,_that.name,_that.unit,_that.models);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductModel implements ProductModel {
  const _ProductModel({required this.id, required this.name, this.unit, final  List<ProductVariantModel> models = const []}): _models = models;
  factory _ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? unit;
 final  List<ProductVariantModel> _models;
@override@JsonKey() List<ProductVariantModel> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}


/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductModelCopyWith<_ProductModel> get copyWith => __$ProductModelCopyWithImpl<_ProductModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other._models, _models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,unit,const DeepCollectionEquality().hash(_models));

@override
String toString() {
  return 'ProductModel(id: $id, name: $name, unit: $unit, models: $models)';
}


}

/// @nodoc
abstract mixin class _$ProductModelCopyWith<$Res> implements $ProductModelCopyWith<$Res> {
  factory _$ProductModelCopyWith(_ProductModel value, $Res Function(_ProductModel) _then) = __$ProductModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? unit, List<ProductVariantModel> models
});




}
/// @nodoc
class __$ProductModelCopyWithImpl<$Res>
    implements _$ProductModelCopyWith<$Res> {
  __$ProductModelCopyWithImpl(this._self, this._then);

  final _ProductModel _self;
  final $Res Function(_ProductModel) _then;

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? unit = freezed,Object? models = null,}) {
  return _then(_ProductModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<ProductVariantModel>,
  ));
}


}


/// @nodoc
mixin _$ProductVariantModel {

 String get id; String get name;@JsonKey(fromJson: _toDouble) double? get price;@JsonKey(fromJson: _toNum) num? get unitsPerBox; String? get packageType;
/// Create a copy of ProductVariantModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductVariantModelCopyWith<ProductVariantModel> get copyWith => _$ProductVariantModelCopyWithImpl<ProductVariantModel>(this as ProductVariantModel, _$identity);

  /// Serializes this ProductVariantModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductVariantModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.unitsPerBox, unitsPerBox) || other.unitsPerBox == unitsPerBox)&&(identical(other.packageType, packageType) || other.packageType == packageType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,unitsPerBox,packageType);

@override
String toString() {
  return 'ProductVariantModel(id: $id, name: $name, price: $price, unitsPerBox: $unitsPerBox, packageType: $packageType)';
}


}

/// @nodoc
abstract mixin class $ProductVariantModelCopyWith<$Res>  {
  factory $ProductVariantModelCopyWith(ProductVariantModel value, $Res Function(ProductVariantModel) _then) = _$ProductVariantModelCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _toDouble) double? price,@JsonKey(fromJson: _toNum) num? unitsPerBox, String? packageType
});




}
/// @nodoc
class _$ProductVariantModelCopyWithImpl<$Res>
    implements $ProductVariantModelCopyWith<$Res> {
  _$ProductVariantModelCopyWithImpl(this._self, this._then);

  final ProductVariantModel _self;
  final $Res Function(ProductVariantModel) _then;

/// Create a copy of ProductVariantModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = freezed,Object? unitsPerBox = freezed,Object? packageType = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,unitsPerBox: freezed == unitsPerBox ? _self.unitsPerBox : unitsPerBox // ignore: cast_nullable_to_non_nullable
as num?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductVariantModel].
extension ProductVariantModelPatterns on ProductVariantModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductVariantModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductVariantModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductVariantModel value)  $default,){
final _that = this;
switch (_that) {
case _ProductVariantModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductVariantModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProductVariantModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _toDouble)  double? price, @JsonKey(fromJson: _toNum)  num? unitsPerBox,  String? packageType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductVariantModel() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.unitsPerBox,_that.packageType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _toDouble)  double? price, @JsonKey(fromJson: _toNum)  num? unitsPerBox,  String? packageType)  $default,) {final _that = this;
switch (_that) {
case _ProductVariantModel():
return $default(_that.id,_that.name,_that.price,_that.unitsPerBox,_that.packageType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(fromJson: _toDouble)  double? price, @JsonKey(fromJson: _toNum)  num? unitsPerBox,  String? packageType)?  $default,) {final _that = this;
switch (_that) {
case _ProductVariantModel() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.unitsPerBox,_that.packageType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductVariantModel implements ProductVariantModel {
  const _ProductVariantModel({required this.id, required this.name, @JsonKey(fromJson: _toDouble) this.price, @JsonKey(fromJson: _toNum) this.unitsPerBox, this.packageType});
  factory _ProductVariantModel.fromJson(Map<String, dynamic> json) => _$ProductVariantModelFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(fromJson: _toDouble) final  double? price;
@override@JsonKey(fromJson: _toNum) final  num? unitsPerBox;
@override final  String? packageType;

/// Create a copy of ProductVariantModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductVariantModelCopyWith<_ProductVariantModel> get copyWith => __$ProductVariantModelCopyWithImpl<_ProductVariantModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductVariantModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductVariantModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.unitsPerBox, unitsPerBox) || other.unitsPerBox == unitsPerBox)&&(identical(other.packageType, packageType) || other.packageType == packageType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,unitsPerBox,packageType);

@override
String toString() {
  return 'ProductVariantModel(id: $id, name: $name, price: $price, unitsPerBox: $unitsPerBox, packageType: $packageType)';
}


}

/// @nodoc
abstract mixin class _$ProductVariantModelCopyWith<$Res> implements $ProductVariantModelCopyWith<$Res> {
  factory _$ProductVariantModelCopyWith(_ProductVariantModel value, $Res Function(_ProductVariantModel) _then) = __$ProductVariantModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _toDouble) double? price,@JsonKey(fromJson: _toNum) num? unitsPerBox, String? packageType
});




}
/// @nodoc
class __$ProductVariantModelCopyWithImpl<$Res>
    implements _$ProductVariantModelCopyWith<$Res> {
  __$ProductVariantModelCopyWithImpl(this._self, this._then);

  final _ProductVariantModel _self;
  final $Res Function(_ProductVariantModel) _then;

/// Create a copy of ProductVariantModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = freezed,Object? unitsPerBox = freezed,Object? packageType = freezed,}) {
  return _then(_ProductVariantModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,unitsPerBox: freezed == unitsPerBox ? _self.unitsPerBox : unitsPerBox // ignore: cast_nullable_to_non_nullable
as num?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
