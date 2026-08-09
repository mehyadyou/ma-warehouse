// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_models_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductModelsData {

 ProductModelInfo? get product; List<ProductModelStockModel> get models;
/// Create a copy of ProductModelsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductModelsDataCopyWith<ProductModelsData> get copyWith => _$ProductModelsDataCopyWithImpl<ProductModelsData>(this as ProductModelsData, _$identity);

  /// Serializes this ProductModelsData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductModelsData&&(identical(other.product, product) || other.product == product)&&const DeepCollectionEquality().equals(other.models, models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,product,const DeepCollectionEquality().hash(models));

@override
String toString() {
  return 'ProductModelsData(product: $product, models: $models)';
}


}

/// @nodoc
abstract mixin class $ProductModelsDataCopyWith<$Res>  {
  factory $ProductModelsDataCopyWith(ProductModelsData value, $Res Function(ProductModelsData) _then) = _$ProductModelsDataCopyWithImpl;
@useResult
$Res call({
 ProductModelInfo? product, List<ProductModelStockModel> models
});


$ProductModelInfoCopyWith<$Res>? get product;

}
/// @nodoc
class _$ProductModelsDataCopyWithImpl<$Res>
    implements $ProductModelsDataCopyWith<$Res> {
  _$ProductModelsDataCopyWithImpl(this._self, this._then);

  final ProductModelsData _self;
  final $Res Function(ProductModelsData) _then;

/// Create a copy of ProductModelsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = freezed,Object? models = null,}) {
  return _then(_self.copyWith(
product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductModelInfo?,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<ProductModelStockModel>,
  ));
}
/// Create a copy of ProductModelsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductModelInfoCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $ProductModelInfoCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductModelsData].
extension ProductModelsDataPatterns on ProductModelsData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductModelsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductModelsData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductModelsData value)  $default,){
final _that = this;
switch (_that) {
case _ProductModelsData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductModelsData value)?  $default,){
final _that = this;
switch (_that) {
case _ProductModelsData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProductModelInfo? product,  List<ProductModelStockModel> models)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductModelsData() when $default != null:
return $default(_that.product,_that.models);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProductModelInfo? product,  List<ProductModelStockModel> models)  $default,) {final _that = this;
switch (_that) {
case _ProductModelsData():
return $default(_that.product,_that.models);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProductModelInfo? product,  List<ProductModelStockModel> models)?  $default,) {final _that = this;
switch (_that) {
case _ProductModelsData() when $default != null:
return $default(_that.product,_that.models);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductModelsData implements ProductModelsData {
  const _ProductModelsData({this.product, final  List<ProductModelStockModel> models = const <ProductModelStockModel>[]}): _models = models;
  factory _ProductModelsData.fromJson(Map<String, dynamic> json) => _$ProductModelsDataFromJson(json);

@override final  ProductModelInfo? product;
 final  List<ProductModelStockModel> _models;
@override@JsonKey() List<ProductModelStockModel> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}


/// Create a copy of ProductModelsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductModelsDataCopyWith<_ProductModelsData> get copyWith => __$ProductModelsDataCopyWithImpl<_ProductModelsData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductModelsDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductModelsData&&(identical(other.product, product) || other.product == product)&&const DeepCollectionEquality().equals(other._models, _models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,product,const DeepCollectionEquality().hash(_models));

@override
String toString() {
  return 'ProductModelsData(product: $product, models: $models)';
}


}

/// @nodoc
abstract mixin class _$ProductModelsDataCopyWith<$Res> implements $ProductModelsDataCopyWith<$Res> {
  factory _$ProductModelsDataCopyWith(_ProductModelsData value, $Res Function(_ProductModelsData) _then) = __$ProductModelsDataCopyWithImpl;
@override @useResult
$Res call({
 ProductModelInfo? product, List<ProductModelStockModel> models
});


@override $ProductModelInfoCopyWith<$Res>? get product;

}
/// @nodoc
class __$ProductModelsDataCopyWithImpl<$Res>
    implements _$ProductModelsDataCopyWith<$Res> {
  __$ProductModelsDataCopyWithImpl(this._self, this._then);

  final _ProductModelsData _self;
  final $Res Function(_ProductModelsData) _then;

/// Create a copy of ProductModelsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = freezed,Object? models = null,}) {
  return _then(_ProductModelsData(
product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductModelInfo?,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<ProductModelStockModel>,
  ));
}

/// Create a copy of ProductModelsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductModelInfoCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $ProductModelInfoCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// @nodoc
mixin _$ProductModelInfo {

 String? get id; String? get name; String? get unit;
/// Create a copy of ProductModelInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductModelInfoCopyWith<ProductModelInfo> get copyWith => _$ProductModelInfoCopyWithImpl<ProductModelInfo>(this as ProductModelInfo, _$identity);

  /// Serializes this ProductModelInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductModelInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,unit);

@override
String toString() {
  return 'ProductModelInfo(id: $id, name: $name, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $ProductModelInfoCopyWith<$Res>  {
  factory $ProductModelInfoCopyWith(ProductModelInfo value, $Res Function(ProductModelInfo) _then) = _$ProductModelInfoCopyWithImpl;
@useResult
$Res call({
 String? id, String? name, String? unit
});




}
/// @nodoc
class _$ProductModelInfoCopyWithImpl<$Res>
    implements $ProductModelInfoCopyWith<$Res> {
  _$ProductModelInfoCopyWithImpl(this._self, this._then);

  final ProductModelInfo _self;
  final $Res Function(ProductModelInfo) _then;

/// Create a copy of ProductModelInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? unit = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductModelInfo].
extension ProductModelInfoPatterns on ProductModelInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductModelInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductModelInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductModelInfo value)  $default,){
final _that = this;
switch (_that) {
case _ProductModelInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductModelInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ProductModelInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name,  String? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductModelInfo() when $default != null:
return $default(_that.id,_that.name,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name,  String? unit)  $default,) {final _that = this;
switch (_that) {
case _ProductModelInfo():
return $default(_that.id,_that.name,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name,  String? unit)?  $default,) {final _that = this;
switch (_that) {
case _ProductModelInfo() when $default != null:
return $default(_that.id,_that.name,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductModelInfo implements ProductModelInfo {
  const _ProductModelInfo({this.id, this.name, this.unit});
  factory _ProductModelInfo.fromJson(Map<String, dynamic> json) => _$ProductModelInfoFromJson(json);

@override final  String? id;
@override final  String? name;
@override final  String? unit;

/// Create a copy of ProductModelInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductModelInfoCopyWith<_ProductModelInfo> get copyWith => __$ProductModelInfoCopyWithImpl<_ProductModelInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductModelInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductModelInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,unit);

@override
String toString() {
  return 'ProductModelInfo(id: $id, name: $name, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$ProductModelInfoCopyWith<$Res> implements $ProductModelInfoCopyWith<$Res> {
  factory _$ProductModelInfoCopyWith(_ProductModelInfo value, $Res Function(_ProductModelInfo) _then) = __$ProductModelInfoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name, String? unit
});




}
/// @nodoc
class __$ProductModelInfoCopyWithImpl<$Res>
    implements _$ProductModelInfoCopyWith<$Res> {
  __$ProductModelInfoCopyWithImpl(this._self, this._then);

  final _ProductModelInfo _self;
  final $Res Function(_ProductModelInfo) _then;

/// Create a copy of ProductModelInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? unit = freezed,}) {
  return _then(_ProductModelInfo(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductModelStockModel {

 String? get modelId; String? get name; String? get packageType; num? get unitsPerBox; num get count; List<ModelWarehouseRowModel> get warehouses;
/// Create a copy of ProductModelStockModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductModelStockModelCopyWith<ProductModelStockModel> get copyWith => _$ProductModelStockModelCopyWithImpl<ProductModelStockModel>(this as ProductModelStockModel, _$identity);

  /// Serializes this ProductModelStockModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductModelStockModel&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.packageType, packageType) || other.packageType == packageType)&&(identical(other.unitsPerBox, unitsPerBox) || other.unitsPerBox == unitsPerBox)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.warehouses, warehouses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,modelId,name,packageType,unitsPerBox,count,const DeepCollectionEquality().hash(warehouses));

@override
String toString() {
  return 'ProductModelStockModel(modelId: $modelId, name: $name, packageType: $packageType, unitsPerBox: $unitsPerBox, count: $count, warehouses: $warehouses)';
}


}

/// @nodoc
abstract mixin class $ProductModelStockModelCopyWith<$Res>  {
  factory $ProductModelStockModelCopyWith(ProductModelStockModel value, $Res Function(ProductModelStockModel) _then) = _$ProductModelStockModelCopyWithImpl;
@useResult
$Res call({
 String? modelId, String? name, String? packageType, num? unitsPerBox, num count, List<ModelWarehouseRowModel> warehouses
});




}
/// @nodoc
class _$ProductModelStockModelCopyWithImpl<$Res>
    implements $ProductModelStockModelCopyWith<$Res> {
  _$ProductModelStockModelCopyWithImpl(this._self, this._then);

  final ProductModelStockModel _self;
  final $Res Function(ProductModelStockModel) _then;

/// Create a copy of ProductModelStockModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? modelId = freezed,Object? name = freezed,Object? packageType = freezed,Object? unitsPerBox = freezed,Object? count = null,Object? warehouses = null,}) {
  return _then(_self.copyWith(
modelId: freezed == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,unitsPerBox: freezed == unitsPerBox ? _self.unitsPerBox : unitsPerBox // ignore: cast_nullable_to_non_nullable
as num?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,warehouses: null == warehouses ? _self.warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<ModelWarehouseRowModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductModelStockModel].
extension ProductModelStockModelPatterns on ProductModelStockModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductModelStockModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductModelStockModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductModelStockModel value)  $default,){
final _that = this;
switch (_that) {
case _ProductModelStockModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductModelStockModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProductModelStockModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? modelId,  String? name,  String? packageType,  num? unitsPerBox,  num count,  List<ModelWarehouseRowModel> warehouses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductModelStockModel() when $default != null:
return $default(_that.modelId,_that.name,_that.packageType,_that.unitsPerBox,_that.count,_that.warehouses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? modelId,  String? name,  String? packageType,  num? unitsPerBox,  num count,  List<ModelWarehouseRowModel> warehouses)  $default,) {final _that = this;
switch (_that) {
case _ProductModelStockModel():
return $default(_that.modelId,_that.name,_that.packageType,_that.unitsPerBox,_that.count,_that.warehouses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? modelId,  String? name,  String? packageType,  num? unitsPerBox,  num count,  List<ModelWarehouseRowModel> warehouses)?  $default,) {final _that = this;
switch (_that) {
case _ProductModelStockModel() when $default != null:
return $default(_that.modelId,_that.name,_that.packageType,_that.unitsPerBox,_that.count,_that.warehouses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductModelStockModel implements ProductModelStockModel {
  const _ProductModelStockModel({this.modelId, this.name, this.packageType, this.unitsPerBox, this.count = 0, final  List<ModelWarehouseRowModel> warehouses = const <ModelWarehouseRowModel>[]}): _warehouses = warehouses;
  factory _ProductModelStockModel.fromJson(Map<String, dynamic> json) => _$ProductModelStockModelFromJson(json);

@override final  String? modelId;
@override final  String? name;
@override final  String? packageType;
@override final  num? unitsPerBox;
@override@JsonKey() final  num count;
 final  List<ModelWarehouseRowModel> _warehouses;
@override@JsonKey() List<ModelWarehouseRowModel> get warehouses {
  if (_warehouses is EqualUnmodifiableListView) return _warehouses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warehouses);
}


/// Create a copy of ProductModelStockModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductModelStockModelCopyWith<_ProductModelStockModel> get copyWith => __$ProductModelStockModelCopyWithImpl<_ProductModelStockModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductModelStockModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductModelStockModel&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.packageType, packageType) || other.packageType == packageType)&&(identical(other.unitsPerBox, unitsPerBox) || other.unitsPerBox == unitsPerBox)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._warehouses, _warehouses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,modelId,name,packageType,unitsPerBox,count,const DeepCollectionEquality().hash(_warehouses));

@override
String toString() {
  return 'ProductModelStockModel(modelId: $modelId, name: $name, packageType: $packageType, unitsPerBox: $unitsPerBox, count: $count, warehouses: $warehouses)';
}


}

/// @nodoc
abstract mixin class _$ProductModelStockModelCopyWith<$Res> implements $ProductModelStockModelCopyWith<$Res> {
  factory _$ProductModelStockModelCopyWith(_ProductModelStockModel value, $Res Function(_ProductModelStockModel) _then) = __$ProductModelStockModelCopyWithImpl;
@override @useResult
$Res call({
 String? modelId, String? name, String? packageType, num? unitsPerBox, num count, List<ModelWarehouseRowModel> warehouses
});




}
/// @nodoc
class __$ProductModelStockModelCopyWithImpl<$Res>
    implements _$ProductModelStockModelCopyWith<$Res> {
  __$ProductModelStockModelCopyWithImpl(this._self, this._then);

  final _ProductModelStockModel _self;
  final $Res Function(_ProductModelStockModel) _then;

/// Create a copy of ProductModelStockModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? modelId = freezed,Object? name = freezed,Object? packageType = freezed,Object? unitsPerBox = freezed,Object? count = null,Object? warehouses = null,}) {
  return _then(_ProductModelStockModel(
modelId: freezed == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,unitsPerBox: freezed == unitsPerBox ? _self.unitsPerBox : unitsPerBox // ignore: cast_nullable_to_non_nullable
as num?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,warehouses: null == warehouses ? _self._warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<ModelWarehouseRowModel>,
  ));
}


}


/// @nodoc
mixin _$ModelWarehouseRowModel {

 String? get warehouseId; String? get warehouseName; num get count;
/// Create a copy of ModelWarehouseRowModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelWarehouseRowModelCopyWith<ModelWarehouseRowModel> get copyWith => _$ModelWarehouseRowModelCopyWithImpl<ModelWarehouseRowModel>(this as ModelWarehouseRowModel, _$identity);

  /// Serializes this ModelWarehouseRowModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelWarehouseRowModel&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseId,warehouseName,count);

@override
String toString() {
  return 'ModelWarehouseRowModel(warehouseId: $warehouseId, warehouseName: $warehouseName, count: $count)';
}


}

/// @nodoc
abstract mixin class $ModelWarehouseRowModelCopyWith<$Res>  {
  factory $ModelWarehouseRowModelCopyWith(ModelWarehouseRowModel value, $Res Function(ModelWarehouseRowModel) _then) = _$ModelWarehouseRowModelCopyWithImpl;
@useResult
$Res call({
 String? warehouseId, String? warehouseName, num count
});




}
/// @nodoc
class _$ModelWarehouseRowModelCopyWithImpl<$Res>
    implements $ModelWarehouseRowModelCopyWith<$Res> {
  _$ModelWarehouseRowModelCopyWithImpl(this._self, this._then);

  final ModelWarehouseRowModel _self;
  final $Res Function(ModelWarehouseRowModel) _then;

/// Create a copy of ModelWarehouseRowModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warehouseId = freezed,Object? warehouseName = freezed,Object? count = null,}) {
  return _then(_self.copyWith(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelWarehouseRowModel].
extension ModelWarehouseRowModelPatterns on ModelWarehouseRowModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelWarehouseRowModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelWarehouseRowModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelWarehouseRowModel value)  $default,){
final _that = this;
switch (_that) {
case _ModelWarehouseRowModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelWarehouseRowModel value)?  $default,){
final _that = this;
switch (_that) {
case _ModelWarehouseRowModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? warehouseId,  String? warehouseName,  num count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelWarehouseRowModel() when $default != null:
return $default(_that.warehouseId,_that.warehouseName,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? warehouseId,  String? warehouseName,  num count)  $default,) {final _that = this;
switch (_that) {
case _ModelWarehouseRowModel():
return $default(_that.warehouseId,_that.warehouseName,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? warehouseId,  String? warehouseName,  num count)?  $default,) {final _that = this;
switch (_that) {
case _ModelWarehouseRowModel() when $default != null:
return $default(_that.warehouseId,_that.warehouseName,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelWarehouseRowModel implements ModelWarehouseRowModel {
  const _ModelWarehouseRowModel({this.warehouseId, this.warehouseName, this.count = 0});
  factory _ModelWarehouseRowModel.fromJson(Map<String, dynamic> json) => _$ModelWarehouseRowModelFromJson(json);

@override final  String? warehouseId;
@override final  String? warehouseName;
@override@JsonKey() final  num count;

/// Create a copy of ModelWarehouseRowModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelWarehouseRowModelCopyWith<_ModelWarehouseRowModel> get copyWith => __$ModelWarehouseRowModelCopyWithImpl<_ModelWarehouseRowModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelWarehouseRowModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelWarehouseRowModel&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseId,warehouseName,count);

@override
String toString() {
  return 'ModelWarehouseRowModel(warehouseId: $warehouseId, warehouseName: $warehouseName, count: $count)';
}


}

/// @nodoc
abstract mixin class _$ModelWarehouseRowModelCopyWith<$Res> implements $ModelWarehouseRowModelCopyWith<$Res> {
  factory _$ModelWarehouseRowModelCopyWith(_ModelWarehouseRowModel value, $Res Function(_ModelWarehouseRowModel) _then) = __$ModelWarehouseRowModelCopyWithImpl;
@override @useResult
$Res call({
 String? warehouseId, String? warehouseName, num count
});




}
/// @nodoc
class __$ModelWarehouseRowModelCopyWithImpl<$Res>
    implements _$ModelWarehouseRowModelCopyWith<$Res> {
  __$ModelWarehouseRowModelCopyWithImpl(this._self, this._then);

  final _ModelWarehouseRowModel _self;
  final $Res Function(_ModelWarehouseRowModel) _then;

/// Create a copy of ModelWarehouseRowModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warehouseId = freezed,Object? warehouseName = freezed,Object? count = null,}) {
  return _then(_ModelWarehouseRowModel(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
