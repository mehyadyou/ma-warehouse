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

 List<TransactionEntryModel> get transactions; List<HistoryEntryModel> get activityLog;
/// Create a copy of RecentActivityData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentActivityDataCopyWith<RecentActivityData> get copyWith => _$RecentActivityDataCopyWithImpl<RecentActivityData>(this as RecentActivityData, _$identity);

  /// Serializes this RecentActivityData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentActivityData&&const DeepCollectionEquality().equals(other.transactions, transactions)&&const DeepCollectionEquality().equals(other.activityLog, activityLog));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(transactions),const DeepCollectionEquality().hash(activityLog));

@override
String toString() {
  return 'RecentActivityData(transactions: $transactions, activityLog: $activityLog)';
}


}

/// @nodoc
abstract mixin class $RecentActivityDataCopyWith<$Res>  {
  factory $RecentActivityDataCopyWith(RecentActivityData value, $Res Function(RecentActivityData) _then) = _$RecentActivityDataCopyWithImpl;
@useResult
$Res call({
 List<TransactionEntryModel> transactions, List<HistoryEntryModel> activityLog
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
@pragma('vm:prefer-inline') @override $Res call({Object? transactions = null,Object? activityLog = null,}) {
  return _then(_self.copyWith(
transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntryModel>,activityLog: null == activityLog ? _self.activityLog : activityLog // ignore: cast_nullable_to_non_nullable
as List<HistoryEntryModel>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TransactionEntryModel> transactions,  List<HistoryEntryModel> activityLog)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentActivityData() when $default != null:
return $default(_that.transactions,_that.activityLog);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TransactionEntryModel> transactions,  List<HistoryEntryModel> activityLog)  $default,) {final _that = this;
switch (_that) {
case _RecentActivityData():
return $default(_that.transactions,_that.activityLog);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TransactionEntryModel> transactions,  List<HistoryEntryModel> activityLog)?  $default,) {final _that = this;
switch (_that) {
case _RecentActivityData() when $default != null:
return $default(_that.transactions,_that.activityLog);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentActivityData implements RecentActivityData {
  const _RecentActivityData({final  List<TransactionEntryModel> transactions = const <TransactionEntryModel>[], final  List<HistoryEntryModel> activityLog = const <HistoryEntryModel>[]}): _transactions = transactions,_activityLog = activityLog;
  factory _RecentActivityData.fromJson(Map<String, dynamic> json) => _$RecentActivityDataFromJson(json);

 final  List<TransactionEntryModel> _transactions;
@override@JsonKey() List<TransactionEntryModel> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}

 final  List<HistoryEntryModel> _activityLog;
@override@JsonKey() List<HistoryEntryModel> get activityLog {
  if (_activityLog is EqualUnmodifiableListView) return _activityLog;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activityLog);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentActivityData&&const DeepCollectionEquality().equals(other._transactions, _transactions)&&const DeepCollectionEquality().equals(other._activityLog, _activityLog));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_transactions),const DeepCollectionEquality().hash(_activityLog));

@override
String toString() {
  return 'RecentActivityData(transactions: $transactions, activityLog: $activityLog)';
}


}

/// @nodoc
abstract mixin class _$RecentActivityDataCopyWith<$Res> implements $RecentActivityDataCopyWith<$Res> {
  factory _$RecentActivityDataCopyWith(_RecentActivityData value, $Res Function(_RecentActivityData) _then) = __$RecentActivityDataCopyWithImpl;
@override @useResult
$Res call({
 List<TransactionEntryModel> transactions, List<HistoryEntryModel> activityLog
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
@override @pragma('vm:prefer-inline') $Res call({Object? transactions = null,Object? activityLog = null,}) {
  return _then(_RecentActivityData(
transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntryModel>,activityLog: null == activityLog ? _self._activityLog : activityLog // ignore: cast_nullable_to_non_nullable
as List<HistoryEntryModel>,
  ));
}


}

// dart format on
