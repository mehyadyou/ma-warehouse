// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keeper_inventory_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KeeperInventorySummaryModel {

 int get totalUnits; int get totalProducts; int get totalModels; int get returnedUnits; int get totalCartons; int get shippedUnits; List<KeeperInventoryProductModel> get products;
/// Create a copy of KeeperInventorySummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperInventorySummaryModelCopyWith<KeeperInventorySummaryModel> get copyWith => _$KeeperInventorySummaryModelCopyWithImpl<KeeperInventorySummaryModel>(this as KeeperInventorySummaryModel, _$identity);

  /// Serializes this KeeperInventorySummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperInventorySummaryModel&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.totalProducts, totalProducts) || other.totalProducts == totalProducts)&&(identical(other.totalModels, totalModels) || other.totalModels == totalModels)&&(identical(other.returnedUnits, returnedUnits) || other.returnedUnits == returnedUnits)&&(identical(other.totalCartons, totalCartons) || other.totalCartons == totalCartons)&&(identical(other.shippedUnits, shippedUnits) || other.shippedUnits == shippedUnits)&&const DeepCollectionEquality().equals(other.products, products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUnits,totalProducts,totalModels,returnedUnits,totalCartons,shippedUnits,const DeepCollectionEquality().hash(products));

@override
String toString() {
  return 'KeeperInventorySummaryModel(totalUnits: $totalUnits, totalProducts: $totalProducts, totalModels: $totalModels, returnedUnits: $returnedUnits, totalCartons: $totalCartons, shippedUnits: $shippedUnits, products: $products)';
}


}

