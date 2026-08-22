// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_activity_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecentActivityData {

 List<ActivityEntryModel> get activities;
/// Create a copy of RecentActivityData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentActivityDataCopyWith<RecentActivityData> get copyWith => _$RecentActivityDataCopyWithImpl<RecentActivityData>(this as RecentActivityData, _$identity);

  /// Serializes this RecentActivityData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentActivityData&&const DeepCollectionEquality().equals(other.activities, activities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(activities));

@override
String toString() {
  return 'RecentActivityData(activities: $activities)';
}


}

/// @nodoc
abstract mixin class $RecentActivityDataCopyWith<$Res>  {
  factory $RecentActivityDataCopyWith(RecentActivityData value, $Res Function(RecentActivityData) _then) = _$RecentActivityDataCopyWithImpl;
@useResult
$Res call({
 List<ActivityEntryModel> activities
});




}
/// @nodoc
class _$RecentActivityDataCopyWithImpl<$Res>
    implements $RecentActivityDataCopyWith<$Res> {
  _$RecentActivityDataCopyWithImpl(this._self, this._then);

  final RecentActivityData _self;
  final $Res Function(RecentActivityData) _then;

/// Create a copy of RecentActivityData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activities = null,}) {
  return _then(_self.copyWith(
activities: null == activities ? _self.activities : activities // ignore: cast_nullable_to_non_nullable
as List<ActivityEntryModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentActivityData].
extension RecentActivityDataPatterns on RecentActivityData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentActivityData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentActivityData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentActivityData value)  $default,){
final _that = this;
switch (_that) {
case _RecentActivityData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentActivityData value)?  $default,){
final _that = this;
switch (_that) {
case _RecentActivityData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ActivityEntryModel> activities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentActivityData() when $default != null:
return $default(_that.activities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ActivityEntryModel> activities)  $default,) {final _that = this;
switch (_that) {
case _RecentActivityData():
return $default(_that.activities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ActivityEntryModel> activities)?  $default,) {final _that = this;
switch (_that) {
case _RecentActivityData() when $default != null:
return $default(_that.activities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentActivityData implements RecentActivityData {
  const _RecentActivityData({final  List<ActivityEntryModel> activities = const <ActivityEntryModel>[]}): _activities = activities;
  factory _RecentActivityData.fromJson(Map<String, dynamic> json) => _$RecentActivityDataFromJson(json);

 final  List<ActivityEntryModel> _activities;
@override@JsonKey() List<ActivityEntryModel> get activities {
  if (_activities is EqualUnmodifiableListView) return _activities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activities);
}


/// Create a copy of RecentActivityData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentActivityDataCopyWith<_RecentActivityData> get copyWith => __$RecentActivityDataCopyWithImpl<_RecentActivityData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentActivityDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentActivityData&&const DeepCollectionEquality().equals(other._activities, _activities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_activities));

@override
String toString() {
  return 'RecentActivityData(activities: $activities)';
}


}

/// @nodoc
abstract mixin class _$RecentActivityDataCopyWith<$Res> implements $RecentActivityDataCopyWith<$Res> {
  factory _$RecentActivityDataCopyWith(_RecentActivityData value, $Res Function(_RecentActivityData) _then) = __$RecentActivityDataCopyWithImpl;
@override @useResult
$Res call({
 List<ActivityEntryModel> activities
});




}
/// @nodoc
class __$RecentActivityDataCopyWithImpl<$Res>
    implements _$RecentActivityDataCopyWith<$Res> {
  __$RecentActivityDataCopyWithImpl(this._self, this._then);

  final _RecentActivityData _self;
  final $Res Function(_RecentActivityData) _then;

/// Create a copy of RecentActivityData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activities = null,}) {
  return _then(_RecentActivityData(
activities: null == activities ? _self._activities : activities // ignore: cast_nullable_to_non_nullable
as List<ActivityEntryModel>,
  ));
}


}


/// @nodoc
mixin _$ActivityEntryModel {

 String? get id; String? get activityType; String? get type; String? get title; String? get label; String? get unit; num get quantity; String? get warehouseName; String? get userName; String? get createdAt; String? get orderId;
/// Create a copy of ActivityEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityEntryModelCopyWith<ActivityEntryModel> get copyWith => _$ActivityEntryModelCopyWithImpl<ActivityEntryModel>(this as ActivityEntryModel, _$identity);

  /// Serializes this ActivityEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityEntryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.label, label) || other.label == label)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.orderId, orderId) || other.orderId == orderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,activityType,type,title,label,unit,quantity,warehouseName,userName,createdAt,orderId);

@override
String toString() {
  return 'ActivityEntryModel(id: $id, activityType: $activityType, type: $type, title: $title, label: $label, unit: $unit, quantity: $quantity, warehouseName: $warehouseName, userName: $userName, createdAt: $createdAt, orderId: $orderId)';
}


}

/// @nodoc
abstract mixin class $ActivityEntryModelCopyWith<$Res>  {
  factory $ActivityEntryModelCopyWith(ActivityEntryModel value, $Res Function(ActivityEntryModel) _then) = _$ActivityEntryModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? activityType, String? type, String? title, String? label, String? unit, num quantity, String? warehouseName, String? userName, String? createdAt, String? orderId
});




}
/// @nodoc
class _$ActivityEntryModelCopyWithImpl<$Res>
    implements $ActivityEntryModelCopyWith<$Res> {
  _$ActivityEntryModelCopyWithImpl(this._self, this._then);

  final ActivityEntryModel _self;
  final $Res Function(ActivityEntryModel) _then;

/// Create a copy of ActivityEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? activityType = freezed,Object? type = freezed,Object? title = freezed,Object? label = freezed,Object? unit = freezed,Object? quantity = null,Object? warehouseName = freezed,Object? userName = freezed,Object? createdAt = freezed,Object? orderId = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,activityType: freezed == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityEntryModel].
extension ActivityEntryModelPatterns on ActivityEntryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityEntryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _ActivityEntryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityEntryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? activityType,  String? type,  String? title,  String? label,  String? unit,  num quantity,  String? warehouseName,  String? userName,  String? createdAt,  String? orderId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityEntryModel() when $default != null:
return $default(_that.id,_that.activityType,_that.type,_that.title,_that.label,_that.unit,_that.quantity,_that.warehouseName,_that.userName,_that.createdAt,_that.orderId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? activityType,  String? type,  String? title,  String? label,  String? unit,  num quantity,  String? warehouseName,  String? userName,  String? createdAt,  String? orderId)  $default,) {final _that = this;
switch (_that) {
case _ActivityEntryModel():
return $default(_that.id,_that.activityType,_that.type,_that.title,_that.label,_that.unit,_that.quantity,_that.warehouseName,_that.userName,_that.createdAt,_that.orderId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? activityType,  String? type,  String? title,  String? label,  String? unit,  num quantity,  String? warehouseName,  String? userName,  String? createdAt,  String? orderId)?  $default,) {final _that = this;
switch (_that) {
case _ActivityEntryModel() when $default != null:
return $default(_that.id,_that.activityType,_that.type,_that.title,_that.label,_that.unit,_that.quantity,_that.warehouseName,_that.userName,_that.createdAt,_that.orderId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityEntryModel implements ActivityEntryModel {
  const _ActivityEntryModel({this.id, this.activityType, this.type, this.title, this.label, this.unit, this.quantity = 0, this.warehouseName, this.userName, this.createdAt, this.orderId});
  factory _ActivityEntryModel.fromJson(Map<String, dynamic> json) => _$ActivityEntryModelFromJson(json);

@override final  String? id;
@override final  String? activityType;
@override final  String? type;
@override final  String? title;
@override final  String? label;
@override final  String? unit;
@override@JsonKey() final  num quantity;
@override final  String? warehouseName;
@override final  String? userName;
@override final  String? createdAt;
@override final  String? orderId;

/// Create a copy of ActivityEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityEntryModelCopyWith<_ActivityEntryModel> get copyWith => __$ActivityEntryModelCopyWithImpl<_ActivityEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityEntryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.label, label) || other.label == label)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.orderId, orderId) || other.orderId == orderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,activityType,type,title,label,unit,quantity,warehouseName,userName,createdAt,orderId);

@override
String toString() {
  return 'ActivityEntryModel(id: $id, activityType: $activityType, type: $type, title: $title, label: $label, unit: $unit, quantity: $quantity, warehouseName: $warehouseName, userName: $userName, createdAt: $createdAt, orderId: $orderId)';
}


}

/// @nodoc
abstract mixin class _$ActivityEntryModelCopyWith<$Res> implements $ActivityEntryModelCopyWith<$Res> {
  factory _$ActivityEntryModelCopyWith(_ActivityEntryModel value, $Res Function(_ActivityEntryModel) _then) = __$ActivityEntryModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? activityType, String? type, String? title, String? label, String? unit, num quantity, String? warehouseName, String? userName, String? createdAt, String? orderId
});




}
/// @nodoc
class __$ActivityEntryModelCopyWithImpl<$Res>
    implements _$ActivityEntryModelCopyWith<$Res> {
  __$ActivityEntryModelCopyWithImpl(this._self, this._then);

  final _ActivityEntryModel _self;
  final $Res Function(_ActivityEntryModel) _then;

/// Create a copy of ActivityEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? activityType = freezed,Object? type = freezed,Object? title = freezed,Object? label = freezed,Object? unit = freezed,Object? quantity = null,Object? warehouseName = freezed,Object? userName = freezed,Object? createdAt = freezed,Object? orderId = freezed,}) {
  return _then(_ActivityEntryModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,activityType: freezed == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
