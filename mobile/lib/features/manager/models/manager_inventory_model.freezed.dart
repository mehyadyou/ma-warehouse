// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manager_inventory_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ManagerInventoryModel {

 List<ManagerProductRowModel> get products; List<WarehouseStockRowModel> get warehouses; int get total; int get page; int get pageSize; bool get hasMore;
/// Create a copy of ManagerInventoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagerInventoryModelCopyWith<ManagerInventoryModel> get copyWith => _$ManagerInventoryModelCopyWithImpl<ManagerInventoryModel>(this as ManagerInventoryModel, _$identity);

  /// Serializes this ManagerInventoryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagerInventoryModel&&const DeepCollectionEquality().equals(other.products, products)&&const DeepCollectionEquality().equals(other.warehouses, warehouses)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(products),const DeepCollectionEquality().hash(warehouses),total,page,pageSize,hasMore);

@override
String toString() {
  return 'ManagerInventoryModel(products: $products, warehouses: $warehouses, total: $total, page: $page, pageSize: $pageSize, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $ManagerInventoryModelCopyWith<$Res>  {
  factory $ManagerInventoryModelCopyWith(ManagerInventoryModel value, $Res Function(ManagerInventoryModel) _then) = _$ManagerInventoryModelCopyWithImpl;
@useResult
$Res call({
 List<ManagerProductRowModel> products, List<WarehouseStockRowModel> warehouses, int total, int page, int pageSize, bool hasMore
});




}
/// @nodoc
class _$ManagerInventoryModelCopyWithImpl<$Res>
    implements $ManagerInventoryModelCopyWith<$Res> {
  _$ManagerInventoryModelCopyWithImpl(this._self, this._then);

  final ManagerInventoryModel _self;
  final $Res Function(ManagerInventoryModel) _then;

/// Create a copy of ManagerInventoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? products = null,Object? warehouses = null,Object? total = null,Object? page = null,Object? pageSize = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<ManagerProductRowModel>,warehouses: null == warehouses ? _self.warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<WarehouseStockRowModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagerInventoryModel].
extension ManagerInventoryModelPatterns on ManagerInventoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagerInventoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagerInventoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagerInventoryModel value)  $default,){
final _that = this;
switch (_that) {
case _ManagerInventoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagerInventoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _ManagerInventoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ManagerProductRowModel> products,  List<WarehouseStockRowModel> warehouses,  int total,  int page,  int pageSize,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagerInventoryModel() when $default != null:
return $default(_that.products,_that.warehouses,_that.total,_that.page,_that.pageSize,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ManagerProductRowModel> products,  List<WarehouseStockRowModel> warehouses,  int total,  int page,  int pageSize,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _ManagerInventoryModel():
return $default(_that.products,_that.warehouses,_that.total,_that.page,_that.pageSize,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ManagerProductRowModel> products,  List<WarehouseStockRowModel> warehouses,  int total,  int page,  int pageSize,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _ManagerInventoryModel() when $default != null:
return $default(_that.products,_that.warehouses,_that.total,_that.page,_that.pageSize,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ManagerInventoryModel implements ManagerInventoryModel {
  const _ManagerInventoryModel({final  List<ManagerProductRowModel> products = const <ManagerProductRowModel>[], final  List<WarehouseStockRowModel> warehouses = const <WarehouseStockRowModel>[], this.total = 0, this.page = 0, this.pageSize = 0, this.hasMore = false}): _products = products,_warehouses = warehouses;
  factory _ManagerInventoryModel.fromJson(Map<String, dynamic> json) => _$ManagerInventoryModelFromJson(json);

 final  List<ManagerProductRowModel> _products;
@override@JsonKey() List<ManagerProductRowModel> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

 final  List<WarehouseStockRowModel> _warehouses;
@override@JsonKey() List<WarehouseStockRowModel> get warehouses {
  if (_warehouses is EqualUnmodifiableListView) return _warehouses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warehouses);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int page;
@override@JsonKey() final  int pageSize;
@override@JsonKey() final  bool hasMore;

/// Create a copy of ManagerInventoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagerInventoryModelCopyWith<_ManagerInventoryModel> get copyWith => __$ManagerInventoryModelCopyWithImpl<_ManagerInventoryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManagerInventoryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagerInventoryModel&&const DeepCollectionEquality().equals(other._products, _products)&&const DeepCollectionEquality().equals(other._warehouses, _warehouses)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_warehouses),total,page,pageSize,hasMore);

@override
String toString() {
  return 'ManagerInventoryModel(products: $products, warehouses: $warehouses, total: $total, page: $page, pageSize: $pageSize, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$ManagerInventoryModelCopyWith<$Res> implements $ManagerInventoryModelCopyWith<$Res> {
  factory _$ManagerInventoryModelCopyWith(_ManagerInventoryModel value, $Res Function(_ManagerInventoryModel) _then) = __$ManagerInventoryModelCopyWithImpl;
@override @useResult
$Res call({
 List<ManagerProductRowModel> products, List<WarehouseStockRowModel> warehouses, int total, int page, int pageSize, bool hasMore
});




}
/// @nodoc
class __$ManagerInventoryModelCopyWithImpl<$Res>
    implements _$ManagerInventoryModelCopyWith<$Res> {
  __$ManagerInventoryModelCopyWithImpl(this._self, this._then);

  final _ManagerInventoryModel _self;
  final $Res Function(_ManagerInventoryModel) _then;

/// Create a copy of ManagerInventoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? products = null,Object? warehouses = null,Object? total = null,Object? page = null,Object? pageSize = null,Object? hasMore = null,}) {
  return _then(_ManagerInventoryModel(
products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<ManagerProductRowModel>,warehouses: null == warehouses ? _self._warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<WarehouseStockRowModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ManagerProductRowModel {

 String? get productId; String? get name; String? get unit; num get totalCount; int get modelCount; List<String> get modelNames;
/// Create a copy of ManagerProductRowModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagerProductRowModelCopyWith<ManagerProductRowModel> get copyWith => _$ManagerProductRowModelCopyWithImpl<ManagerProductRowModel>(this as ManagerProductRowModel, _$identity);

  /// Serializes this ManagerProductRowModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagerProductRowModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.modelCount, modelCount) || other.modelCount == modelCount)&&const DeepCollectionEquality().equals(other.modelNames, modelNames));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unit,totalCount,modelCount,const DeepCollectionEquality().hash(modelNames));

@override
String toString() {
  return 'ManagerProductRowModel(productId: $productId, name: $name, unit: $unit, totalCount: $totalCount, modelCount: $modelCount, modelNames: $modelNames)';
}


}

/// @nodoc
abstract mixin class $ManagerProductRowModelCopyWith<$Res>  {
  factory $ManagerProductRowModelCopyWith(ManagerProductRowModel value, $Res Function(ManagerProductRowModel) _then) = _$ManagerProductRowModelCopyWithImpl;
@useResult
$Res call({
 String? productId, String? name, String? unit, num totalCount, int modelCount, List<String> modelNames
});




}
/// @nodoc
class _$ManagerProductRowModelCopyWithImpl<$Res>
    implements $ManagerProductRowModelCopyWith<$Res> {
  _$ManagerProductRowModelCopyWithImpl(this._self, this._then);

  final ManagerProductRowModel _self;
  final $Res Function(ManagerProductRowModel) _then;

/// Create a copy of ManagerProductRowModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = freezed,Object? name = freezed,Object? unit = freezed,Object? totalCount = null,Object? modelCount = null,Object? modelNames = null,}) {
  return _then(_self.copyWith(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,modelCount: null == modelCount ? _self.modelCount : modelCount // ignore: cast_nullable_to_non_nullable
as int,modelNames: null == modelNames ? _self.modelNames : modelNames // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagerProductRowModel].
extension ManagerProductRowModelPatterns on ManagerProductRowModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagerProductRowModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagerProductRowModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagerProductRowModel value)  $default,){
final _that = this;
switch (_that) {
case _ManagerProductRowModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagerProductRowModel value)?  $default,){
final _that = this;
switch (_that) {
case _ManagerProductRowModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? productId,  String? name,  String? unit,  num totalCount,  int modelCount,  List<String> modelNames)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagerProductRowModel() when $default != null:
return $default(_that.productId,_that.name,_that.unit,_that.totalCount,_that.modelCount,_that.modelNames);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? productId,  String? name,  String? unit,  num totalCount,  int modelCount,  List<String> modelNames)  $default,) {final _that = this;
switch (_that) {
case _ManagerProductRowModel():
return $default(_that.productId,_that.name,_that.unit,_that.totalCount,_that.modelCount,_that.modelNames);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? productId,  String? name,  String? unit,  num totalCount,  int modelCount,  List<String> modelNames)?  $default,) {final _that = this;
switch (_that) {
case _ManagerProductRowModel() when $default != null:
return $default(_that.productId,_that.name,_that.unit,_that.totalCount,_that.modelCount,_that.modelNames);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ManagerProductRowModel implements ManagerProductRowModel {
  const _ManagerProductRowModel({this.productId, this.name, this.unit, this.totalCount = 0, this.modelCount = 0, final  List<String> modelNames = const <String>[]}): _modelNames = modelNames;
  factory _ManagerProductRowModel.fromJson(Map<String, dynamic> json) => _$ManagerProductRowModelFromJson(json);

@override final  String? productId;
@override final  String? name;
@override final  String? unit;
@override@JsonKey() final  num totalCount;
@override@JsonKey() final  int modelCount;
 final  List<String> _modelNames;
@override@JsonKey() List<String> get modelNames {
  if (_modelNames is EqualUnmodifiableListView) return _modelNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modelNames);
}


/// Create a copy of ManagerProductRowModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagerProductRowModelCopyWith<_ManagerProductRowModel> get copyWith => __$ManagerProductRowModelCopyWithImpl<_ManagerProductRowModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManagerProductRowModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagerProductRowModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.modelCount, modelCount) || other.modelCount == modelCount)&&const DeepCollectionEquality().equals(other._modelNames, _modelNames));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unit,totalCount,modelCount,const DeepCollectionEquality().hash(_modelNames));

@override
String toString() {
  return 'ManagerProductRowModel(productId: $productId, name: $name, unit: $unit, totalCount: $totalCount, modelCount: $modelCount, modelNames: $modelNames)';
}


}

/// @nodoc
abstract mixin class _$ManagerProductRowModelCopyWith<$Res> implements $ManagerProductRowModelCopyWith<$Res> {
  factory _$ManagerProductRowModelCopyWith(_ManagerProductRowModel value, $Res Function(_ManagerProductRowModel) _then) = __$ManagerProductRowModelCopyWithImpl;
@override @useResult
$Res call({
 String? productId, String? name, String? unit, num totalCount, int modelCount, List<String> modelNames
});




}
/// @nodoc
class __$ManagerProductRowModelCopyWithImpl<$Res>
    implements _$ManagerProductRowModelCopyWith<$Res> {
  __$ManagerProductRowModelCopyWithImpl(this._self, this._then);

  final _ManagerProductRowModel _self;
  final $Res Function(_ManagerProductRowModel) _then;

/// Create a copy of ManagerProductRowModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? name = freezed,Object? unit = freezed,Object? totalCount = null,Object? modelCount = null,Object? modelNames = null,}) {
  return _then(_ManagerProductRowModel(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,modelCount: null == modelCount ? _self.modelCount : modelCount // ignore: cast_nullable_to_non_nullable
as int,modelNames: null == modelNames ? _self._modelNames : modelNames // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$WarehouseStockRowModel {

 String? get warehouseId; String? get warehouseName; num get totalCount; int get totalItems; List<StockItemRowModel> get items;
/// Create a copy of WarehouseStockRowModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseStockRowModelCopyWith<WarehouseStockRowModel> get copyWith => _$WarehouseStockRowModelCopyWithImpl<WarehouseStockRowModel>(this as WarehouseStockRowModel, _$identity);

  /// Serializes this WarehouseStockRowModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarehouseStockRowModel&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseId,warehouseName,totalCount,totalItems,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'WarehouseStockRowModel(warehouseId: $warehouseId, warehouseName: $warehouseName, totalCount: $totalCount, totalItems: $totalItems, items: $items)';
}


}

/// @nodoc
abstract mixin class $WarehouseStockRowModelCopyWith<$Res>  {
  factory $WarehouseStockRowModelCopyWith(WarehouseStockRowModel value, $Res Function(WarehouseStockRowModel) _then) = _$WarehouseStockRowModelCopyWithImpl;
@useResult
$Res call({
 String? warehouseId, String? warehouseName, num totalCount, int totalItems, List<StockItemRowModel> items
});




}
/// @nodoc
class _$WarehouseStockRowModelCopyWithImpl<$Res>
    implements $WarehouseStockRowModelCopyWith<$Res> {
  _$WarehouseStockRowModelCopyWithImpl(this._self, this._then);

  final WarehouseStockRowModel _self;
  final $Res Function(WarehouseStockRowModel) _then;

/// Create a copy of WarehouseStockRowModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warehouseId = freezed,Object? warehouseName = freezed,Object? totalCount = null,Object? totalItems = null,Object? items = null,}) {
  return _then(_self.copyWith(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<StockItemRowModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [WarehouseStockRowModel].
extension WarehouseStockRowModelPatterns on WarehouseStockRowModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarehouseStockRowModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarehouseStockRowModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarehouseStockRowModel value)  $default,){
final _that = this;
switch (_that) {
case _WarehouseStockRowModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarehouseStockRowModel value)?  $default,){
final _that = this;
switch (_that) {
case _WarehouseStockRowModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? warehouseId,  String? warehouseName,  num totalCount,  int totalItems,  List<StockItemRowModel> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarehouseStockRowModel() when $default != null:
return $default(_that.warehouseId,_that.warehouseName,_that.totalCount,_that.totalItems,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? warehouseId,  String? warehouseName,  num totalCount,  int totalItems,  List<StockItemRowModel> items)  $default,) {final _that = this;
switch (_that) {
case _WarehouseStockRowModel():
return $default(_that.warehouseId,_that.warehouseName,_that.totalCount,_that.totalItems,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? warehouseId,  String? warehouseName,  num totalCount,  int totalItems,  List<StockItemRowModel> items)?  $default,) {final _that = this;
switch (_that) {
case _WarehouseStockRowModel() when $default != null:
return $default(_that.warehouseId,_that.warehouseName,_that.totalCount,_that.totalItems,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WarehouseStockRowModel implements WarehouseStockRowModel {
  const _WarehouseStockRowModel({this.warehouseId, this.warehouseName, this.totalCount = 0, this.totalItems = 0, final  List<StockItemRowModel> items = const <StockItemRowModel>[]}): _items = items;
  factory _WarehouseStockRowModel.fromJson(Map<String, dynamic> json) => _$WarehouseStockRowModelFromJson(json);

@override final  String? warehouseId;
@override final  String? warehouseName;
@override@JsonKey() final  num totalCount;
@override@JsonKey() final  int totalItems;
 final  List<StockItemRowModel> _items;
@override@JsonKey() List<StockItemRowModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of WarehouseStockRowModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseStockRowModelCopyWith<_WarehouseStockRowModel> get copyWith => __$WarehouseStockRowModelCopyWithImpl<_WarehouseStockRowModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WarehouseStockRowModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarehouseStockRowModel&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseId,warehouseName,totalCount,totalItems,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'WarehouseStockRowModel(warehouseId: $warehouseId, warehouseName: $warehouseName, totalCount: $totalCount, totalItems: $totalItems, items: $items)';
}


}

/// @nodoc
abstract mixin class _$WarehouseStockRowModelCopyWith<$Res> implements $WarehouseStockRowModelCopyWith<$Res> {
  factory _$WarehouseStockRowModelCopyWith(_WarehouseStockRowModel value, $Res Function(_WarehouseStockRowModel) _then) = __$WarehouseStockRowModelCopyWithImpl;
@override @useResult
$Res call({
 String? warehouseId, String? warehouseName, num totalCount, int totalItems, List<StockItemRowModel> items
});




}
/// @nodoc
class __$WarehouseStockRowModelCopyWithImpl<$Res>
    implements _$WarehouseStockRowModelCopyWith<$Res> {
  __$WarehouseStockRowModelCopyWithImpl(this._self, this._then);

  final _WarehouseStockRowModel _self;
  final $Res Function(_WarehouseStockRowModel) _then;

/// Create a copy of WarehouseStockRowModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warehouseId = freezed,Object? warehouseName = freezed,Object? totalCount = null,Object? totalItems = null,Object? items = null,}) {
  return _then(_WarehouseStockRowModel(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<StockItemRowModel>,
  ));
}


}


/// @nodoc
mixin _$StockItemRowModel {

 String? get productId; String? get name; String? get unit; num get count;
/// Create a copy of StockItemRowModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockItemRowModelCopyWith<StockItemRowModel> get copyWith => _$StockItemRowModelCopyWithImpl<StockItemRowModel>(this as StockItemRowModel, _$identity);

  /// Serializes this StockItemRowModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockItemRowModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unit,count);

@override
String toString() {
  return 'StockItemRowModel(productId: $productId, name: $name, unit: $unit, count: $count)';
}


}

/// @nodoc
abstract mixin class $StockItemRowModelCopyWith<$Res>  {
  factory $StockItemRowModelCopyWith(StockItemRowModel value, $Res Function(StockItemRowModel) _then) = _$StockItemRowModelCopyWithImpl;
@useResult
$Res call({
 String? productId, String? name, String? unit, num count
});




}
/// @nodoc
class _$StockItemRowModelCopyWithImpl<$Res>
    implements $StockItemRowModelCopyWith<$Res> {
  _$StockItemRowModelCopyWithImpl(this._self, this._then);

  final StockItemRowModel _self;
  final $Res Function(StockItemRowModel) _then;

/// Create a copy of StockItemRowModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = freezed,Object? name = freezed,Object? unit = freezed,Object? count = null,}) {
  return _then(_self.copyWith(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [StockItemRowModel].
extension StockItemRowModelPatterns on StockItemRowModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockItemRowModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockItemRowModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockItemRowModel value)  $default,){
final _that = this;
switch (_that) {
case _StockItemRowModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockItemRowModel value)?  $default,){
final _that = this;
switch (_that) {
case _StockItemRowModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? productId,  String? name,  String? unit,  num count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockItemRowModel() when $default != null:
return $default(_that.productId,_that.name,_that.unit,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? productId,  String? name,  String? unit,  num count)  $default,) {final _that = this;
switch (_that) {
case _StockItemRowModel():
return $default(_that.productId,_that.name,_that.unit,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? productId,  String? name,  String? unit,  num count)?  $default,) {final _that = this;
switch (_that) {
case _StockItemRowModel() when $default != null:
return $default(_that.productId,_that.name,_that.unit,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockItemRowModel implements StockItemRowModel {
  const _StockItemRowModel({this.productId, this.name, this.unit, this.count = 0});
  factory _StockItemRowModel.fromJson(Map<String, dynamic> json) => _$StockItemRowModelFromJson(json);

@override final  String? productId;
@override final  String? name;
@override final  String? unit;
@override@JsonKey() final  num count;

/// Create a copy of StockItemRowModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockItemRowModelCopyWith<_StockItemRowModel> get copyWith => __$StockItemRowModelCopyWithImpl<_StockItemRowModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockItemRowModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockItemRowModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unit,count);

@override
String toString() {
  return 'StockItemRowModel(productId: $productId, name: $name, unit: $unit, count: $count)';
}


}

/// @nodoc
abstract mixin class _$StockItemRowModelCopyWith<$Res> implements $StockItemRowModelCopyWith<$Res> {
  factory _$StockItemRowModelCopyWith(_StockItemRowModel value, $Res Function(_StockItemRowModel) _then) = __$StockItemRowModelCopyWithImpl;
@override @useResult
$Res call({
 String? productId, String? name, String? unit, num count
});




}
/// @nodoc
class __$StockItemRowModelCopyWithImpl<$Res>
    implements _$StockItemRowModelCopyWith<$Res> {
  __$StockItemRowModelCopyWithImpl(this._self, this._then);

  final _StockItemRowModel _self;
  final $Res Function(_StockItemRowModel) _then;

/// Create a copy of StockItemRowModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? name = freezed,Object? unit = freezed,Object? count = null,}) {
  return _then(_StockItemRowModel(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