/// @nodoc
abstract mixin class $KeeperInventorySummaryModelCopyWith<$Res>  {
  factory $KeeperInventorySummaryModelCopyWith(KeeperInventorySummaryModel value, $Res Function(KeeperInventorySummaryModel) _then) = _$KeeperInventorySummaryModelCopyWithImpl;
@useResult
$Res call({
 int totalUnits, int totalProducts, int totalModels, int returnedUnits, int totalCartons, int shippedUnits, List<KeeperInventoryProductModel> products
});




}
/// @nodoc
class _$KeeperInventorySummaryModelCopyWithImpl<$Res>
    implements $KeeperInventorySummaryModelCopyWith<$Res> {
  _$KeeperInventorySummaryModelCopyWithImpl(this._self, this._then);

  final KeeperInventorySummaryModel _self;
  final $Res Function(KeeperInventorySummaryModel) _then;

/// Create a copy of KeeperInventorySummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUnits = null,Object? totalProducts = null,Object? totalModels = null,Object? returnedUnits = null,Object? totalCartons = null,Object? shippedUnits = null,Object? products = null,}) {
  return _then(_self.copyWith(
totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as int,totalProducts: null == totalProducts ? _self.totalProducts : totalProducts // ignore: cast_nullable_to_non_nullable
as int,totalModels: null == totalModels ? _self.totalModels : totalModels // ignore: cast_nullable_to_non_nullable
as int,returnedUnits: null == returnedUnits ? _self.returnedUnits : returnedUnits // ignore: cast_nullable_to_non_nullable
as int,totalCartons: null == totalCartons ? _self.totalCartons : totalCartons // ignore: cast_nullable_to_non_nullable
as int,shippedUnits: null == shippedUnits ? _self.shippedUnits : shippedUnits // ignore: cast_nullable_to_non_nullable
as int,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<KeeperInventoryProductModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperInventorySummaryModel].
extension KeeperInventorySummaryModelPatterns on KeeperInventorySummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperInventorySummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperInventorySummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperInventorySummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperInventorySummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperInventorySummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperInventorySummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalUnits,  int totalProducts,  int totalModels,  int returnedUnits,  int totalCartons,  int shippedUnits,  List<KeeperInventoryProductModel> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperInventorySummaryModel() when $default != null:
return $default(_that.totalUnits,_that.totalProducts,_that.totalModels,_that.returnedUnits,_that.totalCartons,_that.shippedUnits,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalUnits,  int totalProducts,  int totalModels,  int returnedUnits,  int totalCartons,  int shippedUnits,  List<KeeperInventoryProductModel> products)  $default,) {final _that = this;
switch (_that) {
case _KeeperInventorySummaryModel():
return $default(_that.totalUnits,_that.totalProducts,_that.totalModels,_that.returnedUnits,_that.totalCartons,_that.shippedUnits,_that.products);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalUnits,  int totalProducts,  int totalModels,  int returnedUnits,  int totalCartons,  int shippedUnits,  List<KeeperInventoryProductModel> products)?  $default,) {final _that = this;
switch (_that) {
case _KeeperInventorySummaryModel() when $default != null:
return $default(_that.totalUnits,_that.totalProducts,_that.totalModels,_that.returnedUnits,_that.totalCartons,_that.shippedUnits,_that.products);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperInventorySummaryModel implements KeeperInventorySummaryModel {
  const _KeeperInventorySummaryModel({this.totalUnits = 0, this.totalProducts = 0, this.totalModels = 0, this.returnedUnits = 0, this.totalCartons = 0, this.shippedUnits = 0, final  List<KeeperInventoryProductModel> products = const <KeeperInventoryProductModel>[]}): _products = products;
  factory _KeeperInventorySummaryModel.fromJson(Map<String, dynamic> json) => _$KeeperInventorySummaryModelFromJson(json);

@override@JsonKey() final  int totalUnits;
@override@JsonKey() final  int totalProducts;
@override@JsonKey() final  int totalModels;
@override@JsonKey() final  int returnedUnits;
@override@JsonKey() final  int totalCartons;
@override@JsonKey() final  int shippedUnits;
 final  List<KeeperInventoryProductModel> _products;
@override@JsonKey() List<KeeperInventoryProductModel> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of KeeperInventorySummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperInventorySummaryModelCopyWith<_KeeperInventorySummaryModel> get copyWith => __$KeeperInventorySummaryModelCopyWithImpl<_KeeperInventorySummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperInventorySummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperInventorySummaryModel&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.totalProducts, totalProducts) || other.totalProducts == totalProducts)&&(identical(other.totalModels, totalModels) || other.totalModels == totalModels)&&(identical(other.returnedUnits, returnedUnits) || other.returnedUnits == returnedUnits)&&(identical(other.totalCartons, totalCartons) || other.totalCartons == totalCartons)&&(identical(other.shippedUnits, shippedUnits) || other.shippedUnits == shippedUnits)&&const DeepCollectionEquality().equals(other._products, _products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUnits,totalProducts,totalModels,returnedUnits,totalCartons,shippedUnits,const DeepCollectionEquality().hash(_products));

@override
String toString() {
  return 'KeeperInventorySummaryModel(totalUnits: $totalUnits, totalProducts: $totalProducts, totalModels: $totalModels, returnedUnits: $returnedUnits, totalCartons: $totalCartons, shippedUnits: $shippedUnits, products: $products)';
}


}

/// @nodoc
abstract mixin class _$KeeperInventorySummaryModelCopyWith<$Res> implements $KeeperInventorySummaryModelCopyWith<$Res> {
  factory _$KeeperInventorySummaryModelCopyWith(_KeeperInventorySummaryModel value, $Res Function(_KeeperInventorySummaryModel) _then) = __$KeeperInventorySummaryModelCopyWithImpl;
@override @useResult
$Res call({
 int totalUnits, int totalProducts, int totalModels, int returnedUnits, int totalCartons, int shippedUnits, List<KeeperInventoryProductModel> products
});




}
/// @nodoc
class __$KeeperInventorySummaryModelCopyWithImpl<$Res>
    implements _$KeeperInventorySummaryModelCopyWith<$Res> {
  __$KeeperInventorySummaryModelCopyWithImpl(this._self, this._then);

  final _KeeperInventorySummaryModel _self;
  final $Res Function(_KeeperInventorySummaryModel) _then;

/// Create a copy of KeeperInventorySummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUnits = null,Object? totalProducts = null,Object? totalModels = null,Object? returnedUnits = null,Object? totalCartons = null,Object? shippedUnits = null,Object? products = null,}) {
  return _then(_KeeperInventorySummaryModel(
totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as int,totalProducts: null == totalProducts ? _self.totalProducts : totalProducts // ignore: cast_nullable_to_non_nullable
as int,totalModels: null == totalModels ? _self.totalModels : totalModels // ignore: cast_nullable_to_non_nullable
as int,returnedUnits: null == returnedUnits ? _self.returnedUnits : returnedUnits // ignore: cast_nullable_to_non_nullable
as int,totalCartons: null == totalCartons ? _self.totalCartons : totalCartons // ignore: cast_nullable_to_non_nullable
as int,shippedUnits: null == shippedUnits ? _self.shippedUnits : shippedUnits // ignore: cast_nullable_to_non_nullable
as int,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<KeeperInventoryProductModel>,
  ));
}


}


