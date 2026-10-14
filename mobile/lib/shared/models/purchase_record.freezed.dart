// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PurchaseRecord {

 String get id;@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'product_result_id') String get productResultId; double get amount; String get currency; String get status;@JsonKey(name: 'paypal_order_id') String? get paypalOrderId;@JsonKey(name: 'idempotency_key') String? get idempotencyKey;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of PurchaseRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseRecordCopyWith<PurchaseRecord> get copyWith => _$PurchaseRecordCopyWithImpl<PurchaseRecord>(this as PurchaseRecord, _$identity);

  /// Serializes this PurchaseRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PurchaseRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.productResultId, _this.productResultId) || other.productResultId == _this.productResultId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.paypalOrderId, _this.paypalOrderId) || other.paypalOrderId == _this.paypalOrderId)&&(identical(other.idempotencyKey, _this.idempotencyKey) || other.idempotencyKey == _this.idempotencyKey)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PurchaseRecord;
  return Object.hash(runtimeType,_this.id,_this.sessionId,_this.productResultId,_this.amount,_this.currency,_this.status,_this.paypalOrderId,_this.idempotencyKey,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as PurchaseRecord;
  return 'PurchaseRecord(id: ${_this.id}, sessionId: ${_this.sessionId}, productResultId: ${_this.productResultId}, amount: ${_this.amount}, currency: ${_this.currency}, status: ${_this.status}, paypalOrderId: ${_this.paypalOrderId}, idempotencyKey: ${_this.idempotencyKey}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $PurchaseRecordCopyWith<$Res>  {
  factory $PurchaseRecordCopyWith(PurchaseRecord value, $Res Function(PurchaseRecord) _then) = _$PurchaseRecordCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'product_result_id') String productResultId, double amount, String currency, String status,@JsonKey(name: 'paypal_order_id') String? paypalOrderId,@JsonKey(name: 'idempotency_key') String? idempotencyKey,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$PurchaseRecordCopyWithImpl<$Res>
    implements $PurchaseRecordCopyWith<$Res> {
  _$PurchaseRecordCopyWithImpl(this._self, this._then);

  final PurchaseRecord _self;
  final $Res Function(PurchaseRecord) _then;

/// Create a copy of PurchaseRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? productResultId = null,Object? amount = null,Object? currency = null,Object? status = null,Object? paypalOrderId = freezed,Object? idempotencyKey = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(PurchaseRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,productResultId: null == productResultId ? _self.productResultId : productResultId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paypalOrderId: freezed == paypalOrderId ? _self.paypalOrderId : paypalOrderId // ignore: cast_nullable_to_non_nullable
as String?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseRecord].
extension PurchaseRecordPatterns on PurchaseRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseRecord value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'product_result_id')  String productResultId,  double amount,  String currency,  String status, @JsonKey(name: 'paypal_order_id')  String? paypalOrderId, @JsonKey(name: 'idempotency_key')  String? idempotencyKey, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseRecord() when $default != null:
return $default(_that.id,_that.sessionId,_that.productResultId,_that.amount,_that.currency,_that.status,_that.paypalOrderId,_that.idempotencyKey,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'product_result_id')  String productResultId,  double amount,  String currency,  String status, @JsonKey(name: 'paypal_order_id')  String? paypalOrderId, @JsonKey(name: 'idempotency_key')  String? idempotencyKey, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PurchaseRecord():
return $default(_that.id,_that.sessionId,_that.productResultId,_that.amount,_that.currency,_that.status,_that.paypalOrderId,_that.idempotencyKey,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'product_result_id')  String productResultId,  double amount,  String currency,  String status, @JsonKey(name: 'paypal_order_id')  String? paypalOrderId, @JsonKey(name: 'idempotency_key')  String? idempotencyKey, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseRecord() when $default != null:
return $default(_that.id,_that.sessionId,_that.productResultId,_that.amount,_that.currency,_that.status,_that.paypalOrderId,_that.idempotencyKey,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseRecord implements PurchaseRecord {
  const _PurchaseRecord({required this.id, @JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'product_result_id') required this.productResultId, required this.amount, required this.currency, required this.status, @JsonKey(name: 'paypal_order_id') this.paypalOrderId, @JsonKey(name: 'idempotency_key') this.idempotencyKey, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _PurchaseRecord.fromJson(Map<String, dynamic> json) => _$PurchaseRecordFromJson(json);

@override final  String id;
@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'product_result_id') final  String productResultId;
@override final  double amount;
@override final  String currency;
@override final  String status;
@override@JsonKey(name: 'paypal_order_id') final  String? paypalOrderId;
@override@JsonKey(name: 'idempotency_key') final  String? idempotencyKey;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of PurchaseRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseRecordCopyWith<_PurchaseRecord> get copyWith => __$PurchaseRecordCopyWithImpl<_PurchaseRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.productResultId, productResultId) || other.productResultId == productResultId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.paypalOrderId, paypalOrderId) || other.paypalOrderId == paypalOrderId)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionId,productResultId,amount,currency,status,paypalOrderId,idempotencyKey,createdAt,updatedAt);
}

@override
String toString() {
    return 'PurchaseRecord(id: $id, sessionId: $sessionId, productResultId: $productResultId, amount: $amount, currency: $currency, status: $status, paypalOrderId: $paypalOrderId, idempotencyKey: $idempotencyKey, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseRecordCopyWith<$Res> implements $PurchaseRecordCopyWith<$Res> {
  factory _$PurchaseRecordCopyWith(_PurchaseRecord value, $Res Function(_PurchaseRecord) _then) = __$PurchaseRecordCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'product_result_id') String productResultId, double amount, String currency, String status,@JsonKey(name: 'paypal_order_id') String? paypalOrderId,@JsonKey(name: 'idempotency_key') String? idempotencyKey,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$PurchaseRecordCopyWithImpl<$Res>
    implements _$PurchaseRecordCopyWith<$Res> {
  __$PurchaseRecordCopyWithImpl(this._self, this._then);

  final _PurchaseRecord _self;
  final $Res Function(_PurchaseRecord) _then;

/// Create a copy of PurchaseRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? productResultId = null,Object? amount = null,Object? currency = null,Object? status = null,Object? paypalOrderId = freezed,Object? idempotencyKey = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PurchaseRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,productResultId: null == productResultId ? _self.productResultId : productResultId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paypalOrderId: freezed == paypalOrderId ? _self.paypalOrderId : paypalOrderId // ignore: cast_nullable_to_non_nullable
as String?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
