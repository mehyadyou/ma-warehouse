// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransferModel {

 String get id; String get fromWarehouseId; String get fromWarehouseName; String? get toWarehouseId; String? get toWarehouseName; String get productId; String get productName; String? get modelId; String? get modelName; int get quantity; String get description; String get status; DateTime? get completedAt; int get executedUnits; int get remainingUnits; DateTime get createdAt;
/// Create a copy of TransferModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferModelCopyWith<TransferModel> get copyWith => _$TransferModelCopyWithImpl<TransferModel>(this as TransferModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fromWarehouseId, fromWarehouseId) || other.fromWarehouseId == fromWarehouseId)&&(identical(other.fromWarehouseName, fromWarehouseName) || other.fromWarehouseName == fromWarehouseName)&&(identical(other.toWarehouseId, toWarehouseId) || other.toWarehouseId == toWarehouseId)&&(identical(other.toWarehouseName, toWarehouseName) || other.toWarehouseName == toWarehouseName)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.executedUnits, executedUnits) || other.executedUnits == executedUnits)&&(identical(other.remainingUnits, remainingUnits) || other.remainingUnits == remainingUnits)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,fromWarehouseId,fromWarehouseName,toWarehouseId,toWarehouseName,productId,productName,modelId,modelName,quantity,description,status,completedAt,executedUnits,remainingUnits,createdAt);

