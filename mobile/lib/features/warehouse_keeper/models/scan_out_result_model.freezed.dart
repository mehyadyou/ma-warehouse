// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_out_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScanOutResultModel {

 bool get valid; String get error; ScanOutCartonModel? get carton;/// وقتی چند سفارش/دستور فعال برای همین کالا/مدل وجود دارد — لیست هدف‌های ممکن
/// برای انتخاب صریح انباردار (خطای ۴۰۰ با همین لیست)
 List<ScanOutTargetModel>? get candidates;
/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanOutResultModelCopyWith<ScanOutResultModel> get copyWith => _$ScanOutResultModelCopyWithImpl<ScanOutResultModel>(this as ScanOutResultModel, _$identity);

  /// Serializes this ScanOutResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanOutResultModel&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.error, error) || other.error == error)&&(identical(other.carton, carton) || other.carton == carton)&&const DeepCollectionEquality().equals(other.candidates, candidates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,valid,error,carton,const DeepCollectionEquality().hash(candidates));

@override
String toString() {
  return 'ScanOutResultModel(valid: $valid, error: $error, carton: $carton, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class $ScanOutResultModelCopyWith<$Res>  {
  factory $ScanOutResultModelCopyWith(ScanOutResultModel value, $Res Function(ScanOutResultModel) _then) = _$ScanOutResultModelCopyWithImpl;
@useResult
$Res call({
 bool valid, String error, ScanOutCartonModel? carton, List<ScanOutTargetModel>? candidates
});


$ScanOutCartonModelCopyWith<$Res>? get carton;

}
/// @nodoc
class _$ScanOutResultModelCopyWithImpl<$Res>
    implements $ScanOutResultModelCopyWith<$Res> {
  _$ScanOutResultModelCopyWithImpl(this._self, this._then);

  final ScanOutResultModel _self;
  final $Res Function(ScanOutResultModel) _then;

/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valid = null,Object? error = null,Object? carton = freezed,Object? candidates = freezed,}) {
  return _then(_self.copyWith(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,carton: freezed == carton ? _self.carton : carton // ignore: cast_nullable_to_non_nullable
as ScanOutCartonModel?,candidates: freezed == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<ScanOutTargetModel>?,
  ));
}
/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanOutCartonModelCopyWith<$Res>? get carton {
    if (_self.carton == null) {
    return null;
  }

  return $ScanOutCartonModelCopyWith<$Res>(_self.carton!, (value) {
    return _then(_self.copyWith(carton: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScanOutResultModel].
extension ScanOutResultModelPatterns on ScanOutResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanOutResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanOutResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanOutResultModel value)  $default,){
final _that = this;
switch (_that) {
case _ScanOutResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanOutResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScanOutResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool valid,  String error,  ScanOutCartonModel? carton,  List<ScanOutTargetModel>? candidates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanOutResultModel() when $default != null:
return $default(_that.valid,_that.error,_that.carton,_that.candidates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool valid,  String error,  ScanOutCartonModel? carton,  List<ScanOutTargetModel>? candidates)  $default,) {final _that = this;
switch (_that) {
case _ScanOutResultModel():
return $default(_that.valid,_that.error,_that.carton,_that.candidates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool valid,  String error,  ScanOutCartonModel? carton,  List<ScanOutTargetModel>? candidates)?  $default,) {final _that = this;
switch (_that) {
case _ScanOutResultModel() when $default != null:
return $default(_that.valid,_that.error,_that.carton,_that.candidates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanOutResultModel implements ScanOutResultModel {
  const _ScanOutResultModel({this.valid = false, this.error = '', this.carton, final  List<ScanOutTargetModel>? candidates}): _candidates = candidates;
  factory _ScanOutResultModel.fromJson(Map<String, dynamic> json) => _$ScanOutResultModelFromJson(json);

@override@JsonKey() final  bool valid;
@override@JsonKey() final  String error;
@override final  ScanOutCartonModel? carton;
/// وقتی چند سفارش/دستور فعال برای همین کالا/مدل وجود دارد — لیست هدف‌های ممکن
/// برای انتخاب صریح انباردار (خطای ۴۰۰ با همین لیست)
 final  List<ScanOutTargetModel>? _candidates;
/// وقتی چند سفارش/دستور فعال برای همین کالا/مدل وجود دارد — لیست هدف‌های ممکن
/// برای انتخاب صریح انباردار (خطای ۴۰۰ با همین لیست)
@override List<ScanOutTargetModel>? get candidates {
  final value = _candidates;
  if (value == null) return null;
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanOutResultModelCopyWith<_ScanOutResultModel> get copyWith => __$ScanOutResultModelCopyWithImpl<_ScanOutResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanOutResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanOutResultModel&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.error, error) || other.error == error)&&(identical(other.carton, carton) || other.carton == carton)&&const DeepCollectionEquality().equals(other._candidates, _candidates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,valid,error,carton,const DeepCollectionEquality().hash(_candidates));

@override
String toString() {
  return 'ScanOutResultModel(valid: $valid, error: $error, carton: $carton, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class _$ScanOutResultModelCopyWith<$Res> implements $ScanOutResultModelCopyWith<$Res> {
  factory _$ScanOutResultModelCopyWith(_ScanOutResultModel value, $Res Function(_ScanOutResultModel) _then) = __$ScanOutResultModelCopyWithImpl;
@override @useResult
$Res call({
 bool valid, String error, ScanOutCartonModel? carton, List<ScanOutTargetModel>? candidates
});


@override $ScanOutCartonModelCopyWith<$Res>? get carton;

}
/// @nodoc
class __$ScanOutResultModelCopyWithImpl<$Res>
    implements _$ScanOutResultModelCopyWith<$Res> {
  __$ScanOutResultModelCopyWithImpl(this._self, this._then);

  final _ScanOutResultModel _self;
  final $Res Function(_ScanOutResultModel) _then;

/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valid = null,Object? error = null,Object? carton = freezed,Object? candidates = freezed,}) {
  return _then(_ScanOutResultModel(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,carton: freezed == carton ? _self.carton : carton // ignore: cast_nullable_to_non_nullable
as ScanOutCartonModel?,candidates: freezed == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<ScanOutTargetModel>?,
  ));
}

/// Create a copy of ScanOutResultModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanOutCartonModelCopyWith<$Res>? get carton {
    if (_self.carton == null) {
    return null;
  }

  return $ScanOutCartonModelCopyWith<$Res>(_self.carton!, (value) {
    return _then(_self.copyWith(carton: value));
  });
}
}


/// @nodoc
mixin _$ScanOutTargetModel {

/// 'order' یا 'transfer'
 String get kind; String get id;/// مخصوص سفارش
 int? get orderNumber; String? get city; String? get receiverName; String? get carrier; String? get customerPhone;/// مخصوص دستور خروج/جابه‌جایی
 String get productName; String? get modelName; int? get quantity; String? get toWarehouseName;
/// Create a copy of ScanOutTargetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanOutTargetModelCopyWith<ScanOutTargetModel> get copyWith => _$ScanOutTargetModelCopyWithImpl<ScanOutTargetModel>(this as ScanOutTargetModel, _$identity);

  /// Serializes this ScanOutTargetModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanOutTargetModel&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.city, city) || other.city == city)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.toWarehouseName, toWarehouseName) || other.toWarehouseName == toWarehouseName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,id,orderNumber,city,receiverName,carrier,customerPhone,productName,modelName,quantity,toWarehouseName);

@override
String toString() {
  return 'ScanOutTargetModel(kind: $kind, id: $id, orderNumber: $orderNumber, city: $city, receiverName: $receiverName, carrier: $carrier, customerPhone: $customerPhone, productName: $productName, modelName: $modelName, quantity: $quantity, toWarehouseName: $toWarehouseName)';
}


}

/// @nodoc
abstract mixin class $ScanOutTargetModelCopyWith<$Res>  {
  factory $ScanOutTargetModelCopyWith(ScanOutTargetModel value, $Res Function(ScanOutTargetModel) _then) = _$ScanOutTargetModelCopyWithImpl;
@useResult
$Res call({
 String kind, String id, int? orderNumber, String? city, String? receiverName, String? carrier, String? customerPhone, String productName, String? modelName, int? quantity, String? toWarehouseName
});




}
/// @nodoc
class _$ScanOutTargetModelCopyWithImpl<$Res>
    implements $ScanOutTargetModelCopyWith<$Res> {
  _$ScanOutTargetModelCopyWithImpl(this._self, this._then);

  final ScanOutTargetModel _self;
  final $Res Function(ScanOutTargetModel) _then;

/// Create a copy of ScanOutTargetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? id = null,Object? orderNumber = freezed,Object? city = freezed,Object? receiverName = freezed,Object? carrier = freezed,Object? customerPhone = freezed,Object? productName = null,Object? modelName = freezed,Object? quantity = freezed,Object? toWarehouseName = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,carrier: freezed == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,toWarehouseName: freezed == toWarehouseName ? _self.toWarehouseName : toWarehouseName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScanOutTargetModel].
extension ScanOutTargetModelPatterns on ScanOutTargetModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanOutTargetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanOutTargetModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanOutTargetModel value)  $default,){
final _that = this;
switch (_that) {
case _ScanOutTargetModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanOutTargetModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScanOutTargetModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  String id,  int? orderNumber,  String? city,  String? receiverName,  String? carrier,  String? customerPhone,  String productName,  String? modelName,  int? quantity,  String? toWarehouseName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanOutTargetModel() when $default != null:
return $default(_that.kind,_that.id,_that.orderNumber,_that.city,_that.receiverName,_that.carrier,_that.customerPhone,_that.productName,_that.modelName,_that.quantity,_that.toWarehouseName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  String id,  int? orderNumber,  String? city,  String? receiverName,  String? carrier,  String? customerPhone,  String productName,  String? modelName,  int? quantity,  String? toWarehouseName)  $default,) {final _that = this;
switch (_that) {
case _ScanOutTargetModel():
return $default(_that.kind,_that.id,_that.orderNumber,_that.city,_that.receiverName,_that.carrier,_that.customerPhone,_that.productName,_that.modelName,_that.quantity,_that.toWarehouseName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  String id,  int? orderNumber,  String? city,  String? receiverName,  String? carrier,  String? customerPhone,  String productName,  String? modelName,  int? quantity,  String? toWarehouseName)?  $default,) {final _that = this;
switch (_that) {
case _ScanOutTargetModel() when $default != null:
return $default(_that.kind,_that.id,_that.orderNumber,_that.city,_that.receiverName,_that.carrier,_that.customerPhone,_that.productName,_that.modelName,_that.quantity,_that.toWarehouseName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanOutTargetModel implements ScanOutTargetModel {
  const _ScanOutTargetModel({this.kind = '', this.id = '', this.orderNumber, this.city, this.receiverName, this.carrier, this.customerPhone, this.productName = '', this.modelName, this.quantity, this.toWarehouseName});
  factory _ScanOutTargetModel.fromJson(Map<String, dynamic> json) => _$ScanOutTargetModelFromJson(json);

/// 'order' یا 'transfer'
@override@JsonKey() final  String kind;
@override@JsonKey() final  String id;
/// مخصوص سفارش
@override final  int? orderNumber;
@override final  String? city;
@override final  String? receiverName;
@override final  String? carrier;
@override final  String? customerPhone;
/// مخصوص دستور خروج/جابه‌جایی
@override@JsonKey() final  String productName;
@override final  String? modelName;
@override final  int? quantity;
@override final  String? toWarehouseName;

/// Create a copy of ScanOutTargetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanOutTargetModelCopyWith<_ScanOutTargetModel> get copyWith => __$ScanOutTargetModelCopyWithImpl<_ScanOutTargetModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanOutTargetModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanOutTargetModel&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.city, city) || other.city == city)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.toWarehouseName, toWarehouseName) || other.toWarehouseName == toWarehouseName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,id,orderNumber,city,receiverName,carrier,customerPhone,productName,modelName,quantity,toWarehouseName);

@override
String toString() {
  return 'ScanOutTargetModel(kind: $kind, id: $id, orderNumber: $orderNumber, city: $city, receiverName: $receiverName, carrier: $carrier, customerPhone: $customerPhone, productName: $productName, modelName: $modelName, quantity: $quantity, toWarehouseName: $toWarehouseName)';
}


}

/// @nodoc
abstract mixin class _$ScanOutTargetModelCopyWith<$Res> implements $ScanOutTargetModelCopyWith<$Res> {
  factory _$ScanOutTargetModelCopyWith(_ScanOutTargetModel value, $Res Function(_ScanOutTargetModel) _then) = __$ScanOutTargetModelCopyWithImpl;
@override @useResult
$Res call({
 String kind, String id, int? orderNumber, String? city, String? receiverName, String? carrier, String? customerPhone, String productName, String? modelName, int? quantity, String? toWarehouseName
});




}
/// @nodoc
class __$ScanOutTargetModelCopyWithImpl<$Res>
    implements _$ScanOutTargetModelCopyWith<$Res> {
  __$ScanOutTargetModelCopyWithImpl(this._self, this._then);

  final _ScanOutTargetModel _self;
  final $Res Function(_ScanOutTargetModel) _then;

/// Create a copy of ScanOutTargetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? id = null,Object? orderNumber = freezed,Object? city = freezed,Object? receiverName = freezed,Object? carrier = freezed,Object? customerPhone = freezed,Object? productName = null,Object? modelName = freezed,Object? quantity = freezed,Object? toWarehouseName = freezed,}) {
  return _then(_ScanOutTargetModel(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,carrier: freezed == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,toWarehouseName: freezed == toWarehouseName ? _self.toWarehouseName : toWarehouseName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ScanOutCartonModel {

 String get productName; String get modelName; String? get serialNumber; bool? get isIndividualUnit; int? get capacityPerBox; String? get unit; String? get packageType; ScanOutTransferModel? get transfer;/// سفارشی که این بار برای آن خروج خورده — مبنای انتخاب راننده
 ScanOutOrderModel? get order;/// راننده‌ای که بار برایش تعریف شد (خروج دستی با انتخاب راننده)
 ScanOutDriverModel? get driver;
/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanOutCartonModelCopyWith<ScanOutCartonModel> get copyWith => _$ScanOutCartonModelCopyWithImpl<ScanOutCartonModel>(this as ScanOutCartonModel, _$identity);

  /// Serializes this ScanOutCartonModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanOutCartonModel&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.isIndividualUnit, isIndividualUnit) || other.isIndividualUnit == isIndividualUnit)&&(identical(other.capacityPerBox, capacityPerBox) || other.capacityPerBox == capacityPerBox)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.packageType, packageType) || other.packageType == packageType)&&(identical(other.transfer, transfer) || other.transfer == transfer)&&(identical(other.order, order) || other.order == order)&&(identical(other.driver, driver) || other.driver == driver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productName,modelName,serialNumber,isIndividualUnit,capacityPerBox,unit,packageType,transfer,order,driver);

@override
String toString() {
  return 'ScanOutCartonModel(productName: $productName, modelName: $modelName, serialNumber: $serialNumber, isIndividualUnit: $isIndividualUnit, capacityPerBox: $capacityPerBox, unit: $unit, packageType: $packageType, transfer: $transfer, order: $order, driver: $driver)';
}


}

/// @nodoc
abstract mixin class $ScanOutCartonModelCopyWith<$Res>  {
  factory $ScanOutCartonModelCopyWith(ScanOutCartonModel value, $Res Function(ScanOutCartonModel) _then) = _$ScanOutCartonModelCopyWithImpl;
@useResult
$Res call({
 String productName, String modelName, String? serialNumber, bool? isIndividualUnit, int? capacityPerBox, String? unit, String? packageType, ScanOutTransferModel? transfer, ScanOutOrderModel? order, ScanOutDriverModel? driver
});


$ScanOutTransferModelCopyWith<$Res>? get transfer;$ScanOutOrderModelCopyWith<$Res>? get order;$ScanOutDriverModelCopyWith<$Res>? get driver;

}
/// @nodoc
class _$ScanOutCartonModelCopyWithImpl<$Res>
    implements $ScanOutCartonModelCopyWith<$Res> {
  _$ScanOutCartonModelCopyWithImpl(this._self, this._then);

  final ScanOutCartonModel _self;
  final $Res Function(ScanOutCartonModel) _then;

/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productName = null,Object? modelName = null,Object? serialNumber = freezed,Object? isIndividualUnit = freezed,Object? capacityPerBox = freezed,Object? unit = freezed,Object? packageType = freezed,Object? transfer = freezed,Object? order = freezed,Object? driver = freezed,}) {
  return _then(_self.copyWith(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,isIndividualUnit: freezed == isIndividualUnit ? _self.isIndividualUnit : isIndividualUnit // ignore: cast_nullable_to_non_nullable
as bool?,capacityPerBox: freezed == capacityPerBox ? _self.capacityPerBox : capacityPerBox // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,transfer: freezed == transfer ? _self.transfer : transfer // ignore: cast_nullable_to_non_nullable
as ScanOutTransferModel?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as ScanOutOrderModel?,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as ScanOutDriverModel?,
  ));
}
/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanOutTransferModelCopyWith<$Res>? get transfer {
    if (_self.transfer == null) {
    return null;
  }

  return $ScanOutTransferModelCopyWith<$Res>(_self.transfer!, (value) {
    return _then(_self.copyWith(transfer: value));
  });
}/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanOutOrderModelCopyWith<$Res>? get order {
    if (_self.order == null) {
    return null;
  }

  return $ScanOutOrderModelCopyWith<$Res>(_self.order!, (value) {
    return _then(_self.copyWith(order: value));
  });
}/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanOutDriverModelCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $ScanOutDriverModelCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScanOutCartonModel].
extension ScanOutCartonModelPatterns on ScanOutCartonModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanOutCartonModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanOutCartonModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanOutCartonModel value)  $default,){
final _that = this;
switch (_that) {
case _ScanOutCartonModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanOutCartonModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScanOutCartonModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productName,  String modelName,  String? serialNumber,  bool? isIndividualUnit,  int? capacityPerBox,  String? unit,  String? packageType,  ScanOutTransferModel? transfer,  ScanOutOrderModel? order,  ScanOutDriverModel? driver)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanOutCartonModel() when $default != null:
return $default(_that.productName,_that.modelName,_that.serialNumber,_that.isIndividualUnit,_that.capacityPerBox,_that.unit,_that.packageType,_that.transfer,_that.order,_that.driver);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productName,  String modelName,  String? serialNumber,  bool? isIndividualUnit,  int? capacityPerBox,  String? unit,  String? packageType,  ScanOutTransferModel? transfer,  ScanOutOrderModel? order,  ScanOutDriverModel? driver)  $default,) {final _that = this;
switch (_that) {
case _ScanOutCartonModel():
return $default(_that.productName,_that.modelName,_that.serialNumber,_that.isIndividualUnit,_that.capacityPerBox,_that.unit,_that.packageType,_that.transfer,_that.order,_that.driver);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productName,  String modelName,  String? serialNumber,  bool? isIndividualUnit,  int? capacityPerBox,  String? unit,  String? packageType,  ScanOutTransferModel? transfer,  ScanOutOrderModel? order,  ScanOutDriverModel? driver)?  $default,) {final _that = this;
switch (_that) {
case _ScanOutCartonModel() when $default != null:
return $default(_that.productName,_that.modelName,_that.serialNumber,_that.isIndividualUnit,_that.capacityPerBox,_that.unit,_that.packageType,_that.transfer,_that.order,_that.driver);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanOutCartonModel implements ScanOutCartonModel {
  const _ScanOutCartonModel({this.productName = '', this.modelName = '', this.serialNumber, this.isIndividualUnit, this.capacityPerBox, this.unit, this.packageType, this.transfer, this.order, this.driver});
  factory _ScanOutCartonModel.fromJson(Map<String, dynamic> json) => _$ScanOutCartonModelFromJson(json);

@override@JsonKey() final  String productName;
@override@JsonKey() final  String modelName;
@override final  String? serialNumber;
@override final  bool? isIndividualUnit;
@override final  int? capacityPerBox;
@override final  String? unit;
@override final  String? packageType;
@override final  ScanOutTransferModel? transfer;
/// سفارشی که این بار برای آن خروج خورده — مبنای انتخاب راننده
@override final  ScanOutOrderModel? order;
/// راننده‌ای که بار برایش تعریف شد (خروج دستی با انتخاب راننده)
@override final  ScanOutDriverModel? driver;

/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanOutCartonModelCopyWith<_ScanOutCartonModel> get copyWith => __$ScanOutCartonModelCopyWithImpl<_ScanOutCartonModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanOutCartonModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanOutCartonModel&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.isIndividualUnit, isIndividualUnit) || other.isIndividualUnit == isIndividualUnit)&&(identical(other.capacityPerBox, capacityPerBox) || other.capacityPerBox == capacityPerBox)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.packageType, packageType) || other.packageType == packageType)&&(identical(other.transfer, transfer) || other.transfer == transfer)&&(identical(other.order, order) || other.order == order)&&(identical(other.driver, driver) || other.driver == driver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productName,modelName,serialNumber,isIndividualUnit,capacityPerBox,unit,packageType,transfer,order,driver);

@override
String toString() {
  return 'ScanOutCartonModel(productName: $productName, modelName: $modelName, serialNumber: $serialNumber, isIndividualUnit: $isIndividualUnit, capacityPerBox: $capacityPerBox, unit: $unit, packageType: $packageType, transfer: $transfer, order: $order, driver: $driver)';
}


}

/// @nodoc
abstract mixin class _$ScanOutCartonModelCopyWith<$Res> implements $ScanOutCartonModelCopyWith<$Res> {
  factory _$ScanOutCartonModelCopyWith(_ScanOutCartonModel value, $Res Function(_ScanOutCartonModel) _then) = __$ScanOutCartonModelCopyWithImpl;
@override @useResult
$Res call({
 String productName, String modelName, String? serialNumber, bool? isIndividualUnit, int? capacityPerBox, String? unit, String? packageType, ScanOutTransferModel? transfer, ScanOutOrderModel? order, ScanOutDriverModel? driver
});


@override $ScanOutTransferModelCopyWith<$Res>? get transfer;@override $ScanOutOrderModelCopyWith<$Res>? get order;@override $ScanOutDriverModelCopyWith<$Res>? get driver;

}
/// @nodoc
class __$ScanOutCartonModelCopyWithImpl<$Res>
    implements _$ScanOutCartonModelCopyWith<$Res> {
  __$ScanOutCartonModelCopyWithImpl(this._self, this._then);

  final _ScanOutCartonModel _self;
  final $Res Function(_ScanOutCartonModel) _then;

/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productName = null,Object? modelName = null,Object? serialNumber = freezed,Object? isIndividualUnit = freezed,Object? capacityPerBox = freezed,Object? unit = freezed,Object? packageType = freezed,Object? transfer = freezed,Object? order = freezed,Object? driver = freezed,}) {
  return _then(_ScanOutCartonModel(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,isIndividualUnit: freezed == isIndividualUnit ? _self.isIndividualUnit : isIndividualUnit // ignore: cast_nullable_to_non_nullable
as bool?,capacityPerBox: freezed == capacityPerBox ? _self.capacityPerBox : capacityPerBox // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,packageType: freezed == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as String?,transfer: freezed == transfer ? _self.transfer : transfer // ignore: cast_nullable_to_non_nullable
as ScanOutTransferModel?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as ScanOutOrderModel?,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as ScanOutDriverModel?,
  ));
}

/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanOutTransferModelCopyWith<$Res>? get transfer {
    if (_self.transfer == null) {
    return null;
  }

  return $ScanOutTransferModelCopyWith<$Res>(_self.transfer!, (value) {
    return _then(_self.copyWith(transfer: value));
  });
}/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanOutOrderModelCopyWith<$Res>? get order {
    if (_self.order == null) {
    return null;
  }

  return $ScanOutOrderModelCopyWith<$Res>(_self.order!, (value) {
    return _then(_self.copyWith(order: value));
  });
}/// Create a copy of ScanOutCartonModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanOutDriverModelCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $ScanOutDriverModelCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}
}


/// @nodoc
mixin _$ScanOutOrderModel {

 String get id; int? get orderNumber; String? get customerPhone; String? get city; String? get address;
/// Create a copy of ScanOutOrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanOutOrderModelCopyWith<ScanOutOrderModel> get copyWith => _$ScanOutOrderModelCopyWithImpl<ScanOutOrderModel>(this as ScanOutOrderModel, _$identity);

  /// Serializes this ScanOutOrderModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanOutOrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.city, city) || other.city == city)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,customerPhone,city,address);

@override
String toString() {
  return 'ScanOutOrderModel(id: $id, orderNumber: $orderNumber, customerPhone: $customerPhone, city: $city, address: $address)';
}


}

/// @nodoc
abstract mixin class $ScanOutOrderModelCopyWith<$Res>  {
  factory $ScanOutOrderModelCopyWith(ScanOutOrderModel value, $Res Function(ScanOutOrderModel) _then) = _$ScanOutOrderModelCopyWithImpl;
@useResult
$Res call({
 String id, int? orderNumber, String? customerPhone, String? city, String? address
});




}
/// @nodoc
class _$ScanOutOrderModelCopyWithImpl<$Res>
    implements $ScanOutOrderModelCopyWith<$Res> {
  _$ScanOutOrderModelCopyWithImpl(this._self, this._then);

  final ScanOutOrderModel _self;
  final $Res Function(ScanOutOrderModel) _then;

/// Create a copy of ScanOutOrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = freezed,Object? customerPhone = freezed,Object? city = freezed,Object? address = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScanOutOrderModel].
extension ScanOutOrderModelPatterns on ScanOutOrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanOutOrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanOutOrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanOutOrderModel value)  $default,){
final _that = this;
switch (_that) {
case _ScanOutOrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanOutOrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScanOutOrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int? orderNumber,  String? customerPhone,  String? city,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanOutOrderModel() when $default != null:
return $default(_that.id,_that.orderNumber,_that.customerPhone,_that.city,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int? orderNumber,  String? customerPhone,  String? city,  String? address)  $default,) {final _that = this;
switch (_that) {
case _ScanOutOrderModel():
return $default(_that.id,_that.orderNumber,_that.customerPhone,_that.city,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int? orderNumber,  String? customerPhone,  String? city,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _ScanOutOrderModel() when $default != null:
return $default(_that.id,_that.orderNumber,_that.customerPhone,_that.city,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanOutOrderModel implements ScanOutOrderModel {
  const _ScanOutOrderModel({this.id = '', this.orderNumber, this.customerPhone, this.city, this.address});
  factory _ScanOutOrderModel.fromJson(Map<String, dynamic> json) => _$ScanOutOrderModelFromJson(json);

@override@JsonKey() final  String id;
@override final  int? orderNumber;
@override final  String? customerPhone;
@override final  String? city;
@override final  String? address;

/// Create a copy of ScanOutOrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanOutOrderModelCopyWith<_ScanOutOrderModel> get copyWith => __$ScanOutOrderModelCopyWithImpl<_ScanOutOrderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanOutOrderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanOutOrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.city, city) || other.city == city)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,customerPhone,city,address);

@override
String toString() {
  return 'ScanOutOrderModel(id: $id, orderNumber: $orderNumber, customerPhone: $customerPhone, city: $city, address: $address)';
}


}

/// @nodoc
abstract mixin class _$ScanOutOrderModelCopyWith<$Res> implements $ScanOutOrderModelCopyWith<$Res> {
  factory _$ScanOutOrderModelCopyWith(_ScanOutOrderModel value, $Res Function(_ScanOutOrderModel) _then) = __$ScanOutOrderModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int? orderNumber, String? customerPhone, String? city, String? address
});




}
/// @nodoc
class __$ScanOutOrderModelCopyWithImpl<$Res>
    implements _$ScanOutOrderModelCopyWith<$Res> {
  __$ScanOutOrderModelCopyWithImpl(this._self, this._then);

  final _ScanOutOrderModel _self;
  final $Res Function(_ScanOutOrderModel) _then;

/// Create a copy of ScanOutOrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = freezed,Object? customerPhone = freezed,Object? city = freezed,Object? address = freezed,}) {
  return _then(_ScanOutOrderModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ScanOutDriverModel {

 String get id; String get name;
/// Create a copy of ScanOutDriverModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanOutDriverModelCopyWith<ScanOutDriverModel> get copyWith => _$ScanOutDriverModelCopyWithImpl<ScanOutDriverModel>(this as ScanOutDriverModel, _$identity);

  /// Serializes this ScanOutDriverModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanOutDriverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ScanOutDriverModel(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $ScanOutDriverModelCopyWith<$Res>  {
  factory $ScanOutDriverModelCopyWith(ScanOutDriverModel value, $Res Function(ScanOutDriverModel) _then) = _$ScanOutDriverModelCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$ScanOutDriverModelCopyWithImpl<$Res>
    implements $ScanOutDriverModelCopyWith<$Res> {
  _$ScanOutDriverModelCopyWithImpl(this._self, this._then);

  final ScanOutDriverModel _self;
  final $Res Function(ScanOutDriverModel) _then;

/// Create a copy of ScanOutDriverModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScanOutDriverModel].
extension ScanOutDriverModelPatterns on ScanOutDriverModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanOutDriverModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanOutDriverModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanOutDriverModel value)  $default,){
final _that = this;
switch (_that) {
case _ScanOutDriverModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanOutDriverModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScanOutDriverModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanOutDriverModel() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _ScanOutDriverModel():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ScanOutDriverModel() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanOutDriverModel implements ScanOutDriverModel {
  const _ScanOutDriverModel({this.id = '', this.name = ''});
  factory _ScanOutDriverModel.fromJson(Map<String, dynamic> json) => _$ScanOutDriverModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;

/// Create a copy of ScanOutDriverModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanOutDriverModelCopyWith<_ScanOutDriverModel> get copyWith => __$ScanOutDriverModelCopyWithImpl<_ScanOutDriverModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanOutDriverModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanOutDriverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ScanOutDriverModel(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ScanOutDriverModelCopyWith<$Res> implements $ScanOutDriverModelCopyWith<$Res> {
  factory _$ScanOutDriverModelCopyWith(_ScanOutDriverModel value, $Res Function(_ScanOutDriverModel) _then) = __$ScanOutDriverModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$ScanOutDriverModelCopyWithImpl<$Res>
    implements _$ScanOutDriverModelCopyWith<$Res> {
  __$ScanOutDriverModelCopyWithImpl(this._self, this._then);

  final _ScanOutDriverModel _self;
  final $Res Function(_ScanOutDriverModel) _then;

/// Create a copy of ScanOutDriverModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_ScanOutDriverModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ScanOutTransferModel {

 String get id; String? get toWarehouseId; String? get toWarehouseName;
/// Create a copy of ScanOutTransferModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanOutTransferModelCopyWith<ScanOutTransferModel> get copyWith => _$ScanOutTransferModelCopyWithImpl<ScanOutTransferModel>(this as ScanOutTransferModel, _$identity);

  /// Serializes this ScanOutTransferModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanOutTransferModel&&(identical(other.id, id) || other.id == id)&&(identical(other.toWarehouseId, toWarehouseId) || other.toWarehouseId == toWarehouseId)&&(identical(other.toWarehouseName, toWarehouseName) || other.toWarehouseName == toWarehouseName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,toWarehouseId,toWarehouseName);

@override
String toString() {
  return 'ScanOutTransferModel(id: $id, toWarehouseId: $toWarehouseId, toWarehouseName: $toWarehouseName)';
}


}

/// @nodoc
abstract mixin class $ScanOutTransferModelCopyWith<$Res>  {
  factory $ScanOutTransferModelCopyWith(ScanOutTransferModel value, $Res Function(ScanOutTransferModel) _then) = _$ScanOutTransferModelCopyWithImpl;
@useResult
$Res call({
 String id, String? toWarehouseId, String? toWarehouseName
});




}
/// @nodoc
class _$ScanOutTransferModelCopyWithImpl<$Res>
    implements $ScanOutTransferModelCopyWith<$Res> {
  _$ScanOutTransferModelCopyWithImpl(this._self, this._then);

  final ScanOutTransferModel _self;
  final $Res Function(ScanOutTransferModel) _then;

/// Create a copy of ScanOutTransferModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? toWarehouseId = freezed,Object? toWarehouseName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,toWarehouseId: freezed == toWarehouseId ? _self.toWarehouseId : toWarehouseId // ignore: cast_nullable_to_non_nullable
as String?,toWarehouseName: freezed == toWarehouseName ? _self.toWarehouseName : toWarehouseName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScanOutTransferModel].
extension ScanOutTransferModelPatterns on ScanOutTransferModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanOutTransferModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanOutTransferModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanOutTransferModel value)  $default,){
final _that = this;
switch (_that) {
case _ScanOutTransferModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanOutTransferModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScanOutTransferModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? toWarehouseId,  String? toWarehouseName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanOutTransferModel() when $default != null:
return $default(_that.id,_that.toWarehouseId,_that.toWarehouseName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? toWarehouseId,  String? toWarehouseName)  $default,) {final _that = this;
switch (_that) {
case _ScanOutTransferModel():
return $default(_that.id,_that.toWarehouseId,_that.toWarehouseName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? toWarehouseId,  String? toWarehouseName)?  $default,) {final _that = this;
switch (_that) {
case _ScanOutTransferModel() when $default != null:
return $default(_that.id,_that.toWarehouseId,_that.toWarehouseName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanOutTransferModel implements ScanOutTransferModel {
  const _ScanOutTransferModel({required this.id, this.toWarehouseId, this.toWarehouseName});
  factory _ScanOutTransferModel.fromJson(Map<String, dynamic> json) => _$ScanOutTransferModelFromJson(json);

@override final  String id;
@override final  String? toWarehouseId;
@override final  String? toWarehouseName;

/// Create a copy of ScanOutTransferModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanOutTransferModelCopyWith<_ScanOutTransferModel> get copyWith => __$ScanOutTransferModelCopyWithImpl<_ScanOutTransferModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanOutTransferModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanOutTransferModel&&(identical(other.id, id) || other.id == id)&&(identical(other.toWarehouseId, toWarehouseId) || other.toWarehouseId == toWarehouseId)&&(identical(other.toWarehouseName, toWarehouseName) || other.toWarehouseName == toWarehouseName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,toWarehouseId,toWarehouseName);

@override
String toString() {
  return 'ScanOutTransferModel(id: $id, toWarehouseId: $toWarehouseId, toWarehouseName: $toWarehouseName)';
}


}

/// @nodoc
abstract mixin class _$ScanOutTransferModelCopyWith<$Res> implements $ScanOutTransferModelCopyWith<$Res> {
  factory _$ScanOutTransferModelCopyWith(_ScanOutTransferModel value, $Res Function(_ScanOutTransferModel) _then) = __$ScanOutTransferModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? toWarehouseId, String? toWarehouseName
});




}
/// @nodoc
class __$ScanOutTransferModelCopyWithImpl<$Res>
    implements _$ScanOutTransferModelCopyWith<$Res> {
  __$ScanOutTransferModelCopyWithImpl(this._self, this._then);

  final _ScanOutTransferModel _self;
  final $Res Function(_ScanOutTransferModel) _then;

/// Create a copy of ScanOutTransferModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? toWarehouseId = freezed,Object? toWarehouseName = freezed,}) {
  return _then(_ScanOutTransferModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,toWarehouseId: freezed == toWarehouseId ? _self.toWarehouseId : toWarehouseId // ignore: cast_nullable_to_non_nullable
as String?,toWarehouseName: freezed == toWarehouseName ? _self.toWarehouseName : toWarehouseName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
