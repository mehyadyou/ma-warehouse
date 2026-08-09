// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionEntryModel {

 String? get type; String? get productName; String? get title; String? get warehouseName; String? get userName; num get quantity; String? get createdAt;
/// Create a copy of TransactionEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionEntryModelCopyWith<TransactionEntryModel> get copyWith => _$TransactionEntryModelCopyWithImpl<TransactionEntryModel>(this as TransactionEntryModel, _$identity);

  /// Serializes this TransactionEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionEntryModel&&(identical(other.type, type) || other.type == type)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.title, title) || other.title == title)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,productName,title,warehouseName,userName,quantity,createdAt);

@override
String toString() {
  return 'TransactionEntryModel(type: $type, productName: $productName, title: $title, warehouseName: $warehouseName, userName: $userName, quantity: $quantity, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TransactionEntryModelCopyWith<$Res>  {
  factory $TransactionEntryModelCopyWith(TransactionEntryModel value, $Res Function(TransactionEntryModel) _then) = _$TransactionEntryModelCopyWithImpl;
@useResult
$Res call({
 String? type, String? productName, String? title, String? warehouseName, String? userName, num quantity, String? createdAt
});




}
/// @nodoc
class _$TransactionEntryModelCopyWithImpl<$Res>
    implements $TransactionEntryModelCopyWith<$Res> {
  _$TransactionEntryModelCopyWithImpl(this._self, this._then);

  final TransactionEntryModel _self;
  final $Res Function(TransactionEntryModel) _then;

/// Create a copy of TransactionEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? productName = freezed,Object? title = freezed,Object? warehouseName = freezed,Object? userName = freezed,Object? quantity = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionEntryModel].
extension TransactionEntryModelPatterns on TransactionEntryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionEntryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionEntryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionEntryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  String? productName,  String? title,  String? warehouseName,  String? userName,  num quantity,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionEntryModel() when $default != null:
return $default(_that.type,_that.productName,_that.title,_that.warehouseName,_that.userName,_that.quantity,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  String? productName,  String? title,  String? warehouseName,  String? userName,  num quantity,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _TransactionEntryModel():
return $default(_that.type,_that.productName,_that.title,_that.warehouseName,_that.userName,_that.quantity,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  String? productName,  String? title,  String? warehouseName,  String? userName,  num quantity,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TransactionEntryModel() when $default != null:
return $default(_that.type,_that.productName,_that.title,_that.warehouseName,_that.userName,_that.quantity,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionEntryModel implements TransactionEntryModel {
  const _TransactionEntryModel({this.type, this.productName, this.title, this.warehouseName, this.userName, this.quantity = 0, this.createdAt});
  factory _TransactionEntryModel.fromJson(Map<String, dynamic> json) => _$TransactionEntryModelFromJson(json);

@override final  String? type;
@override final  String? productName;
@override final  String? title;
@override final  String? warehouseName;
@override final  String? userName;
@override@JsonKey() final  num quantity;
@override final  String? createdAt;

/// Create a copy of TransactionEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionEntryModelCopyWith<_TransactionEntryModel> get copyWith => __$TransactionEntryModelCopyWithImpl<_TransactionEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionEntryModel&&(identical(other.type, type) || other.type == type)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.title, title) || other.title == title)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,productName,title,warehouseName,userName,quantity,createdAt);

@override
String toString() {
  return 'TransactionEntryModel(type: $type, productName: $productName, title: $title, warehouseName: $warehouseName, userName: $userName, quantity: $quantity, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionEntryModelCopyWith<$Res> implements $TransactionEntryModelCopyWith<$Res> {
  factory _$TransactionEntryModelCopyWith(_TransactionEntryModel value, $Res Function(_TransactionEntryModel) _then) = __$TransactionEntryModelCopyWithImpl;
@override @useResult
$Res call({
 String? type, String? productName, String? title, String? warehouseName, String? userName, num quantity, String? createdAt
});




}
/// @nodoc
class __$TransactionEntryModelCopyWithImpl<$Res>
    implements _$TransactionEntryModelCopyWith<$Res> {
  __$TransactionEntryModelCopyWithImpl(this._self, this._then);

  final _TransactionEntryModel _self;
  final $Res Function(_TransactionEntryModel) _then;

/// Create a copy of TransactionEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? productName = freezed,Object? title = freezed,Object? warehouseName = freezed,Object? userName = freezed,Object? quantity = null,Object? createdAt = freezed,}) {
  return _then(_TransactionEntryModel(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
