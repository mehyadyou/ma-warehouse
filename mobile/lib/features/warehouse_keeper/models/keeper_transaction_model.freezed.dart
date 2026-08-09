// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keeper_transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KeeperTransactionModel {

 String get type; String get productName; String get userName; int get quantity; String get createdAt;
/// Create a copy of KeeperTransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeeperTransactionModelCopyWith<KeeperTransactionModel> get copyWith => _$KeeperTransactionModelCopyWithImpl<KeeperTransactionModel>(this as KeeperTransactionModel, _$identity);

  /// Serializes this KeeperTransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeeperTransactionModel&&(identical(other.type, type) || other.type == type)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,productName,userName,quantity,createdAt);

@override
String toString() {
  return 'KeeperTransactionModel(type: $type, productName: $productName, userName: $userName, quantity: $quantity, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $KeeperTransactionModelCopyWith<$Res>  {
  factory $KeeperTransactionModelCopyWith(KeeperTransactionModel value, $Res Function(KeeperTransactionModel) _then) = _$KeeperTransactionModelCopyWithImpl;
@useResult
$Res call({
 String type, String productName, String userName, int quantity, String createdAt
});




}
/// @nodoc
class _$KeeperTransactionModelCopyWithImpl<$Res>
    implements $KeeperTransactionModelCopyWith<$Res> {
  _$KeeperTransactionModelCopyWithImpl(this._self, this._then);

  final KeeperTransactionModel _self;
  final $Res Function(KeeperTransactionModel) _then;

/// Create a copy of KeeperTransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? productName = null,Object? userName = null,Object? quantity = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [KeeperTransactionModel].
extension KeeperTransactionModelPatterns on KeeperTransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeeperTransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeeperTransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeeperTransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _KeeperTransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeeperTransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _KeeperTransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String productName,  String userName,  int quantity,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeeperTransactionModel() when $default != null:
return $default(_that.type,_that.productName,_that.userName,_that.quantity,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String productName,  String userName,  int quantity,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _KeeperTransactionModel():
return $default(_that.type,_that.productName,_that.userName,_that.quantity,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String productName,  String userName,  int quantity,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _KeeperTransactionModel() when $default != null:
return $default(_that.type,_that.productName,_that.userName,_that.quantity,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeeperTransactionModel implements KeeperTransactionModel {
  const _KeeperTransactionModel({this.type = '', this.productName = '', this.userName = '', this.quantity = 0, this.createdAt = ''});
  factory _KeeperTransactionModel.fromJson(Map<String, dynamic> json) => _$KeeperTransactionModelFromJson(json);

@override@JsonKey() final  String type;
@override@JsonKey() final  String productName;
@override@JsonKey() final  String userName;
@override@JsonKey() final  int quantity;
@override@JsonKey() final  String createdAt;

/// Create a copy of KeeperTransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeeperTransactionModelCopyWith<_KeeperTransactionModel> get copyWith => __$KeeperTransactionModelCopyWithImpl<_KeeperTransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeeperTransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeeperTransactionModel&&(identical(other.type, type) || other.type == type)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,productName,userName,quantity,createdAt);

@override
String toString() {
  return 'KeeperTransactionModel(type: $type, productName: $productName, userName: $userName, quantity: $quantity, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$KeeperTransactionModelCopyWith<$Res> implements $KeeperTransactionModelCopyWith<$Res> {
  factory _$KeeperTransactionModelCopyWith(_KeeperTransactionModel value, $Res Function(_KeeperTransactionModel) _then) = __$KeeperTransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String type, String productName, String userName, int quantity, String createdAt
});




}
/// @nodoc
class __$KeeperTransactionModelCopyWithImpl<$Res>
    implements _$KeeperTransactionModelCopyWith<$Res> {
  __$KeeperTransactionModelCopyWithImpl(this._self, this._then);

  final _KeeperTransactionModel _self;
  final $Res Function(_KeeperTransactionModel) _then;

/// Create a copy of KeeperTransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? productName = null,Object? userName = null,Object? quantity = null,Object? createdAt = null,}) {
  return _then(_KeeperTransactionModel(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
