// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShoppingSession {

 String get id;@JsonKey(name: 'brief_text') String get briefText;@JsonKey(name: 'requirements_json') Map<String, dynamic>? get requirementsJson; String get status;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of ShoppingSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingSessionCopyWith<ShoppingSession> get copyWith => _$ShoppingSessionCopyWithImpl<ShoppingSession>(this as ShoppingSession, _$identity);

  /// Serializes this ShoppingSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ShoppingSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.briefText, _this.briefText) || other.briefText == _this.briefText)&&const DeepCollectionEquality().equals(other.requirementsJson, _this.requirementsJson)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ShoppingSession;
  return Object.hash(runtimeType,_this.id,_this.briefText,const DeepCollectionEquality().hash(_this.requirementsJson),_this.status,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as ShoppingSession;
  return 'ShoppingSession(id: ${_this.id}, briefText: ${_this.briefText}, requirementsJson: ${_this.requirementsJson}, status: ${_this.status}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ShoppingSessionCopyWith<$Res>  {
  factory $ShoppingSessionCopyWith(ShoppingSession value, $Res Function(ShoppingSession) _then) = _$ShoppingSessionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'brief_text') String briefText,@JsonKey(name: 'requirements_json') Map<String, dynamic>? requirementsJson, String status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$ShoppingSessionCopyWithImpl<$Res>
    implements $ShoppingSessionCopyWith<$Res> {
  _$ShoppingSessionCopyWithImpl(this._self, this._then);

  final ShoppingSession _self;
  final $Res Function(ShoppingSession) _then;

/// Create a copy of ShoppingSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? briefText = null,Object? requirementsJson = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(ShoppingSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,briefText: null == briefText ? _self.briefText : briefText // ignore: cast_nullable_to_non_nullable
as String,requirementsJson: freezed == requirementsJson ? _self.requirementsJson : requirementsJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingSession].
extension ShoppingSessionPatterns on ShoppingSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingSession value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingSession value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'brief_text')  String briefText, @JsonKey(name: 'requirements_json')  Map<String, dynamic>? requirementsJson,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingSession() when $default != null:
return $default(_that.id,_that.briefText,_that.requirementsJson,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'brief_text')  String briefText, @JsonKey(name: 'requirements_json')  Map<String, dynamic>? requirementsJson,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ShoppingSession():
return $default(_that.id,_that.briefText,_that.requirementsJson,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'brief_text')  String briefText, @JsonKey(name: 'requirements_json')  Map<String, dynamic>? requirementsJson,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingSession() when $default != null:
return $default(_that.id,_that.briefText,_that.requirementsJson,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShoppingSession implements ShoppingSession {
  const _ShoppingSession({required this.id, @JsonKey(name: 'brief_text') required this.briefText, @JsonKey(name: 'requirements_json')  Map<String, dynamic>? requirementsJson, required this.status, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _requirementsJson = requirementsJson;
  factory _ShoppingSession.fromJson(Map<String, dynamic> json) => _$ShoppingSessionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'brief_text') final  String briefText;
 final  Map<String, dynamic>? _requirementsJson;
@override@JsonKey(name: 'requirements_json') Map<String, dynamic>? get requirementsJson {
  final value = _requirementsJson;
  if (value == null) return null;
  if (_requirementsJson is EqualUnmodifiableMapView) return _requirementsJson;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of ShoppingSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingSessionCopyWith<_ShoppingSession> get copyWith => __$ShoppingSessionCopyWithImpl<_ShoppingSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShoppingSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.briefText, briefText) || other.briefText == briefText)&&const DeepCollectionEquality().equals(other.requirementsJson, _requirementsJson)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,briefText,const DeepCollectionEquality().hash(_requirementsJson),status,createdAt,updatedAt);
}

@override
String toString() {
    return 'ShoppingSession(id: $id, briefText: $briefText, requirementsJson: $requirementsJson, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ShoppingSessionCopyWith<$Res> implements $ShoppingSessionCopyWith<$Res> {
  factory _$ShoppingSessionCopyWith(_ShoppingSession value, $Res Function(_ShoppingSession) _then) = __$ShoppingSessionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'brief_text') String briefText,@JsonKey(name: 'requirements_json') Map<String, dynamic>? requirementsJson, String status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$ShoppingSessionCopyWithImpl<$Res>
    implements _$ShoppingSessionCopyWith<$Res> {
  __$ShoppingSessionCopyWithImpl(this._self, this._then);

  final _ShoppingSession _self;
  final $Res Function(_ShoppingSession) _then;

/// Create a copy of ShoppingSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? briefText = null,Object? requirementsJson = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ShoppingSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,briefText: null == briefText ? _self.briefText : briefText // ignore: cast_nullable_to_non_nullable
as String,requirementsJson: freezed == requirementsJson ? _self._requirementsJson : requirementsJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