/// @nodoc
mixin _$KeeperInventoryProductModel {

 String get name; String? get unit; int get totalCount; int get cartonCount; int get individualCount; List<KeeperInventoryModelRow> get models;
/// Create a copy of KeeperInventoryProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperInventoryProductModelCopyWith<KeeperInventoryProductModel> get copyWith => _$KeeperInventoryProductModelCopyWithImpl<KeeperInventoryProductModel>(this as KeeperInventoryProductModel, _$identity);

  /// Serializes this KeeperInventoryProductModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperInventoryProductModel&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&(identical(other.individualCount, individualCount) || other.individualCount == individualCount)&&const DeepCollectionEquality().equals(other.models, models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,unit,totalCount,cartonCount,individualCount,const DeepCollectionEquality().hash(models));

@override
String toString() {
  return 'KeeperInventoryProductModel(name: $name, unit: $unit, totalCount: $totalCount, cartonCount: $cartonCount, individualCount: $individualCount, models: $models)';
}


}

/// @nodoc
abstract mixin class $KeeperInventoryProductModelCopyWith<$Res>  {
  factory $KeeperInventoryProductModelCopyWith(KeeperInventoryProductModel value, $Res Function(KeeperInventoryProductModel) _then) = _$KeeperInventoryProductModelCopyWithImpl;
@useResult
$Res call({
 String name, String? unit, int totalCount, int cartonCount, int individualCount, List<KeeperInventoryModelRow> models
});




}
/// @nodoc
class _$KeeperInventoryProductModelCopyWithImpl<$Res>
    implements $KeeperInventoryProductModelCopyWith<$Res> {
  _$KeeperInventoryProductModelCopyWithImpl(this._self, this._then);

  final KeeperInventoryProductModel _self;
  final $Res Function(KeeperInventoryProductModel) _then;

/// Create a copy of KeeperInventoryProductModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? unit = freezed,Object? totalCount = null,Object? cartonCount = null,Object? individualCount = null,Object? models = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as int,individualCount: null == individualCount ? _self.individualCount : individualCount // ignore: cast_nullable_to_non_nullable
as int,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<KeeperInventoryModelRow>,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperInventoryProductModel].
extension KeeperInventoryProductModelPatterns on KeeperInventoryProductModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperInventoryProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperInventoryProductModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperInventoryProductModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperInventoryProductModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperInventoryProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperInventoryProductModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? unit,  int totalCount,  int cartonCount,  int individualCount,  List<KeeperInventoryModelRow> models)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperInventoryProductModel() when $default != null:
return $default(_that.name,_that.unit,_that.totalCount,_that.cartonCount,_that.individualCount,_that.models);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? unit,  int totalCount,  int cartonCount,  int individualCount,  List<KeeperInventoryModelRow> models)  $default,) {final _that = this;
switch (_that) {
case _KeeperInventoryProductModel():
return $default(_that.name,_that.unit,_that.totalCount,_that.cartonCount,_that.individualCount,_that.models);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? unit,  int totalCount,  int cartonCount,  int individualCount,  List<KeeperInventoryModelRow> models)?  $default,) {final _that = this;
switch (_that) {
case _KeeperInventoryProductModel() when $default != null:
return $default(_that.name,_that.unit,_that.totalCount,_that.cartonCount,_that.individualCount,_that.models);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperInventoryProductModel implements KeeperInventoryProductModel {
  const _KeeperInventoryProductModel({this.name = '', this.unit, this.totalCount = 0, this.cartonCount = 0, this.individualCount = 0, final  List<KeeperInventoryModelRow> models = const <KeeperInventoryModelRow>[]}): _models = models;
  factory _KeeperInventoryProductModel.fromJson(Map<String, dynamic> json) => _$KeeperInventoryProductModelFromJson(json);

@override@JsonKey() final  String name;
@override final  String? unit;
@override@JsonKey() final  int totalCount;
@override@JsonKey() final  int cartonCount;
@override@JsonKey() final  int individualCount;
 final  List<KeeperInventoryModelRow> _models;
@override@JsonKey() List<KeeperInventoryModelRow> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}


/// Create a copy of KeeperInventoryProductModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperInventoryProductModelCopyWith<_KeeperInventoryProductModel> get copyWith => __$KeeperInventoryProductModelCopyWithImpl<_KeeperInventoryProductModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperInventoryProductModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperInventoryProductModel&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&(identical(other.individualCount, individualCount) || other.individualCount == individualCount)&&const DeepCollectionEquality().equals(other._models, _models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,unit,totalCount,cartonCount,individualCount,const DeepCollectionEquality().hash(_models));

@override
String toString() {
  return 'KeeperInventoryProductModel(name: $name, unit: $unit, totalCount: $totalCount, cartonCount: $cartonCount, individualCount: $individualCount, models: $models)';
}


}

/// @nodoc
abstract mixin class _$KeeperInventoryProductModelCopyWith<$Res> implements $KeeperInventoryProductModelCopyWith<$Res> {
  factory _$KeeperInventoryProductModelCopyWith(_KeeperInventoryProductModel value, $Res Function(_KeeperInventoryProductModel) _then) = __$KeeperInventoryProductModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String? unit, int totalCount, int cartonCount, int individualCount, List<KeeperInventoryModelRow> models
});




}
/// @nodoc
class __$KeeperInventoryProductModelCopyWithImpl<$Res>
    implements _$KeeperInventoryProductModelCopyWith<$Res> {
  __$KeeperInventoryProductModelCopyWithImpl(this._self, this._then);

  final _KeeperInventoryProductModel _self;
  final $Res Function(_KeeperInventoryProductModel) _then;

/// Create a copy of KeeperInventoryProductModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? unit = freezed,Object? totalCount = null,Object? cartonCount = null,Object? individualCount = null,Object? models = null,}) {
  return _then(_KeeperInventoryProductModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as int,individualCount: null == individualCount ? _self.individualCount : individualCount // ignore: cast_nullable_to_non_nullable
as int,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<KeeperInventoryModelRow>,
  ));
}


}


