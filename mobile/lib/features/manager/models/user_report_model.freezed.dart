// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserReportModel {

 UserReportUserModel get user; UserReportStatsModel get stats; HistoryEntryModel? get lastActivity; List<HistoryEntryModel> get recentActivities;
/// Create a copy of UserReportModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserReportModelCopyWith<UserReportModel> get copyWith => _$UserReportModelCopyWithImpl<UserReportModel>(this as UserReportModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserReportModel&&(identical(other.user, user) || other.user == user)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.lastActivity, lastActivity) || other.lastActivity == lastActivity)&&const DeepCollectionEquality().equals(other.recentActivities, recentActivities));
}


@override
int get hashCode => Object.hash(runtimeType,user,stats,lastActivity,const DeepCollectionEquality().hash(recentActivities));

@override
String toString() {
  return 'UserReportModel(user: $user, stats: $stats, lastActivity: $lastActivity, recentActivities: $recentActivities)';
}


}

/// @nodoc
abstract mixin class $UserReportModelCopyWith<$Res>  {
  factory $UserReportModelCopyWith(UserReportModel value, $Res Function(UserReportModel) _then) = _$UserReportModelCopyWithImpl;
@useResult
$Res call({
 UserReportUserModel user, UserReportStatsModel stats, HistoryEntryModel? lastActivity, List<HistoryEntryModel> recentActivities
});


$UserReportUserModelCopyWith<$Res> get user;$UserReportStatsModelCopyWith<$Res> get stats;$HistoryEntryModelCopyWith<$Res>? get lastActivity;

}
/// @nodoc
class _$UserReportModelCopyWithImpl<$Res>
    implements $UserReportModelCopyWith<$Res> {
  _$UserReportModelCopyWithImpl(this._self, this._then);

  final UserReportModel _self;
  final $Res Function(UserReportModel) _then;

/// Create a copy of UserReportModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? stats = null,Object? lastActivity = freezed,Object? recentActivities = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserReportUserModel,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as UserReportStatsModel,lastActivity: freezed == lastActivity ? _self.lastActivity : lastActivity // ignore: cast_nullable_to_non_nullable
as HistoryEntryModel?,recentActivities: null == recentActivities ? _self.recentActivities : recentActivities // ignore: cast_nullable_to_non_nullable
as List<HistoryEntryModel>,
  ));
}
/// Create a copy of UserReportModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserReportUserModelCopyWith<$Res> get user {
  
  return $UserReportUserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of UserReportModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserReportStatsModelCopyWith<$Res> get stats {
  
  return $UserReportStatsModelCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of UserReportModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HistoryEntryModelCopyWith<$Res>? get lastActivity {
    if (_self.lastActivity == null) {
    return null;
  }

  return $HistoryEntryModelCopyWith<$Res>(_self.lastActivity!, (value) {
    return _then(_self.copyWith(lastActivity: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserReportModel].
extension UserReportModelPatterns on UserReportModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserReportModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserReportModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserReportModel value)  $default,){
final _that = this;
switch (_that) {
case _UserReportModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserReportModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserReportModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserReportUserModel user,  UserReportStatsModel stats,  HistoryEntryModel? lastActivity,  List<HistoryEntryModel> recentActivities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserReportModel() when $default != null:
return $default(_that.user,_that.stats,_that.lastActivity,_that.recentActivities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserReportUserModel user,  UserReportStatsModel stats,  HistoryEntryModel? lastActivity,  List<HistoryEntryModel> recentActivities)  $default,) {final _that = this;
switch (_that) {
case _UserReportModel():
return $default(_that.user,_that.stats,_that.lastActivity,_that.recentActivities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserReportUserModel user,  UserReportStatsModel stats,  HistoryEntryModel? lastActivity,  List<HistoryEntryModel> recentActivities)?  $default,) {final _that = this;
switch (_that) {
case _UserReportModel() when $default != null:
return $default(_that.user,_that.stats,_that.lastActivity,_that.recentActivities);case _:
  return null;

}
}

}

/// @nodoc


class _UserReportModel implements UserReportModel {
  const _UserReportModel({required this.user, this.stats = const UserReportStatsModel(), this.lastActivity, final  List<HistoryEntryModel> recentActivities = const <HistoryEntryModel>[]}): _recentActivities = recentActivities;
  

@override final  UserReportUserModel user;
@override@JsonKey() final  UserReportStatsModel stats;
@override final  HistoryEntryModel? lastActivity;
 final  List<HistoryEntryModel> _recentActivities;
@override@JsonKey() List<HistoryEntryModel> get recentActivities {
  if (_recentActivities is EqualUnmodifiableListView) return _recentActivities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentActivities);
}


/// Create a copy of UserReportModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserReportModelCopyWith<_UserReportModel> get copyWith => __$UserReportModelCopyWithImpl<_UserReportModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserReportModel&&(identical(other.user, user) || other.user == user)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.lastActivity, lastActivity) || other.lastActivity == lastActivity)&&const DeepCollectionEquality().equals(other._recentActivities, _recentActivities));
}


@override
int get hashCode => Object.hash(runtimeType,user,stats,lastActivity,const DeepCollectionEquality().hash(_recentActivities));

@override
String toString() {
  return 'UserReportModel(user: $user, stats: $stats, lastActivity: $lastActivity, recentActivities: $recentActivities)';
}


}

/// @nodoc
abstract mixin class _$UserReportModelCopyWith<$Res> implements $UserReportModelCopyWith<$Res> {
  factory _$UserReportModelCopyWith(_UserReportModel value, $Res Function(_UserReportModel) _then) = __$UserReportModelCopyWithImpl;
@override @useResult
$Res call({
 UserReportUserModel user, UserReportStatsModel stats, HistoryEntryModel? lastActivity, List<HistoryEntryModel> recentActivities
});


@override $UserReportUserModelCopyWith<$Res> get user;@override $UserReportStatsModelCopyWith<$Res> get stats;@override $HistoryEntryModelCopyWith<$Res>? get lastActivity;

}
/// @nodoc
class __$UserReportModelCopyWithImpl<$Res>
    implements _$UserReportModelCopyWith<$Res> {
  __$UserReportModelCopyWithImpl(this._self, this._then);

  final _UserReportModel _self;
  final $Res Function(_UserReportModel) _then;

/// Create a copy of UserReportModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? stats = null,Object? lastActivity = freezed,Object? recentActivities = null,}) {
  return _then(_UserReportModel(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserReportUserModel,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as UserReportStatsModel,lastActivity: freezed == lastActivity ? _self.lastActivity : lastActivity // ignore: cast_nullable_to_non_nullable
as HistoryEntryModel?,recentActivities: null == recentActivities ? _self._recentActivities : recentActivities // ignore: cast_nullable_to_non_nullable
as List<HistoryEntryModel>,
  ));
}

/// Create a copy of UserReportModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserReportUserModelCopyWith<$Res> get user {
  
  return $UserReportUserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of UserReportModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserReportStatsModelCopyWith<$Res> get stats {
  
  return $UserReportStatsModelCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of UserReportModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HistoryEntryModelCopyWith<$Res>? get lastActivity {
    if (_self.lastActivity == null) {
    return null;
  }

  return $HistoryEntryModelCopyWith<$Res>(_self.lastActivity!, (value) {
    return _then(_self.copyWith(lastActivity: value));
  });
}
}

/// @nodoc
mixin _$UserReportUserModel {

 String get id; String? get name; String? get phone; String? get role; String? get createdAt; String? get warehouseName;
/// Create a copy of UserReportUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserReportUserModelCopyWith<UserReportUserModel> get copyWith => _$UserReportUserModelCopyWithImpl<UserReportUserModel>(this as UserReportUserModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserReportUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,phone,role,createdAt,warehouseName);

@override
String toString() {
  return 'UserReportUserModel(id: $id, name: $name, phone: $phone, role: $role, createdAt: $createdAt, warehouseName: $warehouseName)';
}


}

/// @nodoc
abstract mixin class $UserReportUserModelCopyWith<$Res>  {
  factory $UserReportUserModelCopyWith(UserReportUserModel value, $Res Function(UserReportUserModel) _then) = _$UserReportUserModelCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? phone, String? role, String? createdAt, String? warehouseName
});




}
/// @nodoc
class _$UserReportUserModelCopyWithImpl<$Res>
    implements $UserReportUserModelCopyWith<$Res> {
  _$UserReportUserModelCopyWithImpl(this._self, this._then);

  final UserReportUserModel _self;
  final $Res Function(UserReportUserModel) _then;

/// Create a copy of UserReportUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? phone = freezed,Object? role = freezed,Object? createdAt = freezed,Object? warehouseName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserReportUserModel].
extension UserReportUserModelPatterns on UserReportUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserReportUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserReportUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserReportUserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserReportUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserReportUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserReportUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? phone,  String? role,  String? createdAt,  String? warehouseName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserReportUserModel() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.role,_that.createdAt,_that.warehouseName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? phone,  String? role,  String? createdAt,  String? warehouseName)  $default,) {final _that = this;
switch (_that) {
case _UserReportUserModel():
return $default(_that.id,_that.name,_that.phone,_that.role,_that.createdAt,_that.warehouseName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? phone,  String? role,  String? createdAt,  String? warehouseName)?  $default,) {final _that = this;
switch (_that) {
case _UserReportUserModel() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.role,_that.createdAt,_that.warehouseName);case _:
  return null;

}
}

}