@override
String toString() {
  return 'TransferModel(id: $id, fromWarehouseId: $fromWarehouseId, fromWarehouseName: $fromWarehouseName, toWarehouseId: $toWarehouseId, toWarehouseName: $toWarehouseName, productId: $productId, productName: $productName, modelId: $modelId, modelName: $modelName, quantity: $quantity, description: $description, status: $status, completedAt: $completedAt, executedUnits: $executedUnits, remainingUnits: $remainingUnits, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TransferModelCopyWith<$Res>  {
  factory $TransferModelCopyWith(TransferModel value, $Res Function(TransferModel) _then) = _$TransferModelCopyWithImpl;
@useResult
$Res call({
 String id, String fromWarehouseId, String fromWarehouseName, String? toWarehouseId, String? toWarehouseName, String productId, String productName, String? modelId, String? modelName, int quantity, String description, String status, DateTime? completedAt, int executedUnits, int remainingUnits, DateTime createdAt
});




}
/// @nodoc
class _$TransferModelCopyWithImpl<$Res>
    implements $TransferModelCopyWith<$Res> {
  _$TransferModelCopyWithImpl(this._self, this._then);

  final TransferModel _self;
  final $Res Function(TransferModel) _then;

/// Create a copy of TransferModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromWarehouseId = null,Object? fromWarehouseName = null,Object? toWarehouseId = freezed,Object? toWarehouseName = freezed,Object? productId = null,Object? productName = null,Object? modelId = freezed,Object? modelName = freezed,Object? quantity = null,Object? description = null,Object? status = null,Object? completedAt = freezed,Object? executedUnits = null,Object? remainingUnits = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromWarehouseId: null == fromWarehouseId ? _self.fromWarehouseId : fromWarehouseId // ignore: cast_nullable_to_non_nullable
as String,fromWarehouseName: null == fromWarehouseName ? _self.fromWarehouseName : fromWarehouseName // ignore: cast_nullable_to_non_nullable
as String,toWarehouseId: freezed == toWarehouseId ? _self.toWarehouseId : toWarehouseId // ignore: cast_nullable_to_non_nullable
as String?,toWarehouseName: freezed == toWarehouseName ? _self.toWarehouseName : toWarehouseName // ignore: cast_nullable_to_non_nullable
as String?,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,modelId: freezed == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String?,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,executedUnits: null == executedUnits ? _self.executedUnits : executedUnits // ignore: cast_nullable_to_non_nullable
as int,remainingUnits: null == remainingUnits ? _self.remainingUnits : remainingUnits // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TransferModel].
extension TransferModelPatterns on TransferModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferModel value)  $default,){
final _that = this;
switch (_that) {
case _TransferModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransferModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fromWarehouseId,  String fromWarehouseName,  String? toWarehouseId,  String? toWarehouseName,  String productId,  String productName,  String? modelId,  String? modelName,  int quantity,  String description,  String status,  DateTime? completedAt,  int executedUnits,  int remainingUnits,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferModel() when $default != null:
return $default(_that.id,_that.fromWarehouseId,_that.fromWarehouseName,_that.toWarehouseId,_that.toWarehouseName,_that.productId,_that.productName,_that.modelId,_that.modelName,_that.quantity,_that.description,_that.status,_that.completedAt,_that.executedUnits,_that.remainingUnits,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fromWarehouseId,  String fromWarehouseName,  String? toWarehouseId,  String? toWarehouseName,  String productId,  String productName,  String? modelId,  String? modelName,  int quantity,  String description,  String status,  DateTime? completedAt,  int executedUnits,  int remainingUnits,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TransferModel():
return $default(_that.id,_that.fromWarehouseId,_that.fromWarehouseName,_that.toWarehouseId,_that.toWarehouseName,_that.productId,_that.productName,_that.modelId,_that.modelName,_that.quantity,_that.description,_that.status,_that.completedAt,_that.executedUnits,_that.remainingUnits,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fromWarehouseId,  String fromWarehouseName,  String? toWarehouseId,  String? toWarehouseName,  String productId,  String productName,  String? modelId,  String? modelName,  int quantity,  String description,  String status,  DateTime? completedAt,  int executedUnits,  int remainingUnits,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TransferModel() when $default != null:
return $default(_that.id,_that.fromWarehouseId,_that.fromWarehouseName,_that.toWarehouseId,_that.toWarehouseName,_that.productId,_that.productName,_that.modelId,_that.modelName,_that.quantity,_that.description,_that.status,_that.completedAt,_that.executedUnits,_that.remainingUnits,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _TransferModel implements TransferModel {
  const _TransferModel({required this.id, required this.fromWarehouseId, required this.fromWarehouseName, this.toWarehouseId, this.toWarehouseName, required this.productId, required this.productName, this.modelId, this.modelName, required this.quantity, this.description = '', this.status = 'PENDING', this.completedAt, this.executedUnits = 0, this.remainingUnits = 0, required this.createdAt});
  

@override final  String id;
@override final  String fromWarehouseId;
@override final  String fromWarehouseName;
@override final  String? toWarehouseId;
@override final  String? toWarehouseName;
@override final  String productId;
@override final  String productName;
@override final  String? modelId;
@override final  String? modelName;
@override final  int quantity;
@override@JsonKey() final  String description;
@override@JsonKey() final  String status;
@override final  DateTime? completedAt;
@override@JsonKey() final  int executedUnits;
@override@JsonKey() final  int remainingUnits;
@override final  DateTime createdAt;

/// Create a copy of TransferModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferModelCopyWith<_TransferModel> get copyWith => __$TransferModelCopyWithImpl<_TransferModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fromWarehouseId, fromWarehouseId) || other.fromWarehouseId == fromWarehouseId)&&(identical(other.fromWarehouseName, fromWarehouseName) || other.fromWarehouseName == fromWarehouseName)&&(identical(other.toWarehouseId, toWarehouseId) || other.toWarehouseId == toWarehouseId)&&(identical(other.toWarehouseName, toWarehouseName) || other.toWarehouseName == toWarehouseName)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.executedUnits, executedUnits) || other.executedUnits == executedUnits)&&(identical(other.remainingUnits, remainingUnits) || other.remainingUnits == remainingUnits)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,fromWarehouseId,fromWarehouseName,toWarehouseId,toWarehouseName,productId,productName,modelId,modelName,quantity,description,status,completedAt,executedUnits,remainingUnits,createdAt);

@override
String toString() {
  return 'TransferModel(id: $id, fromWarehouseId: $fromWarehouseId, fromWarehouseName: $fromWarehouseName, toWarehouseId: $toWarehouseId, toWarehouseName: $toWarehouseName, productId: $productId, productName: $productName, modelId: $modelId, modelName: $modelName, quantity: $quantity, description: $description, status: $status, completedAt: $completedAt, executedUnits: $executedUnits, remainingUnits: $remainingUnits, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TransferModelCopyWith<$Res> implements $TransferModelCopyWith<$Res> {
  factory _$TransferModelCopyWith(_TransferModel value, $Res Function(_TransferModel) _then) = __$TransferModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String fromWarehouseId, String fromWarehouseName, String? toWarehouseId, String? toWarehouseName, String productId, String productName, String? modelId, String? modelName, int quantity, String description, String status, DateTime? completedAt, int executedUnits, int remainingUnits, DateTime createdAt
});




}
/// @nodoc
class __$TransferModelCopyWithImpl<$Res>
    implements _$TransferModelCopyWith<$Res> {
  __$TransferModelCopyWithImpl(this._self, this._then);

  final _TransferModel _self;
  final $Res Function(_TransferModel) _then;

/// Create a copy of TransferModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromWarehouseId = null,Object? fromWarehouseName = null,Object? toWarehouseId = freezed,Object? toWarehouseName = freezed,Object? productId = null,Object? productName = null,Object? modelId = freezed,Object? modelName = freezed,Object? quantity = null,Object? description = null,Object? status = null,Object? completedAt = freezed,Object? executedUnits = null,Object? remainingUnits = null,Object? createdAt = null,}) {
  return _then(_TransferModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromWarehouseId: null == fromWarehouseId ? _self.fromWarehouseId : fromWarehouseId // ignore: cast_nullable_to_non_nullable
as String,fromWarehouseName: null == fromWarehouseName ? _self.fromWarehouseName : fromWarehouseName // ignore: cast_nullable_to_non_nullable
as String,toWarehouseId: freezed == toWarehouseId ? _self.toWarehouseId : toWarehouseId // ignore: cast_nullable_to_non_nullable
as String?,toWarehouseName: freezed == toWarehouseName ? _self.toWarehouseName : toWarehouseName // ignore: cast_nullable_to_non_nullable
as String?,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,modelId: freezed == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String?,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,executedUnits: null == executedUnits ? _self.executedUnits : executedUnits // ignore: cast_nullable_to_non_nullable
as int,remainingUnits: null == remainingUnits ? _self.remainingUnits : remainingUnits // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
