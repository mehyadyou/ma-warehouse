// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventorySummaryModel {

 List<InventoryRowModel> get inventory; num get totalRegisteredProducts; num get totalInventoryUnits; num get returnedUnits;
/// Create a copy of InventorySummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventorySummaryModelCopyWith<InventorySummaryModel> get copyWith => _$InventorySummaryModelCopyWithImpl<InventorySummaryModel>(this as InventorySummaryModel, _$identity);

  /// Serializes this InventorySummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventorySummaryModel&&const DeepCollectionEquality().equals(other.inventory, inventory)&&(identical(other.totalRegisteredProducts, totalRegisteredProducts) || other.totalRegisteredProducts == totalRegisteredProducts)&&(identical(other.totalInventoryUnits, totalInventoryUnits) || other.totalInventoryUnits == totalInventoryUnits)&&(identical(other.returnedUnits, returnedUnits) || other.returnedUnits == returnedUnits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(inventory),totalRegisteredProducts,totalInventoryUnits,returnedUnits);

@override
String toString() {
  return 'InventorySummaryModel(inventory: $inventory, totalRegisteredProducts: $totalRegisteredProducts, totalInventoryUnits: $totalInventoryUnits, returnedUnits: $returnedUnits)';
}


}

/// @nodoc
abstract mixin class $InventorySummaryModelCopyWith<$Res>  {
  factory $InventorySummaryModelCopyWith(InventorySummaryModel value, $Res Function(InventorySummaryModel) _then) = _$InventorySummaryModelCopyWithImpl;
@useResult
$Res call({
 List<InventoryRowModel> inventory, num totalRegisteredProducts, num totalInventoryUnits, num returnedUnits
});




}
/// @nodoc
class _$InventorySummaryModelCopyWithImpl<$Res>
    implements $InventorySummaryModelCopyWith<$Res> {
  _$InventorySummaryModelCopyWithImpl(this._self, this._then);

  final InventorySummaryModel _self;
  final $Res Function(InventorySummaryModel) _then;

/// Create a copy of InventorySummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inventory = null,Object? totalRegisteredProducts = null,Object? totalInventoryUnits = null,Object? returnedUnits = null,}) {
  return _then(_self.copyWith(
inventory: null == inventory ? _self.inventory : inventory // ignore: cast_nullable_to_non_nullable
as List<InventoryRowModel>,totalRegisteredProducts: null == totalRegisteredProducts ? _self.totalRegisteredProducts : totalRegisteredProducts // ignore: cast_nullable_to_non_nullable
as num,totalInventoryUnits: null == totalInventoryUnits ? _self.totalInventoryUnits : totalInventoryUnits // ignore: cast_nullable_to_non_nullable
as num,returnedUnits: null == returnedUnits ? _self.returnedUnits : returnedUnits // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [InventorySummaryModel].
extension InventorySummaryModelPatterns on InventorySummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventorySummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventorySummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventorySummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _InventorySummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventorySummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _InventorySummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InventoryRowModel> inventory,  num totalRegisteredProducts,  num totalInventoryUnits,  num returnedUnits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventorySummaryModel() when $default != null:
return $default(_that.inventory,_that.totalRegisteredProducts,_that.totalInventoryUnits,_that.returnedUnits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InventoryRowModel> inventory,  num totalRegisteredProducts,  num totalInventoryUnits,  num returnedUnits)  $default,) {final _that = this;
switch (_that) {
case _InventorySummaryModel():
return $default(_that.inventory,_that.totalRegisteredProducts,_that.totalInventoryUnits,_that.returnedUnits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InventoryRowModel> inventory,  num totalRegisteredProducts,  num totalInventoryUnits,  num returnedUnits)?  $default,) {final _that = this;
switch (_that) {
case _InventorySummaryModel() when $default != null:
return $default(_that.inventory,_that.totalRegisteredProducts,_that.totalInventoryUnits,_that.returnedUnits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventorySummaryModel implements InventorySummaryModel {
  const _InventorySummaryModel({final  List<InventoryRowModel> inventory = const <InventoryRowModel>[], this.totalRegisteredProducts = 0, this.totalInventoryUnits = 0, this.returnedUnits = 0}): _inventory = inventory;
  factory _InventorySummaryModel.fromJson(Map<String, dynamic> json) => _$InventorySummaryModelFromJson(json);

 final  List<InventoryRowModel> _inventory;
@override@JsonKey() List<InventoryRowModel> get inventory {
  if (_inventory is EqualUnmodifiableListView) return _inventory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inventory);
}

@override@JsonKey() final  num totalRegisteredProducts;
@override@JsonKey() final  num totalInventoryUnits;
@override@JsonKey() final  num returnedUnits;

/// Create a copy of InventorySummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventorySummaryModelCopyWith<_InventorySummaryModel> get copyWith => __$InventorySummaryModelCopyWithImpl<_InventorySummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventorySummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventorySummaryModel&&const DeepCollectionEquality().equals(other._inventory, _inventory)&&(identical(other.totalRegisteredProducts, totalRegisteredProducts) || other.totalRegisteredProducts == totalRegisteredProducts)&&(identical(other.totalInventoryUnits, totalInventoryUnits) || other.totalInventoryUnits == totalInventoryUnits)&&(identical(other.returnedUnits, returnedUnits) || other.returnedUnits == returnedUnits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_inventory),totalRegisteredProducts,totalInventoryUnits,returnedUnits);

@override
String toString() {
  return 'InventorySummaryModel(inventory: $inventory, totalRegisteredProducts: $totalRegisteredProducts, totalInventoryUnits: $totalInventoryUnits, returnedUnits: $returnedUnits)';
}


}

/// @nodoc
abstract mixin class _$InventorySummaryModelCopyWith<$Res> implements $InventorySummaryModelCopyWith<$Res> {
  factory _$InventorySummaryModelCopyWith(_InventorySummaryModel value, $Res Function(_InventorySummaryModel) _then) = __$InventorySummaryModelCopyWithImpl;
@override @useResult
$Res call({
 List<InventoryRowModel> inventory, num totalRegisteredProducts, num totalInventoryUnits, num returnedUnits
});




}
/// @nodoc
class __$InventorySummaryModelCopyWithImpl<$Res>
    implements _$InventorySummaryModelCopyWith<$Res> {
  __$InventorySummaryModelCopyWithImpl(this._self, this._then);

  final _InventorySummaryModel _self;
  final $Res Function(_InventorySummaryModel) _then;

/// Create a copy of InventorySummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inventory = null,Object? totalRegisteredProducts = null,Object? totalInventoryUnits = null,Object? returnedUnits = null,}) {
  return _then(_InventorySummaryModel(
inventory: null == inventory ? _self._inventory : inventory // ignore: cast_nullable_to_non_nullable
as List<InventoryRowModel>,totalRegisteredProducts: null == totalRegisteredProducts ? _self.totalRegisteredProducts : totalRegisteredProducts // ignore: cast_nullable_to_non_nullable
as num,totalInventoryUnits: null == totalInventoryUnits ? _self.totalInventoryUnits : totalInventoryUnits // ignore: cast_nullable_to_non_nullable
as num,returnedUnits: null == returnedUnits ? _self.returnedUnits : returnedUnits // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$InventoryRowModel {

 String? get name; num get totalCount; String? get unit;
/// Create a copy of InventoryRowModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryRowModelCopyWith<InventoryRowModel> get copyWith => _$InventoryRowModelCopyWithImpl<InventoryRowModel>(this as InventoryRowModel, _$identity);

  /// Serializes this InventoryRowModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryRowModel&&(identical(other.name, name) || other.name == name)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,totalCount,unit);

@override
String toString() {
  return 'InventoryRowModel(name: $name, totalCount: $totalCount, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $InventoryRowModelCopyWith<$Res>  {
  factory $InventoryRowModelCopyWith(InventoryRowModel value, $Res Function(InventoryRowModel) _then) = _$InventoryRowModelCopyWithImpl;
@useResult
$Res call({
 String? name, num totalCount, String? unit
});




}
/// @nodoc
class _$InventoryRowModelCopyWithImpl<$Res>
    implements $InventoryRowModelCopyWith<$Res> {
  _$InventoryRowModelCopyWithImpl(this._self, this._then);

  final InventoryRowModel _self;
  final $Res Function(InventoryRowModel) _then;

/// Create a copy of InventoryRowModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? totalCount = null,Object? unit = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryRowModel].
extension InventoryRowModelPatterns on InventoryRowModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryRowModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryRowModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryRowModel value)  $default,){
final _that = this;
switch (_that) {
case _InventoryRowModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryRowModel value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryRowModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  num totalCount,  String? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryRowModel() when $default != null:
return $default(_that.name,_that.totalCount,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  num totalCount,  String? unit)  $default,) {final _that = this;
switch (_that) {
case _InventoryRowModel():
return $default(_that.name,_that.totalCount,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  num totalCount,  String? unit)?  $default,) {final _that = this;
switch (_that) {
case _InventoryRowModel() when $default != null:
return $default(_that.name,_that.totalCount,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryRowModel implements InventoryRowModel {
  const _InventoryRowModel({this.name, this.totalCount = 0, this.unit});
  factory _InventoryRowModel.fromJson(Map<String, dynamic> json) => _$InventoryRowModelFromJson(json);

@override final  String? name;
@override@JsonKey() final  num totalCount;
@override final  String? unit;

/// Create a copy of InventoryRowModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryRowModelCopyWith<_InventoryRowModel> get copyWith => __$InventoryRowModelCopyWithImpl<_InventoryRowModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryRowModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryRowModel&&(identical(other.name, name) || other.name == name)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,totalCount,unit);

@override
String toString() {
  return 'InventoryRowModel(name: $name, totalCount: $totalCount, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$InventoryRowModelCopyWith<$Res> implements $InventoryRowModelCopyWith<$Res> {
  factory _$InventoryRowModelCopyWith(_InventoryRowModel value, $Res Function(_InventoryRowModel) _then) = __$InventoryRowModelCopyWithImpl;
@override @useResult
$Res call({
 String? name, num totalCount, String? unit
});




}
/// @nodoc
class __$InventoryRowModelCopyWithImpl<$Res>
    implements _$InventoryRowModelCopyWith<$Res> {
  __$InventoryRowModelCopyWithImpl(this._self, this._then);

  final _InventoryRowModel _self;
  final $Res Function(_InventoryRowModel) _then;

/// Create a copy of InventoryRowModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? totalCount = null,Object? unit = freezed,}) {
  return _then(_InventoryRowModel(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as num,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