/// @nodoc


class _UserReportUserModel implements UserReportUserModel {
  const _UserReportUserModel({required this.id, this.name, this.phone, this.role, this.createdAt, this.warehouseName});
  

@override final  String id;
@override final  String? name;
@override final  String? phone;
@override final  String? role;
@override final  String? createdAt;
@override final  String? warehouseName;

/// Create a copy of UserReportUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserReportUserModelCopyWith<_UserReportUserModel> get copyWith => __$UserReportUserModelCopyWithImpl<_UserReportUserModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserReportUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,phone,role,createdAt,warehouseName);

@override
String toString() {
  return 'UserReportUserModel(id: $id, name: $name, phone: $phone, role: $role, createdAt: $createdAt, warehouseName: $warehouseName)';
}


}

/// @nodoc
abstract mixin class _$UserReportUserModelCopyWith<$Res> implements $UserReportUserModelCopyWith<$Res> {
  factory _$UserReportUserModelCopyWith(_UserReportUserModel value, $Res Function(_UserReportUserModel) _then) = __$UserReportUserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? phone, String? role, String? createdAt, String? warehouseName
});




}
/// @nodoc
class __$UserReportUserModelCopyWithImpl<$Res>
    implements _$UserReportUserModelCopyWith<$Res> {
  __$UserReportUserModelCopyWithImpl(this._self, this._then);

  final _UserReportUserModel _self;
  final $Res Function(_UserReportUserModel) _then;

/// Create a copy of UserReportUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? phone = freezed,Object? role = freezed,Object? createdAt = freezed,Object? warehouseName = freezed,}) {
  return _then(_UserReportUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$UserReportStatsModel {

 num get totalCheckins; num get totalUnits; num get totalReturns; num get totalOrders; num get totalDeliveries;
/// Create a copy of UserReportStatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserReportStatsModelCopyWith<UserReportStatsModel> get copyWith => _$UserReportStatsModelCopyWithImpl<UserReportStatsModel>(this as UserReportStatsModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserReportStatsModel&&(identical(other.totalCheckins, totalCheckins) || other.totalCheckins == totalCheckins)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.totalReturns, totalReturns) || other.totalReturns == totalReturns)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.totalDeliveries, totalDeliveries) || other.totalDeliveries == totalDeliveries));
}


@override
int get hashCode => Object.hash(runtimeType,totalCheckins,totalUnits,totalReturns,totalOrders,totalDeliveries);

@override
String toString() {
  return 'UserReportStatsModel(totalCheckins: $totalCheckins, totalUnits: $totalUnits, totalReturns: $totalReturns, totalOrders: $totalOrders, totalDeliveries: $totalDeliveries)';
}


}

/// @nodoc
abstract mixin class $UserReportStatsModelCopyWith<$Res>  {
  factory $UserReportStatsModelCopyWith(UserReportStatsModel value, $Res Function(UserReportStatsModel) _then) = _$UserReportStatsModelCopyWithImpl;
@useResult
$Res call({
 num totalCheckins, num totalUnits, num totalReturns, num totalOrders, num totalDeliveries
});




}
/// @nodoc
class _$UserReportStatsModelCopyWithImpl<$Res>
    implements $UserReportStatsModelCopyWith<$Res> {
  _$UserReportStatsModelCopyWithImpl(this._self, this._then);

  final UserReportStatsModel _self;
  final $Res Function(UserReportStatsModel) _then;

/// Create a copy of UserReportStatsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCheckins = null,Object? totalUnits = null,Object? totalReturns = null,Object? totalOrders = null,Object? totalDeliveries = null,}) {
  return _then(_self.copyWith(
totalCheckins: null == totalCheckins ? _self.totalCheckins : totalCheckins // ignore: cast_nullable_to_non_nullable
as num,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as num,totalReturns: null == totalReturns ? _self.totalReturns : totalReturns // ignore: cast_nullable_to_non_nullable
as num,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as num,totalDeliveries: null == totalDeliveries ? _self.totalDeliveries : totalDeliveries // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [UserReportStatsModel].
extension UserReportStatsModelPatterns on UserReportStatsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserReportStatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserReportStatsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserReportStatsModel value)  $default,){
final _that = this;
switch (_that) {
case _UserReportStatsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserReportStatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserReportStatsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num totalCheckins,  num totalUnits,  num totalReturns,  num totalOrders,  num totalDeliveries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserReportStatsModel() when $default != null:
return $default(_that.totalCheckins,_that.totalUnits,_that.totalReturns,_that.totalOrders,_that.totalDeliveries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num totalCheckins,  num totalUnits,  num totalReturns,  num totalOrders,  num totalDeliveries)  $default,) {final _that = this;
switch (_that) {
case _UserReportStatsModel():
return $default(_that.totalCheckins,_that.totalUnits,_that.totalReturns,_that.totalOrders,_that.totalDeliveries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num totalCheckins,  num totalUnits,  num totalReturns,  num totalOrders,  num totalDeliveries)?  $default,) {final _that = this;
switch (_that) {
case _UserReportStatsModel() when $default != null:
return $default(_that.totalCheckins,_that.totalUnits,_that.totalReturns,_that.totalOrders,_that.totalDeliveries);case _:
  return null;

}
}

}

/// @nodoc


class _UserReportStatsModel implements UserReportStatsModel {
  const _UserReportStatsModel({this.totalCheckins = 0, this.totalUnits = 0, this.totalReturns = 0, this.totalOrders = 0, this.totalDeliveries = 0});
  

@override@JsonKey() final  num totalCheckins;
@override@JsonKey() final  num totalUnits;
@override@JsonKey() final  num totalReturns;
@override@JsonKey() final  num totalOrders;
@override@JsonKey() final  num totalDeliveries;

/// Create a copy of UserReportStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserReportStatsModelCopyWith<_UserReportStatsModel> get copyWith => __$UserReportStatsModelCopyWithImpl<_UserReportStatsModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserReportStatsModel&&(identical(other.totalCheckins, totalCheckins) || other.totalCheckins == totalCheckins)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.totalReturns, totalReturns) || other.totalReturns == totalReturns)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.totalDeliveries, totalDeliveries) || other.totalDeliveries == totalDeliveries));
}


@override
int get hashCode => Object.hash(runtimeType,totalCheckins,totalUnits,totalReturns,totalOrders,totalDeliveries);

@override
String toString() {
  return 'UserReportStatsModel(totalCheckins: $totalCheckins, totalUnits: $totalUnits, totalReturns: $totalReturns, totalOrders: $totalOrders, totalDeliveries: $totalDeliveries)';
}


}

/// @nodoc
abstract mixin class _$UserReportStatsModelCopyWith<$Res> implements $UserReportStatsModelCopyWith<$Res> {
  factory _$UserReportStatsModelCopyWith(_UserReportStatsModel value, $Res Function(_UserReportStatsModel) _then) = __$UserReportStatsModelCopyWithImpl;
@override @useResult
$Res call({
 num totalCheckins, num totalUnits, num totalReturns, num totalOrders, num totalDeliveries
});




}
/// @nodoc
class __$UserReportStatsModelCopyWithImpl<$Res>
    implements _$UserReportStatsModelCopyWith<$Res> {
  __$UserReportStatsModelCopyWithImpl(this._self, this._then);

  final _UserReportStatsModel _self;
  final $Res Function(_UserReportStatsModel) _then;

/// Create a copy of UserReportStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCheckins = null,Object? totalUnits = null,Object? totalReturns = null,Object? totalOrders = null,Object? totalDeliveries = null,}) {
  return _then(_UserReportStatsModel(
totalCheckins: null == totalCheckins ? _self.totalCheckins : totalCheckins // ignore: cast_nullable_to_non_nullable
as num,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as num,totalReturns: null == totalReturns ? _self.totalReturns : totalReturns // ignore: cast_nullable_to_non_nullable
as num,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as num,totalDeliveries: null == totalDeliveries ? _self.totalDeliveries : totalDeliveries // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
