// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keeper_inventory_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KeeperInventoryListModel {

 List<KeeperProductRowModel> get products; List<KeeperWarehouseStockRowModel> get warehouses; int get total; int get page; int get pageSize; bool get hasMore;
/// Create a copy of KeeperInventoryListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperInventoryListModelCopyWith<KeeperInventoryListModel> get copyWith => _$KeeperInventoryListModelCopyWithImpl<KeeperInventoryListModel>(this as KeeperInventoryListModel, _$identity);

  /// Serializes this KeeperInventoryListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperInventoryListModel&&const DeepCollectionEquality().equals(other.products, products)&&const DeepCollectionEquality().equals(other.warehouses, warehouses)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(products),const DeepCollectionEquality().hash(warehouses),total,page,pageSize,hasMore);

@override
String toString() {
  return 'KeeperInventoryListModel(products: $products, warehouses: $warehouses, total: $total, page: $page, pageSize: $pageSize, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $KeeperInventoryListModelCopyWith<$Res>  {
  factory $KeeperInventoryListModelCopyWith(KeeperInventoryListModel value, $Res Function(KeeperInventoryListModel) _then) = _$KeeperInventoryListModelCopyWithImpl;
@useResult
$Res call({
 List<KeeperProductRowModel> products, List<KeeperWarehouseStockRowModel> warehouses, int total, int page, int pageSize, bool hasMore
});




}
/// @nodoc
class _$KeeperInventoryListModelCopyWithImpl<$Res>
    implements $KeeperInventoryListModelCopyWith<$Res> {
  _$KeeperInventoryListModelCopyWithImpl(this._self, this._then);

  final KeeperInventoryListModel _self;
  final $Res Function(KeeperInventoryListModel) _then;

/// Create a copy of KeeperInventoryListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? products = null,Object? warehouses = null,Object? total = null,Object? page = null,Object? pageSize = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<KeeperProductRowModel>,warehouses: null == warehouses ? _self.warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<KeeperWarehouseStockRowModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperInventoryListModel].
extension KeeperInventoryListModelPatterns on KeeperInventoryListModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperInventoryListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperInventoryListModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperInventoryListModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperInventoryListModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperInventoryListModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperInventoryListModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<KeeperProductRowModel> products,  List<KeeperWarehouseStockRowModel> warehouses,  int total,  int page,  int pageSize,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperInventoryListModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<KeeperProductRowModel> products,  List<KeeperWarehouseStockRowModel> warehouses,  int total,  int page,  int pageSize,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _KeeperInventoryListModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<KeeperProductRowModel> products,  List<KeeperWarehouseStockRowModel> warehouses,  int total,  int page,  int pageSize,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _KeeperInventoryListModel() when $default != null:
return $default(_that.products,_that.warehouses,_that.total,_that.page,_that.pageSize,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperInventoryListModel implements KeeperInventoryListModel {
  const _KeeperInventoryListModel({final  List<KeeperProductRowModel> products = const <KeeperProductRowModel>[], final  List<KeeperWarehouseStockRowModel> warehouses = const <KeeperWarehouseStockRowModel>[], this.total = 0, this.page = 1, this.pageSize = 50, this.hasMore = false}): _products = products,_warehouses = warehouses;
  factory _KeeperInventoryListModel.fromJson(Map<String, dynamic> json) => _$KeeperInventoryListModelFromJson(json);

 final  List<KeeperProductRowModel> _products;
@override@JsonKey() List<KeeperProductRowModel> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

 final  List<KeeperWarehouseStockRowModel> _warehouses;
@override@JsonKey() List<KeeperWarehouseStockRowModel> get warehouses {
  if (_warehouses is EqualUnmodifiableListView) return _warehouses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warehouses);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int page;
@override@JsonKey() final  int pageSize;
@override@JsonKey() final  bool hasMore;

/// Create a copy of KeeperInventoryListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperInventoryListModelCopyWith<_KeeperInventoryListModel> get copyWith => __$KeeperInventoryListModelCopyWithImpl<_KeeperInventoryListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperInventoryListModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperInventoryListModel&&const DeepCollectionEquality().equals(other._products, _products)&&const DeepCollectionEquality().equals(other._warehouses, _warehouses)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_warehouses),total,page,pageSize,hasMore);

@override
String toString() {
  return 'KeeperInventoryListModel(products: $products, warehouses: $warehouses, total: $total, page: $page, pageSize: $pageSize, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$KeeperInventoryListModelCopyWith<$Res> implements $KeeperInventoryListModelCopyWith<$Res> {
  factory _$KeeperInventoryListModelCopyWith(_KeeperInventoryListModel value, $Res Function(_KeeperInventoryListModel) _then) = __$KeeperInventoryListModelCopyWithImpl;
@override @useResult
$Res call({
 List<KeeperProductRowModel> products, List<KeeperWarehouseStockRowModel> warehouses, int total, int page, int pageSize, bool hasMore
});




}
/// @nodoc
class __$KeeperInventoryListModelCopyWithImpl<$Res>
    implements _$KeeperInventoryListModelCopyWith<$Res> {
  __$KeeperInventoryListModelCopyWithImpl(this._self, this._then);

  final _KeeperInventoryListModel _self;
  final $Res Function(_KeeperInventoryListModel) _then;

/// Create a copy of KeeperInventoryListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? products = null,Object? warehouses = null,Object? total = null,Object? page = null,Object? pageSize = null,Object? hasMore = null,}) {
  return _then(_KeeperInventoryListModel(
products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<KeeperProductRowModel>,warehouses: null == warehouses ? _self._warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<KeeperWarehouseStockRowModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$KeeperProductRowModel {

 String? get productId; String? get name; String? get unit; num get totalCount; List<KeeperProductModelStockModel> get models;
/// Create a copy of KeeperProductRowModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperProductRowModelCopyWith<KeeperProductRowModel> get copyWith => _$KeeperProductRowModelCopyWithImpl<KeeperProductRowModel>(this as KeeperProductRowModel, _$identity);

  /// Serializes this KeeperProductRowModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperProductRowModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other.models, models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unit,totalCount,const DeepCollectionEquality().hash(models));

@override
String toString() {
  return 'KeeperProductRowModel(productId: $productId, name: $name, unit: $unit, totalCount: $totalCount, models: $models)';
}


}

/// @nodoc
abstract mixin class $KeeperProductRowModelCopyWith<$Res>  {
  factory $KeeperProductRowModelCopyWith(KeeperProductRowModel value, $Res Function(KeeperProductRowModel) _then) = _$KeeperProductRowModelCopyWithImpl;
@useResult
$Res call({
 String? productId, String? name, String? unit, num totalCount, List<KeeperProductModelStockModel> models
});




}
/// @nodoc
class _$KeeperProductRowModelCopyWithImpl<$Res>
    implements $KeeperProductRowModelCopyWith<$Res> {
  _$KeeperProductRowModelCopyWithImpl(this._self, this._then);

  final KeeperProductRowModel _self;
  final $Res Function(KeeperProductRowModel) _then;

/// Create a copy of KeeperProductRowModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = freezed,Object? name = freezed,Object? unit = freezed,Object? totalCount = null,Object? models = null,}) {
  return _then(_self.copyWith(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<KeeperProductModelStockModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperProductRowModel].
extension KeeperProductRowModelPatterns on KeeperProductRowModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperProductRowModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperProductRowModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperProductRowModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperProductRowModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperProductRowModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperProductRowModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? productId,  String? name,  String? unit,  num totalCount,  List<KeeperProductModelStockModel> models)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperProductRowModel() when $default != null:
return $default(_that.productId,_that.name,_that.unit,_that.totalCount,_that.models);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? productId,  String? name,  String? unit,  num totalCount,  List<KeeperProductModelStockModel> models)  $default,) {final _that = this;
switch (_that) {
case _KeeperProductRowModel():
return $default(_that.productId,_that.name,_that.unit,_that.totalCount,_that.models);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? productId,  String? name,  String? unit,  num totalCount,  List<KeeperProductModelStockModel> models)?  $default,) {final _that = this;
switch (_that) {
case _KeeperProductRowModel() when $default != null:
return $default(_that.productId,_that.name,_that.unit,_that.totalCount,_that.models);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperProductRowModel implements KeeperProductRowModel {
  const _KeeperProductRowModel({this.productId, this.name, this.unit, this.totalCount = 0, final  List<KeeperProductModelStockModel> models = const <KeeperProductModelStockModel>[]}): _models = models;
  factory _KeeperProductRowModel.fromJson(Map<String, dynamic> json) => _$KeeperProductRowModelFromJson(json);

@override final  String? productId;
@override final  String? name;
@override final  String? unit;
@override@JsonKey() final  num totalCount;
 final  List<KeeperProductModelStockModel> _models;
@override@JsonKey() List<KeeperProductModelStockModel> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}


/// Create a copy of KeeperProductRowModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperProductRowModelCopyWith<_KeeperProductRowModel> get copyWith => __$KeeperProductRowModelCopyWithImpl<_KeeperProductRowModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperProductRowModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperProductRowModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other._models, _models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unit,totalCount,const DeepCollectionEquality().hash(_models));

@override
String toString() {
  return 'KeeperProductRowModel(productId: $productId, name: $name, unit: $unit, totalCount: $totalCount, models: $models)';
}


}

/// @nodoc
abstract mixin class _$KeeperProductRowModelCopyWith<$Res> implements $KeeperProductRowModelCopyWith<$Res> {
  factory _$KeeperProductRowModelCopyWith(_KeeperProductRowModel value, $Res Function(_KeeperProductRowModel) _then) = __$KeeperProductRowModelCopyWithImpl;
@override @useResult
$Res call({
 String? productId, String? name, String? unit, num totalCount, List<KeeperProductModelStockModel> models
});




}
/// @nodoc
class __$KeeperProductRowModelCopyWithImpl<$Res>
    implements _$KeeperProductRowModelCopyWith<$Res> {
  __$KeeperProductRowModelCopyWithImpl(this._self, this._then);

  final _KeeperProductRowModel _self;
  final $Res Function(_KeeperProductRowModel) _then;

/// Create a copy of KeeperProductRowModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? name = freezed,Object? unit = freezed,Object? totalCount = null,Object? models = null,}) {
  return _then(_KeeperProductRowModel(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<KeeperProductModelStockModel>,
  ));
}


}


/// @nodoc
mixin _$KeeperWarehouseStockRowModel {

 String? get warehouseId; String? get warehouseName; num get totalCount; List<KeeperStockItemRowModel> get items;
/// Create a copy of KeeperWarehouseStockRowModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperWarehouseStockRowModelCopyWith<KeeperWarehouseStockRowModel> get copyWith => _$KeeperWarehouseStockRowModelCopyWithImpl<KeeperWarehouseStockRowModel>(this as KeeperWarehouseStockRowModel, _$identity);

  /// Serializes this KeeperWarehouseStockRowModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperWarehouseStockRowModel&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseId,warehouseName,totalCount,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'KeeperWarehouseStockRowModel(warehouseId: $warehouseId, warehouseName: $warehouseName, totalCount: $totalCount, items: $items)';
}


}

/// @nodoc
abstract mixin class $KeeperWarehouseStockRowModelCopyWith<$Res>  {
  factory $KeeperWarehouseStockRowModelCopyWith(KeeperWarehouseStockRowModel value, $Res Function(KeeperWarehouseStockRowModel) _then) = _$KeeperWarehouseStockRowModelCopyWithImpl;
@useResult
$Res call({
 String? warehouseId, String? warehouseName, num totalCount, List<KeeperStockItemRowModel> items
});




}
/// @nodoc
class _$KeeperWarehouseStockRowModelCopyWithImpl<$Res>
    implements $KeeperWarehouseStockRowModelCopyWith<$Res> {
  _$KeeperWarehouseStockRowModelCopyWithImpl(this._self, this._then);

  final KeeperWarehouseStockRowModel _self;
  final $Res Function(KeeperWarehouseStockRowModel) _then;

/// Create a copy of KeeperWarehouseStockRowModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warehouseId = freezed,Object? warehouseName = freezed,Object? totalCount = null,Object? items = null,}) {
  return _then(_self.copyWith(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<KeeperStockItemRowModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperWarehouseStockRowModel].
extension KeeperWarehouseStockRowModelPatterns on KeeperWarehouseStockRowModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperWarehouseStockRowModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperWarehouseStockRowModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperWarehouseStockRowModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperWarehouseStockRowModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperWarehouseStockRowModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperWarehouseStockRowModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? warehouseId,  String? warehouseName,  num totalCount,  List<KeeperStockItemRowModel> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperWarehouseStockRowModel() when $default != null:
return $default(_that.warehouseId,_that.warehouseName,_that.totalCount,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? warehouseId,  String? warehouseName,  num totalCount,  List<KeeperStockItemRowModel> items)  $default,) {final _that = this;
switch (_that) {
case _KeeperWarehouseStockRowModel():
return $default(_that.warehouseId,_that.warehouseName,_that.totalCount,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? warehouseId,  String? warehouseName,  num totalCount,  List<KeeperStockItemRowModel> items)?  $default,) {final _that = this;
switch (_that) {
case _KeeperWarehouseStockRowModel() when $default != null:
return $default(_that.warehouseId,_that.warehouseName,_that.totalCount,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperWarehouseStockRowModel implements KeeperWarehouseStockRowModel {
  const _KeeperWarehouseStockRowModel({this.warehouseId, this.warehouseName, this.totalCount = 0, final  List<KeeperStockItemRowModel> items = const <KeeperStockItemRowModel>[]}): _items = items;
  factory _KeeperWarehouseStockRowModel.fromJson(Map<String, dynamic> json) => _$KeeperWarehouseStockRowModelFromJson(json);

@override final  String? warehouseId;
@override final  String? warehouseName;
@override@JsonKey() final  num totalCount;
 final  List<KeeperStockItemRowModel> _items;
@override@JsonKey() List<KeeperStockItemRowModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of KeeperWarehouseStockRowModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperWarehouseStockRowModelCopyWith<_KeeperWarehouseStockRowModel> get copyWith => __$KeeperWarehouseStockRowModelCopyWithImpl<_KeeperWarehouseStockRowModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperWarehouseStockRowModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperWarehouseStockRowModel&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseId,warehouseName,totalCount,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'KeeperWarehouseStockRowModel(warehouseId: $warehouseId, warehouseName: $warehouseName, totalCount: $totalCount, items: $items)';
}


}

/// @nodoc
abstract mixin class _$KeeperWarehouseStockRowModelCopyWith<$Res> implements $KeeperWarehouseStockRowModelCopyWith<$Res> {
  factory _$KeeperWarehouseStockRowModelCopyWith(_KeeperWarehouseStockRowModel value, $Res Function(_KeeperWarehouseStockRowModel) _then) = __$KeeperWarehouseStockRowModelCopyWithImpl;
@override @useResult
$Res call({
 String? warehouseId, String? warehouseName, num totalCount, List<KeeperStockItemRowModel> items
});




}
/// @nodoc
class __$KeeperWarehouseStockRowModelCopyWithImpl<$Res>
    implements _$KeeperWarehouseStockRowModelCopyWith<$Res> {
  __$KeeperWarehouseStockRowModelCopyWithImpl(this._self, this._then);

  final _KeeperWarehouseStockRowModel _self;
  final $Res Function(_KeeperWarehouseStockRowModel) _then;

/// Create a copy of KeeperWarehouseStockRowModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warehouseId = freezed,Object? warehouseName = freezed,Object? totalCount = null,Object? items = null,}) {
  return _then(_KeeperWarehouseStockRowModel(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<KeeperStockItemRowModel>,
  ));
}


}


/// @nodoc
mixin _$KeeperStockItemRowModel {

 String? get productId; String? get name; String? get unit; num get count;
/// Create a copy of KeeperStockItemRowModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperStockItemRowModelCopyWith<KeeperStockItemRowModel> get copyWith => _$KeeperStockItemRowModelCopyWithImpl<KeeperStockItemRowModel>(this as KeeperStockItemRowModel, _$identity);

  /// Serializes this KeeperStockItemRowModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperStockItemRowModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unit,count);

@override
String toString() {
  return 'KeeperStockItemRowModel(productId: $productId, name: $name, unit: $unit, count: $count)';
}


}

/// @nodoc
abstract mixin class $KeeperStockItemRowModelCopyWith<$Res>  {
  factory $KeeperStockItemRowModelCopyWith(KeeperStockItemRowModel value, $Res Function(KeeperStockItemRowModel) _then) = _$KeeperStockItemRowModelCopyWithImpl;
@useResult
$Res call({
 String? productId, String? name, String? unit, num count
});




}
/// @nodoc
class _$KeeperStockItemRowModelCopyWithImpl<$Res>
    implements $KeeperStockItemRowModelCopyWith<$Res> {
  _$KeeperStockItemRowModelCopyWithImpl(this._self, this._then);

  final KeeperStockItemRowModel _self;
  final $Res Function(KeeperStockItemRowModel) _then;

/// Create a copy of KeeperStockItemRowModel
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


/// Adds pattern-matching-related methods to [KeeperStockItemRowModel].
extension KeeperStockItemRowModelPatterns on KeeperStockItemRowModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperStockItemRowModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperStockItemRowModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperStockItemRowModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperStockItemRowModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperStockItemRowModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperStockItemRowModel() when $default != null:
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
case _KeeperStockItemRowModel() when $default != null:
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
case _KeeperStockItemRowModel():
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
case _KeeperStockItemRowModel() when $default != null:
return $default(_that.productId,_that.name,_that.unit,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperStockItemRowModel implements KeeperStockItemRowModel {
  const _KeeperStockItemRowModel({this.productId, this.name, this.unit, this.count = 0});
  factory _KeeperStockItemRowModel.fromJson(Map<String, dynamic> json) => _$KeeperStockItemRowModelFromJson(json);

@override final  String? productId;
@override final  String? name;
@override final  String? unit;
@override@JsonKey() final  num count;

/// Create a copy of KeeperStockItemRowModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperStockItemRowModelCopyWith<_KeeperStockItemRowModel> get copyWith => __$KeeperStockItemRowModelCopyWithImpl<_KeeperStockItemRowModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperStockItemRowModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperStockItemRowModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,unit,count);

@override
String toString() {
  return 'KeeperStockItemRowModel(productId: $productId, name: $name, unit: $unit, count: $count)';
}


}

/// @nodoc
abstract mixin class _$KeeperStockItemRowModelCopyWith<$Res> implements $KeeperStockItemRowModelCopyWith<$Res> {
  factory _$KeeperStockItemRowModelCopyWith(_KeeperStockItemRowModel value, $Res Function(_KeeperStockItemRowModel) _then) = __$KeeperStockItemRowModelCopyWithImpl;
@override @useResult
$Res call({
 String? productId, String? name, String? unit, num count
});




}
/// @nodoc
class __$KeeperStockItemRowModelCopyWithImpl<$Res>
    implements _$KeeperStockItemRowModelCopyWith<$Res> {
  __$KeeperStockItemRowModelCopyWithImpl(this._self, this._then);

  final _KeeperStockItemRowModel _self;
  final $Res Function(_KeeperStockItemRowModel) _then;

/// Create a copy of KeeperStockItemRowModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? name = freezed,Object? unit = freezed,Object? count = null,}) {
  return _then(_KeeperStockItemRowModel(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$KeeperProductModelsData {

 KeeperProductInfoModel? get product; List<KeeperProductModelStockModel> get models;
/// Create a copy of KeeperProductModelsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperProductModelsDataCopyWith<KeeperProductModelsData> get copyWith => _$KeeperProductModelsDataCopyWithImpl<KeeperProductModelsData>(this as KeeperProductModelsData, _$identity);

  /// Serializes this KeeperProductModelsData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperProductModelsData&&(identical(other.product, product) || other.product == product)&&const DeepCollectionEquality().equals(other.models, models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,product,const DeepCollectionEquality().hash(models));

@override
String toString() {
  return 'KeeperProductModelsData(product: $product, models: $models)';
}


}

/// @nodoc
abstract mixin class $KeeperProductModelsDataCopyWith<$Res>  {
  factory $KeeperProductModelsDataCopyWith(KeeperProductModelsData value, $Res Function(KeeperProductModelsData) _then) = _$KeeperProductModelsDataCopyWithImpl;
@useResult
$Res call({
 KeeperProductInfoModel? product, List<KeeperProductModelStockModel> models
});


$KeeperProductInfoModelCopyWith<$Res>? get product;

}
/// @nodoc
class _$KeeperProductModelsDataCopyWithImpl<$Res>
    implements $KeeperProductModelsDataCopyWith<$Res> {
  _$KeeperProductModelsDataCopyWithImpl(this._self, this._then);

  final KeeperProductModelsData _self;
  final $Res Function(KeeperProductModelsData) _then;

/// Create a copy of KeeperProductModelsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = freezed,Object? models = null,}) {
  return _then(_self.copyWith(
product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as KeeperProductInfoModel?,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<KeeperProductModelStockModel>,
  ));
}
/// Create a copy of KeeperProductModelsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KeeperProductInfoModelCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $KeeperProductInfoModelCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [KeeperProductModelsData].
extension KeeperProductModelsDataPatterns on KeeperProductModelsData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperProductModelsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperProductModelsData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperProductModelsData value)  $default,){
final _that = this;
switch (_that) {
case _KeeperProductModelsData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperProductModelsData value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperProductModelsData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( KeeperProductInfoModel? product,  List<KeeperProductModelStockModel> models)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperProductModelsData() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( KeeperProductInfoModel? product,  List<KeeperProductModelStockModel> models)  $default,) {final _that = this;
switch (_that) {
case _KeeperProductModelsData():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( KeeperProductInfoModel? product,  List<KeeperProductModelStockModel> models)?  $default,) {final _that = this;
switch (_that) {
case _KeeperProductModelsData() when $default != null:
return $default(_that.product,_that.models);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperProductModelsData implements KeeperProductModelsData {
  const _KeeperProductModelsData({this.product, final  List<KeeperProductModelStockModel> models = const <KeeperProductModelStockModel>[]}): _models = models;
  factory _KeeperProductModelsData.fromJson(Map<String, dynamic> json) => _$KeeperProductModelsDataFromJson(json);

@override final  KeeperProductInfoModel? product;
 final  List<KeeperProductModelStockModel> _models;
@override@JsonKey() List<KeeperProductModelStockModel> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}


/// Create a copy of KeeperProductModelsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperProductModelsDataCopyWith<_KeeperProductModelsData> get copyWith => __$KeeperProductModelsDataCopyWithImpl<_KeeperProductModelsData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperProductModelsDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperProductModelsData&&(identical(other.product, product) || other.product == product)&&const DeepCollectionEquality().equals(other._models, _models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,product,const DeepCollectionEquality().hash(_models));

@override
String toString() {
  return 'KeeperProductModelsData(product: $product, models: $models)';
}


}

/// @nodoc
abstract mixin class _$KeeperProductModelsDataCopyWith<$Res> implements $KeeperProductModelsDataCopyWith<$Res> {
  factory _$KeeperProductModelsDataCopyWith(_KeeperProductModelsData value, $Res Function(_KeeperProductModelsData) _then) = __$KeeperProductModelsDataCopyWithImpl;
@override @useResult
$Res call({
 KeeperProductInfoModel? product, List<KeeperProductModelStockModel> models
});


@override $KeeperProductInfoModelCopyWith<$Res>? get product;

}
/// @nodoc
class __$KeeperProductModelsDataCopyWithImpl<$Res>
    implements _$KeeperProductModelsDataCopyWith<$Res> {
  __$KeeperProductModelsDataCopyWithImpl(this._self, this._then);

  final _KeeperProductModelsData _self;
  final $Res Function(_KeeperProductModelsData) _then;

/// Create a copy of KeeperProductModelsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = freezed,Object? models = null,}) {
  return _then(_KeeperProductModelsData(
product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as KeeperProductInfoModel?,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<KeeperProductModelStockModel>,
  ));
}

/// Create a copy of KeeperProductModelsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KeeperProductInfoModelCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $KeeperProductInfoModelCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// @nodoc
mixin _$KeeperProductInfoModel {

 String? get id; String? get name; String? get unit;
/// Create a copy of KeeperProductInfoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperProductInfoModelCopyWith<KeeperProductInfoModel> get copyWith => _$KeeperProductInfoModelCopyWithImpl<KeeperProductInfoModel>(this as KeeperProductInfoModel, _$identity);

  /// Serializes this KeeperProductInfoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperProductInfoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,unit);

@override
String toString() {
  return 'KeeperProductInfoModel(id: $id, name: $name, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $KeeperProductInfoModelCopyWith<$Res>  {
  factory $KeeperProductInfoModelCopyWith(KeeperProductInfoModel value, $Res Function(KeeperProductInfoModel) _then) = _$KeeperProductInfoModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? name, String? unit
});




}
/// @nodoc
class _$KeeperProductInfoModelCopyWithImpl<$Res>
    implements $KeeperProductInfoModelCopyWith<$Res> {
  _$KeeperProductInfoModelCopyWithImpl(this._self, this._then);

  final KeeperProductInfoModel _self;
  final $Res Function(KeeperProductInfoModel) _then;

/// Create a copy of KeeperProductInfoModel
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


/// Adds pattern-matching-related methods to [KeeperProductInfoModel].
extension KeeperProductInfoModelPatterns on KeeperProductInfoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperProductInfoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperProductInfoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperProductInfoModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperProductInfoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperProductInfoModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperProductInfoModel() when $default != null:
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
case _KeeperProductInfoModel() when $default != null:
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
case _KeeperProductInfoModel():
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
case _KeeperProductInfoModel() when $default != null:
return $default(_that.id,_that.name,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperProductInfoModel implements KeeperProductInfoModel {
  const _KeeperProductInfoModel({this.id, this.name, this.unit});
  factory _KeeperProductInfoModel.fromJson(Map<String, dynamic> json) => _$KeeperProductInfoModelFromJson(json);

@override final  String? id;
@override final  String? name;
@override final  String? unit;

/// Create a copy of KeeperProductInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperProductInfoModelCopyWith<_KeeperProductInfoModel> get copyWith => __$KeeperProductInfoModelCopyWithImpl<_KeeperProductInfoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperProductInfoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperProductInfoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,unit);

@override
String toString() {
  return 'KeeperProductInfoModel(id: $id, name: $name, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$KeeperProductInfoModelCopyWith<$Res> implements $KeeperProductInfoModelCopyWith<$Res> {
  factory _$KeeperProductInfoModelCopyWith(_KeeperProductInfoModel value, $Res Function(_KeeperProductInfoModel) _then) = __$KeeperProductInfoModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name, String? unit
});




}
/// @nodoc
class __$KeeperProductInfoModelCopyWithImpl<$Res>
    implements _$KeeperProductInfoModelCopyWith<$Res> {
  __$KeeperProductInfoModelCopyWithImpl(this._self, this._then);

  final _KeeperProductInfoModel _self;
  final $Res Function(_KeeperProductInfoModel) _then;

/// Create a copy of KeeperProductInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? unit = freezed,}) {
  return _then(_KeeperProductInfoModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$KeeperProductModelStockModel {

 String? get modelId; String? get name; String? get packageType; num? get unitsPerBox; num get count; List<KeeperModelWarehouseRowModel> get warehouses;
/// Create a copy of KeeperProductModelStockModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperProductModelStockModelCopyWith<KeeperProductModelStockModel> get copyWith => _$KeeperProductModelStockModelCopyWithImpl<KeeperProductModelStockModel>(this as KeeperProductModelStockModel, _$identity);

  /// Serializes this KeeperProductModelStockModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperProductModelStockModel&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.packageType, packageType) || other.packageType == packageType)&&(identical(other.unitsPerBox, unitsPerBox) || other.unitsPerBox == unitsPerBox)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.warehouses, warehouses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,modelId,name,packageType,unitsPerBox,count,const DeepCollectionEquality().hash(warehouses));

@override
String toString() {
  return 'KeeperProductModelStockModel(modelId: $modelId, name: $name, packageType: $packageType, unitsPerBox: $unitsPerBox, count: $count, warehouses: $warehouses)';
}


}

/// @nodoc
abstract mixin class $KeeperProductModelStockModelCopyWith<$Res>  {
  factory $KeeperProductModelStockModelCopyWith(KeeperProductModelStockModel value, $Res Function(KeeperProductModelStockModel) _then) = _$KeeperProductModelStockModelCopyWithImpl;
@useResult
$Res call({
 String? modelId, String? name, String? packageType, num? unitsPerBox, num count, List<KeeperModelWarehouseRowModel> warehouses
});




}
/// @nodoc
class _$KeeperProductModelStockModelCopyWithImpl<$Res>
    implements $KeeperProductModelStockModelCopyWith<$Res> {
  _$KeeperProductModelStockModelCopyWithImpl(this._self, this._then);

  final KeeperProductModelStockModel _self;
  final $Res Function(KeeperProductModelStockModel) _then;

/// Create a copy of KeeperProductModelStockModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? modelId = freezed,Object? name = freezed,Object? packageType = freezed,Object? unitsPerBox = freezed,Object? count = null,Object? warehouses = null,}) {
  return _then(_self.copyWith(
modelId: freezed == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,unitsPerBox: freezed == unitsPerBox ? _self.unitsPerBox : unitsPerBox // ignore: cast_nullable_to_non_nullable
as num?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,warehouses: null == warehouses ? _self.warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<KeeperModelWarehouseRowModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperProductModelStockModel].
extension KeeperProductModelStockModelPatterns on KeeperProductModelStockModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperProductModelStockModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperProductModelStockModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperProductModelStockModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperProductModelStockModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperProductModelStockModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperProductModelStockModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? modelId,  String? name,  String? packageType,  num? unitsPerBox,  num count,  List<KeeperModelWarehouseRowModel> warehouses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperProductModelStockModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? modelId,  String? name,  String? packageType,  num? unitsPerBox,  num count,  List<KeeperModelWarehouseRowModel> warehouses)  $default,) {final _that = this;
switch (_that) {
case _KeeperProductModelStockModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? modelId,  String? name,  String? packageType,  num? unitsPerBox,  num count,  List<KeeperModelWarehouseRowModel> warehouses)?  $default,) {final _that = this;
switch (_that) {
case _KeeperProductModelStockModel() when $default != null:
return $default(_that.modelId,_that.name,_that.packageType,_that.unitsPerBox,_that.count,_that.warehouses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperProductModelStockModel implements KeeperProductModelStockModel {
  const _KeeperProductModelStockModel({this.modelId, this.name, this.packageType, this.unitsPerBox, this.count = 0, final  List<KeeperModelWarehouseRowModel> warehouses = const <KeeperModelWarehouseRowModel>[]}): _warehouses = warehouses;
  factory _KeeperProductModelStockModel.fromJson(Map<String, dynamic> json) => _$KeeperProductModelStockModelFromJson(json);

@override final  String? modelId;
@override final  String? name;
@override final  String? packageType;
@override final  num? unitsPerBox;
@override@JsonKey() final  num count;
 final  List<KeeperModelWarehouseRowModel> _warehouses;
@override@JsonKey() List<KeeperModelWarehouseRowModel> get warehouses {
  if (_warehouses is EqualUnmodifiableListView) return _warehouses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warehouses);
}


/// Create a copy of KeeperProductModelStockModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperProductModelStockModelCopyWith<_KeeperProductModelStockModel> get copyWith => __$KeeperProductModelStockModelCopyWithImpl<_KeeperProductModelStockModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperProductModelStockModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperProductModelStockModel&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.packageType, packageType) || other.packageType == packageType)&&(identical(other.unitsPerBox, unitsPerBox) || other.unitsPerBox == unitsPerBox)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._warehouses, _warehouses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,modelId,name,packageType,unitsPerBox,count,const DeepCollectionEquality().hash(_warehouses));

@override
String toString() {
  return 'KeeperProductModelStockModel(modelId: $modelId, name: $name, packageType: $packageType, unitsPerBox: $unitsPerBox, count: $count, warehouses: $warehouses)';
}


}

/// @nodoc
abstract mixin class _$KeeperProductModelStockModelCopyWith<$Res> implements $KeeperProductModelStockModelCopyWith<$Res> {
  factory _$KeeperProductModelStockModelCopyWith(_KeeperProductModelStockModel value, $Res Function(_KeeperProductModelStockModel) _then) = __$KeeperProductModelStockModelCopyWithImpl;
@override @useResult
$Res call({
 String? modelId, String? name, String? packageType, num? unitsPerBox, num count, List<KeeperModelWarehouseRowModel> warehouses
});




}
/// @nodoc
class __$KeeperProductModelStockModelCopyWithImpl<$Res>
    implements _$KeeperProductModelStockModelCopyWith<$Res> {
  __$KeeperProductModelStockModelCopyWithImpl(this._self, this._then);

  final _KeeperProductModelStockModel _self;
  final $Res Function(_KeeperProductModelStockModel) _then;

/// Create a copy of KeeperProductModelStockModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? modelId = freezed,Object? name = freezed,Object? packageType = freezed,Object? unitsPerBox = freezed,Object? count = null,Object? warehouses = null,}) {
  return _then(_KeeperProductModelStockModel(
modelId: freezed == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,unitsPerBox: freezed == unitsPerBox ? _self.unitsPerBox : unitsPerBox // ignore: cast_nullable_to_non_nullable
as num?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,warehouses: null == warehouses ? _self._warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<KeeperModelWarehouseRowModel>,
  ));
}


}


/// @nodoc
mixin _$KeeperModelWarehouseRowModel {

 String? get warehouseId; String? get warehouseName; num get count;
/// Create a copy of KeeperModelWarehouseRowModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperModelWarehouseRowModelCopyWith<KeeperModelWarehouseRowModel> get copyWith => _$KeeperModelWarehouseRowModelCopyWithImpl<KeeperModelWarehouseRowModel>(this as KeeperModelWarehouseRowModel, _$identity);

  /// Serializes this KeeperModelWarehouseRowModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperModelWarehouseRowModel&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseId,warehouseName,count);

@override
String toString() {
  return 'KeeperModelWarehouseRowModel(warehouseId: $warehouseId, warehouseName: $warehouseName, count: $count)';
}


}

/// @nodoc
abstract mixin class $KeeperModelWarehouseRowModelCopyWith<$Res>  {
  factory $KeeperModelWarehouseRowModelCopyWith(KeeperModelWarehouseRowModel value, $Res Function(KeeperModelWarehouseRowModel) _then) = _$KeeperModelWarehouseRowModelCopyWithImpl;
@useResult
$Res call({
 String? warehouseId, String? warehouseName, num count
});




}
/// @nodoc
class _$KeeperModelWarehouseRowModelCopyWithImpl<$Res>
    implements $KeeperModelWarehouseRowModelCopyWith<$Res> {
  _$KeeperModelWarehouseRowModelCopyWithImpl(this._self, this._then);

  final KeeperModelWarehouseRowModel _self;
  final $Res Function(KeeperModelWarehouseRowModel) _then;

/// Create a copy of KeeperModelWarehouseRowModel
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


/// Adds pattern-matching-related methods to [KeeperModelWarehouseRowModel].
extension KeeperModelWarehouseRowModelPatterns on KeeperModelWarehouseRowModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperModelWarehouseRowModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperModelWarehouseRowModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperModelWarehouseRowModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperModelWarehouseRowModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperModelWarehouseRowModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperModelWarehouseRowModel() when $default != null:
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
case _KeeperModelWarehouseRowModel() when $default != null:
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
case _KeeperModelWarehouseRowModel():
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
case _KeeperModelWarehouseRowModel() when $default != null:
return $default(_that.warehouseId,_that.warehouseName,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperModelWarehouseRowModel implements KeeperModelWarehouseRowModel {
  const _KeeperModelWarehouseRowModel({this.warehouseId, this.warehouseName, this.count = 0});
  factory _KeeperModelWarehouseRowModel.fromJson(Map<String, dynamic> json) => _$KeeperModelWarehouseRowModelFromJson(json);

@override final  String? warehouseId;
@override final  String? warehouseName;
@override@JsonKey() final  num count;

/// Create a copy of KeeperModelWarehouseRowModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperModelWarehouseRowModelCopyWith<_KeeperModelWarehouseRowModel> get copyWith => __$KeeperModelWarehouseRowModelCopyWithImpl<_KeeperModelWarehouseRowModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperModelWarehouseRowModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperModelWarehouseRowModel&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warehouseId,warehouseName,count);

@override
String toString() {
  return 'KeeperModelWarehouseRowModel(warehouseId: $warehouseId, warehouseName: $warehouseName, count: $count)';
}


}

/// @nodoc
abstract mixin class _$KeeperModelWarehouseRowModelCopyWith<$Res> implements $KeeperModelWarehouseRowModelCopyWith<$Res> {
  factory _$KeeperModelWarehouseRowModelCopyWith(_KeeperModelWarehouseRowModel value, $Res Function(_KeeperModelWarehouseRowModel) _then) = __$KeeperModelWarehouseRowModelCopyWithImpl;
@override @useResult
$Res call({
 String? warehouseId, String? warehouseName, num count
});




}
/// @nodoc
class __$KeeperModelWarehouseRowModelCopyWithImpl<$Res>
    implements _$KeeperModelWarehouseRowModelCopyWith<$Res> {
  __$KeeperModelWarehouseRowModelCopyWithImpl(this._self, this._then);

  final _KeeperModelWarehouseRowModel _self;
  final $Res Function(_KeeperModelWarehouseRowModel) _then;

/// Create a copy of KeeperModelWarehouseRowModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warehouseId = freezed,Object? warehouseName = freezed,Object? count = null,}) {
  return _then(_KeeperModelWarehouseRowModel(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