/// @nodoc
mixin _$KeeperInventoryModelRow {

 String get name; int get totalCount; String? get unit; int get cartonCount; int get individualCount;
/// Create a copy of KeeperInventoryModelRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperInventoryModelRowCopyWith<KeeperInventoryModelRow> get copyWith => _$KeeperInventoryModelRowCopyWithImpl<KeeperInventoryModelRow>(this as KeeperInventoryModelRow, _$identity);

  /// Serializes this KeeperInventoryModelRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperInventoryModelRow&&(identical(other.name, name) || other.name == name)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&(identical(other.individualCount, individualCount) || other.individualCount == individualCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,totalCount,unit,cartonCount,individualCount);

@override
String toString() {
  return 'KeeperInventoryModelRow(name: $name, totalCount: $totalCount, unit: $unit, cartonCount: $cartonCount, individualCount: $individualCount)';
}


}

/// @nodoc
abstract mixin class $KeeperInventoryModelRowCopyWith<$Res>  {
  factory $KeeperInventoryModelRowCopyWith(KeeperInventoryModelRow value, $Res Function(KeeperInventoryModelRow) _then) = _$KeeperInventoryModelRowCopyWithImpl;
@useResult
$Res call({
 String name, int totalCount, String? unit, int cartonCount, int individualCount
});




}
/// @nodoc
class _$KeeperInventoryModelRowCopyWithImpl<$Res>
    implements $KeeperInventoryModelRowCopyWith<$Res> {
  _$KeeperInventoryModelRowCopyWithImpl(this._self, this._then);

  final KeeperInventoryModelRow _self;
  final $Res Function(KeeperInventoryModelRow) _then;

/// Create a copy of KeeperInventoryModelRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? totalCount = null,Object? unit = freezed,Object? cartonCount = null,Object? individualCount = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as int,individualCount: null == individualCount ? _self.individualCount : individualCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperInventoryModelRow].
extension KeeperInventoryModelRowPatterns on KeeperInventoryModelRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperInventoryModelRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperInventoryModelRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperInventoryModelRow value)  $default,){
final _that = this;
switch (_that) {
case _KeeperInventoryModelRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperInventoryModelRow value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperInventoryModelRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int totalCount,  String? unit,  int cartonCount,  int individualCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperInventoryModelRow() when $default != null:
return $default(_that.name,_that.totalCount,_that.unit,_that.cartonCount,_that.individualCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int totalCount,  String? unit,  int cartonCount,  int individualCount)  $default,) {final _that = this;
switch (_that) {
case _KeeperInventoryModelRow():
return $default(_that.name,_that.totalCount,_that.unit,_that.cartonCount,_that.individualCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int totalCount,  String? unit,  int cartonCount,  int individualCount)?  $default,) {final _that = this;
switch (_that) {
case _KeeperInventoryModelRow() when $default != null:
return $default(_that.name,_that.totalCount,_that.unit,_that.cartonCount,_that.individualCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperInventoryModelRow implements KeeperInventoryModelRow {
  const _KeeperInventoryModelRow({this.name = '', this.totalCount = 0, this.unit, this.cartonCount = 0, this.individualCount = 0});
  factory _KeeperInventoryModelRow.fromJson(Map<String, dynamic> json) => _$KeeperInventoryModelRowFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  int totalCount;
@override final  String? unit;
@override@JsonKey() final  int cartonCount;
@override@JsonKey() final  int individualCount;

/// Create a copy of KeeperInventoryModelRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperInventoryModelRowCopyWith<_KeeperInventoryModelRow> get copyWith => __$KeeperInventoryModelRowCopyWithImpl<_KeeperInventoryModelRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperInventoryModelRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperInventoryModelRow&&(identical(other.name, name) || other.name == name)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&(identical(other.individualCount, individualCount) || other.individualCount == individualCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,totalCount,unit,cartonCount,individualCount);

@override
String toString() {
  return 'KeeperInventoryModelRow(name: $name, totalCount: $totalCount, unit: $unit, cartonCount: $cartonCount, individualCount: $individualCount)';
}


}

/// @nodoc
abstract mixin class _$KeeperInventoryModelRowCopyWith<$Res> implements $KeeperInventoryModelRowCopyWith<$Res> {
  factory _$KeeperInventoryModelRowCopyWith(_KeeperInventoryModelRow value, $Res Function(_KeeperInventoryModelRow) _then) = __$KeeperInventoryModelRowCopyWithImpl;
@override @useResult
$Res call({
 String name, int totalCount, String? unit, int cartonCount, int individualCount
});




}
/// @nodoc
class __$KeeperInventoryModelRowCopyWithImpl<$Res>
    implements _$KeeperInventoryModelRowCopyWith<$Res> {
  __$KeeperInventoryModelRowCopyWithImpl(this._self, this._then);

  final _KeeperInventoryModelRow _self;
  final $Res Function(_KeeperInventoryModelRow) _then;

/// Create a copy of KeeperInventoryModelRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? totalCount = null,Object? unit = freezed,Object? cartonCount = null,Object? individualCount = null,}) {
  return _then(_KeeperInventoryModelRow(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as int,individualCount: null == individualCount ? _self.individualCount : individualCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
