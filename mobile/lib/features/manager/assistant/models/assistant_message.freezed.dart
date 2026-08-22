// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantMessage {

/// 'user' | 'assistant'
 String get role; String get content; DateTime get createdAt;
/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantMessageCopyWith<AssistantMessage> get copyWith => _$AssistantMessageCopyWithImpl<AssistantMessage>(this as AssistantMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantMessage&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,role,content,createdAt);

@override
String toString() {
  return 'AssistantMessage(role: $role, content: $content, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AssistantMessageCopyWith<$Res>  {
  factory $AssistantMessageCopyWith(AssistantMessage value, $Res Function(AssistantMessage) _then) = _$AssistantMessageCopyWithImpl;
@useResult
$Res call({
 String role, String content, DateTime createdAt
});




}
/// @nodoc
class _$AssistantMessageCopyWithImpl<$Res>
    implements $AssistantMessageCopyWith<$Res> {
  _$AssistantMessageCopyWithImpl(this._self, this._then);

  final AssistantMessage _self;
  final $Res Function(AssistantMessage) _then;

/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? content = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AssistantMessage].
extension AssistantMessagePatterns on AssistantMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantMessage value)  $default,){
final _that = this;
switch (_that) {
case _AssistantMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantMessage value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role,  String content,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
return $default(_that.role,_that.content,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role,  String content,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AssistantMessage():
return $default(_that.role,_that.content,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role,  String content,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
return $default(_that.role,_that.content,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantMessage implements AssistantMessage {
  const _AssistantMessage({required this.role, required this.content, required this.createdAt});
  

/// 'user' | 'assistant'
@override final  String role;
@override final  String content;
@override final  DateTime createdAt;

/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantMessageCopyWith<_AssistantMessage> get copyWith => __$AssistantMessageCopyWithImpl<_AssistantMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantMessage&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,role,content,createdAt);

@override
String toString() {
  return 'AssistantMessage(role: $role, content: $content, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AssistantMessageCopyWith<$Res> implements $AssistantMessageCopyWith<$Res> {
  factory _$AssistantMessageCopyWith(_AssistantMessage value, $Res Function(_AssistantMessage) _then) = __$AssistantMessageCopyWithImpl;
@override @useResult
$Res call({
 String role, String content, DateTime createdAt
});




}
/// @nodoc
class __$AssistantMessageCopyWithImpl<$Res>
    implements _$AssistantMessageCopyWith<$Res> {
  __$AssistantMessageCopyWithImpl(this._self, this._then);

  final _AssistantMessage _self;
  final $Res Function(_AssistantMessage) _then;

/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? content = null,Object? createdAt = null,}) {
  return _then(_AssistantMessage(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
