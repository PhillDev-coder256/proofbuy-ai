// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppTransaction {

 String get id;@JsonKey(name: 'purchase_record_id') String get purchaseRecordId;@JsonKey(name: 'paypal_capture_id') String? get paypalCaptureId; String get status;@JsonKey(name: 'verified_at') DateTime? get verifiedAt;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppTransactionCopyWith<AppTransaction> get copyWith => _$AppTransactionCopyWithImpl<AppTransaction>(this as AppTransaction, _$identity);

  /// Serializes this AppTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppTransaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppTransaction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.purchaseRecordId, _this.purchaseRecordId) || other.purchaseRecordId == _this.purchaseRecordId)&&(identical(other.paypalCaptureId, _this.paypalCaptureId) || other.paypalCaptureId == _this.paypalCaptureId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.verifiedAt, _this.verifiedAt) || other.verifiedAt == _this.verifiedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppTransaction;
  return Object.hash(runtimeType,_this.id,_this.purchaseRecordId,_this.paypalCaptureId,_this.status,_this.verifiedAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as AppTransaction;
  return 'AppTransaction(id: ${_this.id}, purchaseRecordId: ${_this.purchaseRecordId}, paypalCaptureId: ${_this.paypalCaptureId}, status: ${_this.status}, verifiedAt: ${_this.verifiedAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AppTransactionCopyWith<$Res>  {
  factory $AppTransactionCopyWith(AppTransaction value, $Res Function(AppTransaction) _then) = _$AppTransactionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'purchase_record_id') String purchaseRecordId,@JsonKey(name: 'paypal_capture_id') String? paypalCaptureId, String status,@JsonKey(name: 'verified_at') DateTime? verifiedAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$AppTransactionCopyWithImpl<$Res>
    implements $AppTransactionCopyWith<$Res> {
  _$AppTransactionCopyWithImpl(this._self, this._then);

  final AppTransaction _self;
  final $Res Function(AppTransaction) _then;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? purchaseRecordId = null,Object? paypalCaptureId = freezed,Object? status = null,Object? verifiedAt = freezed,Object? createdAt = null,}) {
  return _then(AppTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,purchaseRecordId: null == purchaseRecordId ? _self.purchaseRecordId : purchaseRecordId // ignore: cast_nullable_to_non_nullable
as String,paypalCaptureId: freezed == paypalCaptureId ? _self.paypalCaptureId : paypalCaptureId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppTransaction].
extension AppTransactionPatterns on AppTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppTransaction value)  $default,){
final _that = this;
switch (_that) {
case _AppTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'purchase_record_id')  String purchaseRecordId, @JsonKey(name: 'paypal_capture_id')  String? paypalCaptureId,  String status, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
return $default(_that.id,_that.purchaseRecordId,_that.paypalCaptureId,_that.status,_that.verifiedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'purchase_record_id')  String purchaseRecordId, @JsonKey(name: 'paypal_capture_id')  String? paypalCaptureId,  String status, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AppTransaction():
return $default(_that.id,_that.purchaseRecordId,_that.paypalCaptureId,_that.status,_that.verifiedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'purchase_record_id')  String purchaseRecordId, @JsonKey(name: 'paypal_capture_id')  String? paypalCaptureId,  String status, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
return $default(_that.id,_that.purchaseRecordId,_that.paypalCaptureId,_that.status,_that.verifiedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppTransaction implements AppTransaction {
  const _AppTransaction({required this.id, @JsonKey(name: 'purchase_record_id') required this.purchaseRecordId, @JsonKey(name: 'paypal_capture_id') this.paypalCaptureId, required this.status, @JsonKey(name: 'verified_at') this.verifiedAt, @JsonKey(name: 'created_at') required this.createdAt});
  factory _AppTransaction.fromJson(Map<String, dynamic> json) => _$AppTransactionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'purchase_record_id') final  String purchaseRecordId;
@override@JsonKey(name: 'paypal_capture_id') final  String? paypalCaptureId;
@override final  String status;
@override@JsonKey(name: 'verified_at') final  DateTime? verifiedAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppTransactionCopyWith<_AppTransaction> get copyWith => __$AppTransactionCopyWithImpl<_AppTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.purchaseRecordId, purchaseRecordId) || other.purchaseRecordId == purchaseRecordId)&&(identical(other.paypalCaptureId, paypalCaptureId) || other.paypalCaptureId == paypalCaptureId)&&(identical(other.status, status) || other.status == status)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,purchaseRecordId,paypalCaptureId,status,verifiedAt,createdAt);
}

@override
String toString() {
    return 'AppTransaction(id: $id, purchaseRecordId: $purchaseRecordId, paypalCaptureId: $paypalCaptureId, status: $status, verifiedAt: $verifiedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AppTransactionCopyWith<$Res> implements $AppTransactionCopyWith<$Res> {
  factory _$AppTransactionCopyWith(_AppTransaction value, $Res Function(_AppTransaction) _then) = __$AppTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'purchase_record_id') String purchaseRecordId,@JsonKey(name: 'paypal_capture_id') String? paypalCaptureId, String status,@JsonKey(name: 'verified_at') DateTime? verifiedAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$AppTransactionCopyWithImpl<$Res>
    implements _$AppTransactionCopyWith<$Res> {
  __$AppTransactionCopyWithImpl(this._self, this._then);

  final _AppTransaction _self;
  final $Res Function(_AppTransaction) _then;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? purchaseRecordId = null,Object? paypalCaptureId = freezed,Object? status = null,Object? verifiedAt = freezed,Object? createdAt = null,}) {
  return _then(_AppTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,purchaseRecordId: null == purchaseRecordId ? _self.purchaseRecordId : purchaseRecordId // ignore: cast_nullable_to_non_nullable
as String,paypalCaptureId: freezed == paypalCaptureId ? _self.paypalCaptureId : paypalCaptureId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
