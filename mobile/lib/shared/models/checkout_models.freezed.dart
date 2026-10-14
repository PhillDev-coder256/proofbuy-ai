// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckoutCreateRequest {

@JsonKey(name: 'product_result_id') String get productResultId;@JsonKey(name: 'session_id') String? get sessionId;
/// Create a copy of CheckoutCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutCreateRequestCopyWith<CheckoutCreateRequest> get copyWith => _$CheckoutCreateRequestCopyWithImpl<CheckoutCreateRequest>(this as CheckoutCreateRequest, _$identity);

  /// Serializes this CheckoutCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckoutCreateRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutCreateRequest&&(identical(other.productResultId, _this.productResultId) || other.productResultId == _this.productResultId)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckoutCreateRequest;
  return Object.hash(runtimeType,_this.productResultId,_this.sessionId);
}

@override
String toString() {
  final _this = this as CheckoutCreateRequest;
  return 'CheckoutCreateRequest(productResultId: ${_this.productResultId}, sessionId: ${_this.sessionId})';
}


}

/// @nodoc
abstract mixin class $CheckoutCreateRequestCopyWith<$Res>  {
  factory $CheckoutCreateRequestCopyWith(CheckoutCreateRequest value, $Res Function(CheckoutCreateRequest) _then) = _$CheckoutCreateRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'product_result_id') String productResultId,@JsonKey(name: 'session_id') String? sessionId
});




}
/// @nodoc
class _$CheckoutCreateRequestCopyWithImpl<$Res>
    implements $CheckoutCreateRequestCopyWith<$Res> {
  _$CheckoutCreateRequestCopyWithImpl(this._self, this._then);

  final CheckoutCreateRequest _self;
  final $Res Function(CheckoutCreateRequest) _then;

/// Create a copy of CheckoutCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productResultId = null,Object? sessionId = freezed,}) {
  return _then(CheckoutCreateRequest(
productResultId: null == productResultId ? _self.productResultId : productResultId // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutCreateRequest].
extension CheckoutCreateRequestPatterns on CheckoutCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_result_id')  String productResultId, @JsonKey(name: 'session_id')  String? sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutCreateRequest() when $default != null:
return $default(_that.productResultId,_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_result_id')  String productResultId, @JsonKey(name: 'session_id')  String? sessionId)  $default,) {final _that = this;
switch (_that) {
case _CheckoutCreateRequest():
return $default(_that.productResultId,_that.sessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'product_result_id')  String productResultId, @JsonKey(name: 'session_id')  String? sessionId)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutCreateRequest() when $default != null:
return $default(_that.productResultId,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutCreateRequest implements CheckoutCreateRequest {
  const _CheckoutCreateRequest({@JsonKey(name: 'product_result_id') required this.productResultId, @JsonKey(name: 'session_id') this.sessionId});
  factory _CheckoutCreateRequest.fromJson(Map<String, dynamic> json) => _$CheckoutCreateRequestFromJson(json);

@override@JsonKey(name: 'product_result_id') final  String productResultId;
@override@JsonKey(name: 'session_id') final  String? sessionId;

/// Create a copy of CheckoutCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutCreateRequestCopyWith<_CheckoutCreateRequest> get copyWith => __$CheckoutCreateRequestCopyWithImpl<_CheckoutCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutCreateRequest&&(identical(other.productResultId, productResultId) || other.productResultId == productResultId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productResultId,sessionId);
}

@override
String toString() {
    return 'CheckoutCreateRequest(productResultId: $productResultId, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$CheckoutCreateRequestCopyWith<$Res> implements $CheckoutCreateRequestCopyWith<$Res> {
  factory _$CheckoutCreateRequestCopyWith(_CheckoutCreateRequest value, $Res Function(_CheckoutCreateRequest) _then) = __$CheckoutCreateRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'product_result_id') String productResultId,@JsonKey(name: 'session_id') String? sessionId
});




}
/// @nodoc
class __$CheckoutCreateRequestCopyWithImpl<$Res>
    implements _$CheckoutCreateRequestCopyWith<$Res> {
  __$CheckoutCreateRequestCopyWithImpl(this._self, this._then);

  final _CheckoutCreateRequest _self;
  final $Res Function(_CheckoutCreateRequest) _then;

/// Create a copy of CheckoutCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productResultId = null,Object? sessionId = freezed,}) {
  return _then(_CheckoutCreateRequest(
productResultId: null == productResultId ? _self.productResultId : productResultId // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CheckoutCreateResponse {

@JsonKey(name: 'order_id') String get orderId;@JsonKey(name: 'approval_url') String get approvalUrl;@JsonKey(name: 'purchase_id') String get purchaseId;
/// Create a copy of CheckoutCreateResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutCreateResponseCopyWith<CheckoutCreateResponse> get copyWith => _$CheckoutCreateResponseCopyWithImpl<CheckoutCreateResponse>(this as CheckoutCreateResponse, _$identity);

  /// Serializes this CheckoutCreateResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckoutCreateResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutCreateResponse&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.approvalUrl, _this.approvalUrl) || other.approvalUrl == _this.approvalUrl)&&(identical(other.purchaseId, _this.purchaseId) || other.purchaseId == _this.purchaseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckoutCreateResponse;
  return Object.hash(runtimeType,_this.orderId,_this.approvalUrl,_this.purchaseId);
}

@override
String toString() {
  final _this = this as CheckoutCreateResponse;
  return 'CheckoutCreateResponse(orderId: ${_this.orderId}, approvalUrl: ${_this.approvalUrl}, purchaseId: ${_this.purchaseId})';
}


}

/// @nodoc
abstract mixin class $CheckoutCreateResponseCopyWith<$Res>  {
  factory $CheckoutCreateResponseCopyWith(CheckoutCreateResponse value, $Res Function(CheckoutCreateResponse) _then) = _$CheckoutCreateResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'approval_url') String approvalUrl,@JsonKey(name: 'purchase_id') String purchaseId
});




}
/// @nodoc
class _$CheckoutCreateResponseCopyWithImpl<$Res>
    implements $CheckoutCreateResponseCopyWith<$Res> {
  _$CheckoutCreateResponseCopyWithImpl(this._self, this._then);

  final CheckoutCreateResponse _self;
  final $Res Function(CheckoutCreateResponse) _then;

/// Create a copy of CheckoutCreateResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? approvalUrl = null,Object? purchaseId = null,}) {
  return _then(CheckoutCreateResponse(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,approvalUrl: null == approvalUrl ? _self.approvalUrl : approvalUrl // ignore: cast_nullable_to_non_nullable
as String,purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutCreateResponse].
extension CheckoutCreateResponsePatterns on CheckoutCreateResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutCreateResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutCreateResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutCreateResponse value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutCreateResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutCreateResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutCreateResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'approval_url')  String approvalUrl, @JsonKey(name: 'purchase_id')  String purchaseId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutCreateResponse() when $default != null:
return $default(_that.orderId,_that.approvalUrl,_that.purchaseId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'approval_url')  String approvalUrl, @JsonKey(name: 'purchase_id')  String purchaseId)  $default,) {final _that = this;
switch (_that) {
case _CheckoutCreateResponse():
return $default(_that.orderId,_that.approvalUrl,_that.purchaseId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'approval_url')  String approvalUrl, @JsonKey(name: 'purchase_id')  String purchaseId)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutCreateResponse() when $default != null:
return $default(_that.orderId,_that.approvalUrl,_that.purchaseId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutCreateResponse implements CheckoutCreateResponse {
  const _CheckoutCreateResponse({@JsonKey(name: 'order_id') required this.orderId, @JsonKey(name: 'approval_url') required this.approvalUrl, @JsonKey(name: 'purchase_id') required this.purchaseId});
  factory _CheckoutCreateResponse.fromJson(Map<String, dynamic> json) => _$CheckoutCreateResponseFromJson(json);

@override@JsonKey(name: 'order_id') final  String orderId;
@override@JsonKey(name: 'approval_url') final  String approvalUrl;
@override@JsonKey(name: 'purchase_id') final  String purchaseId;

/// Create a copy of CheckoutCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutCreateResponseCopyWith<_CheckoutCreateResponse> get copyWith => __$CheckoutCreateResponseCopyWithImpl<_CheckoutCreateResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutCreateResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutCreateResponse&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.approvalUrl, approvalUrl) || other.approvalUrl == approvalUrl)&&(identical(other.purchaseId, purchaseId) || other.purchaseId == purchaseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,orderId,approvalUrl,purchaseId);
}

@override
String toString() {
    return 'CheckoutCreateResponse(orderId: $orderId, approvalUrl: $approvalUrl, purchaseId: $purchaseId)';
}


}

/// @nodoc
abstract mixin class _$CheckoutCreateResponseCopyWith<$Res> implements $CheckoutCreateResponseCopyWith<$Res> {
  factory _$CheckoutCreateResponseCopyWith(_CheckoutCreateResponse value, $Res Function(_CheckoutCreateResponse) _then) = __$CheckoutCreateResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'approval_url') String approvalUrl,@JsonKey(name: 'purchase_id') String purchaseId
});




}
/// @nodoc
class __$CheckoutCreateResponseCopyWithImpl<$Res>
    implements _$CheckoutCreateResponseCopyWith<$Res> {
  __$CheckoutCreateResponseCopyWithImpl(this._self, this._then);

  final _CheckoutCreateResponse _self;
  final $Res Function(_CheckoutCreateResponse) _then;

/// Create a copy of CheckoutCreateResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? approvalUrl = null,Object? purchaseId = null,}) {
  return _then(_CheckoutCreateResponse(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,approvalUrl: null == approvalUrl ? _self.approvalUrl : approvalUrl // ignore: cast_nullable_to_non_nullable
as String,purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CheckoutCaptureRequest {

@JsonKey(name: 'order_id') String get orderId;@JsonKey(name: 'purchase_id') String get purchaseId;
/// Create a copy of CheckoutCaptureRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutCaptureRequestCopyWith<CheckoutCaptureRequest> get copyWith => _$CheckoutCaptureRequestCopyWithImpl<CheckoutCaptureRequest>(this as CheckoutCaptureRequest, _$identity);

  /// Serializes this CheckoutCaptureRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckoutCaptureRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutCaptureRequest&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.purchaseId, _this.purchaseId) || other.purchaseId == _this.purchaseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckoutCaptureRequest;
  return Object.hash(runtimeType,_this.orderId,_this.purchaseId);
}

@override
String toString() {
  final _this = this as CheckoutCaptureRequest;
  return 'CheckoutCaptureRequest(orderId: ${_this.orderId}, purchaseId: ${_this.purchaseId})';
}


}

/// @nodoc
abstract mixin class $CheckoutCaptureRequestCopyWith<$Res>  {
  factory $CheckoutCaptureRequestCopyWith(CheckoutCaptureRequest value, $Res Function(CheckoutCaptureRequest) _then) = _$CheckoutCaptureRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'purchase_id') String purchaseId
});




}
/// @nodoc
class _$CheckoutCaptureRequestCopyWithImpl<$Res>
    implements $CheckoutCaptureRequestCopyWith<$Res> {
  _$CheckoutCaptureRequestCopyWithImpl(this._self, this._then);

  final CheckoutCaptureRequest _self;
  final $Res Function(CheckoutCaptureRequest) _then;

/// Create a copy of CheckoutCaptureRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? purchaseId = null,}) {
  return _then(CheckoutCaptureRequest(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutCaptureRequest].
extension CheckoutCaptureRequestPatterns on CheckoutCaptureRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutCaptureRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutCaptureRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutCaptureRequest value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutCaptureRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutCaptureRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutCaptureRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'purchase_id')  String purchaseId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutCaptureRequest() when $default != null:
return $default(_that.orderId,_that.purchaseId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'purchase_id')  String purchaseId)  $default,) {final _that = this;
switch (_that) {
case _CheckoutCaptureRequest():
return $default(_that.orderId,_that.purchaseId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'purchase_id')  String purchaseId)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutCaptureRequest() when $default != null:
return $default(_that.orderId,_that.purchaseId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutCaptureRequest implements CheckoutCaptureRequest {
  const _CheckoutCaptureRequest({@JsonKey(name: 'order_id') required this.orderId, @JsonKey(name: 'purchase_id') required this.purchaseId});
  factory _CheckoutCaptureRequest.fromJson(Map<String, dynamic> json) => _$CheckoutCaptureRequestFromJson(json);

@override@JsonKey(name: 'order_id') final  String orderId;
@override@JsonKey(name: 'purchase_id') final  String purchaseId;

/// Create a copy of CheckoutCaptureRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutCaptureRequestCopyWith<_CheckoutCaptureRequest> get copyWith => __$CheckoutCaptureRequestCopyWithImpl<_CheckoutCaptureRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutCaptureRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutCaptureRequest&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.purchaseId, purchaseId) || other.purchaseId == purchaseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,orderId,purchaseId);
}

@override
String toString() {
    return 'CheckoutCaptureRequest(orderId: $orderId, purchaseId: $purchaseId)';
}


}

/// @nodoc
abstract mixin class _$CheckoutCaptureRequestCopyWith<$Res> implements $CheckoutCaptureRequestCopyWith<$Res> {
  factory _$CheckoutCaptureRequestCopyWith(_CheckoutCaptureRequest value, $Res Function(_CheckoutCaptureRequest) _then) = __$CheckoutCaptureRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'purchase_id') String purchaseId
});




}
/// @nodoc
class __$CheckoutCaptureRequestCopyWithImpl<$Res>
    implements _$CheckoutCaptureRequestCopyWith<$Res> {
  __$CheckoutCaptureRequestCopyWithImpl(this._self, this._then);

  final _CheckoutCaptureRequest _self;
  final $Res Function(_CheckoutCaptureRequest) _then;

/// Create a copy of CheckoutCaptureRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? purchaseId = null,}) {
  return _then(_CheckoutCaptureRequest(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CheckoutCaptureResponse {

@JsonKey(name: 'transaction_id') String get transactionId; String get status; bool get verified;
/// Create a copy of CheckoutCaptureResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutCaptureResponseCopyWith<CheckoutCaptureResponse> get copyWith => _$CheckoutCaptureResponseCopyWithImpl<CheckoutCaptureResponse>(this as CheckoutCaptureResponse, _$identity);

  /// Serializes this CheckoutCaptureResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckoutCaptureResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutCaptureResponse&&(identical(other.transactionId, _this.transactionId) || other.transactionId == _this.transactionId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.verified, _this.verified) || other.verified == _this.verified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckoutCaptureResponse;
  return Object.hash(runtimeType,_this.transactionId,_this.status,_this.verified);
}

@override
String toString() {
  final _this = this as CheckoutCaptureResponse;
  return 'CheckoutCaptureResponse(transactionId: ${_this.transactionId}, status: ${_this.status}, verified: ${_this.verified})';
}


}

/// @nodoc
abstract mixin class $CheckoutCaptureResponseCopyWith<$Res>  {
  factory $CheckoutCaptureResponseCopyWith(CheckoutCaptureResponse value, $Res Function(CheckoutCaptureResponse) _then) = _$CheckoutCaptureResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'transaction_id') String transactionId, String status, bool verified
});




}
/// @nodoc
class _$CheckoutCaptureResponseCopyWithImpl<$Res>
    implements $CheckoutCaptureResponseCopyWith<$Res> {
  _$CheckoutCaptureResponseCopyWithImpl(this._self, this._then);

  final CheckoutCaptureResponse _self;
  final $Res Function(CheckoutCaptureResponse) _then;

/// Create a copy of CheckoutCaptureResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionId = null,Object? status = null,Object? verified = null,}) {
  return _then(CheckoutCaptureResponse(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutCaptureResponse].
extension CheckoutCaptureResponsePatterns on CheckoutCaptureResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutCaptureResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutCaptureResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutCaptureResponse value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutCaptureResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutCaptureResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutCaptureResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'transaction_id')  String transactionId,  String status,  bool verified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutCaptureResponse() when $default != null:
return $default(_that.transactionId,_that.status,_that.verified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'transaction_id')  String transactionId,  String status,  bool verified)  $default,) {final _that = this;
switch (_that) {
case _CheckoutCaptureResponse():
return $default(_that.transactionId,_that.status,_that.verified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'transaction_id')  String transactionId,  String status,  bool verified)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutCaptureResponse() when $default != null:
return $default(_that.transactionId,_that.status,_that.verified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutCaptureResponse implements CheckoutCaptureResponse {
  const _CheckoutCaptureResponse({@JsonKey(name: 'transaction_id') required this.transactionId, required this.status, required this.verified});
  factory _CheckoutCaptureResponse.fromJson(Map<String, dynamic> json) => _$CheckoutCaptureResponseFromJson(json);

@override@JsonKey(name: 'transaction_id') final  String transactionId;
@override final  String status;
@override final  bool verified;

/// Create a copy of CheckoutCaptureResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutCaptureResponseCopyWith<_CheckoutCaptureResponse> get copyWith => __$CheckoutCaptureResponseCopyWithImpl<_CheckoutCaptureResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutCaptureResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutCaptureResponse&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.status, status) || other.status == status)&&(identical(other.verified, verified) || other.verified == verified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,transactionId,status,verified);
}

@override
String toString() {
    return 'CheckoutCaptureResponse(transactionId: $transactionId, status: $status, verified: $verified)';
}


}

/// @nodoc
abstract mixin class _$CheckoutCaptureResponseCopyWith<$Res> implements $CheckoutCaptureResponseCopyWith<$Res> {
  factory _$CheckoutCaptureResponseCopyWith(_CheckoutCaptureResponse value, $Res Function(_CheckoutCaptureResponse) _then) = __$CheckoutCaptureResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'transaction_id') String transactionId, String status, bool verified
});




}
/// @nodoc
class __$CheckoutCaptureResponseCopyWithImpl<$Res>
    implements _$CheckoutCaptureResponseCopyWith<$Res> {
  __$CheckoutCaptureResponseCopyWithImpl(this._self, this._then);

  final _CheckoutCaptureResponse _self;
  final $Res Function(_CheckoutCaptureResponse) _then;

/// Create a copy of CheckoutCaptureResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionId = null,Object? status = null,Object? verified = null,}) {
  return _then(_CheckoutCaptureResponse(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
