// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckoutState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CheckoutState()';
}


}

/// @nodoc
class $CheckoutStateCopyWith<$Res>  {
$CheckoutStateCopyWith(CheckoutState _, $Res Function(CheckoutState) __);
}


/// Adds pattern-matching-related methods to [CheckoutState].
extension CheckoutStatePatterns on CheckoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CheckoutIdle value)?  idle,TResult Function( CheckoutCreatingOrder value)?  creatingOrder,TResult Function( CheckoutAwaitingApproval value)?  awaitingApproval,TResult Function( CheckoutCapturing value)?  capturing,TResult Function( CheckoutSuccess value)?  success,TResult Function( CheckoutFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CheckoutIdle() when idle != null:
return idle(_that);case CheckoutCreatingOrder() when creatingOrder != null:
return creatingOrder(_that);case CheckoutAwaitingApproval() when awaitingApproval != null:
return awaitingApproval(_that);case CheckoutCapturing() when capturing != null:
return capturing(_that);case CheckoutSuccess() when success != null:
return success(_that);case CheckoutFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CheckoutIdle value)  idle,required TResult Function( CheckoutCreatingOrder value)  creatingOrder,required TResult Function( CheckoutAwaitingApproval value)  awaitingApproval,required TResult Function( CheckoutCapturing value)  capturing,required TResult Function( CheckoutSuccess value)  success,required TResult Function( CheckoutFailure value)  failure,}){
final _that = this;
switch (_that) {
case CheckoutIdle():
return idle(_that);case CheckoutCreatingOrder():
return creatingOrder(_that);case CheckoutAwaitingApproval():
return awaitingApproval(_that);case CheckoutCapturing():
return capturing(_that);case CheckoutSuccess():
return success(_that);case CheckoutFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CheckoutIdle value)?  idle,TResult? Function( CheckoutCreatingOrder value)?  creatingOrder,TResult? Function( CheckoutAwaitingApproval value)?  awaitingApproval,TResult? Function( CheckoutCapturing value)?  capturing,TResult? Function( CheckoutSuccess value)?  success,TResult? Function( CheckoutFailure value)?  failure,}){
final _that = this;
switch (_that) {
case CheckoutIdle() when idle != null:
return idle(_that);case CheckoutCreatingOrder() when creatingOrder != null:
return creatingOrder(_that);case CheckoutAwaitingApproval() when awaitingApproval != null:
return awaitingApproval(_that);case CheckoutCapturing() when capturing != null:
return capturing(_that);case CheckoutSuccess() when success != null:
return success(_that);case CheckoutFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  creatingOrder,TResult Function( String orderId,  String approvalUrl,  String purchaseId)?  awaitingApproval,TResult Function( String orderId,  String purchaseId)?  capturing,TResult Function( String transactionId)?  success,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CheckoutIdle() when idle != null:
return idle();case CheckoutCreatingOrder() when creatingOrder != null:
return creatingOrder();case CheckoutAwaitingApproval() when awaitingApproval != null:
return awaitingApproval(_that.orderId,_that.approvalUrl,_that.purchaseId);case CheckoutCapturing() when capturing != null:
return capturing(_that.orderId,_that.purchaseId);case CheckoutSuccess() when success != null:
return success(_that.transactionId);case CheckoutFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  creatingOrder,required TResult Function( String orderId,  String approvalUrl,  String purchaseId)  awaitingApproval,required TResult Function( String orderId,  String purchaseId)  capturing,required TResult Function( String transactionId)  success,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case CheckoutIdle():
return idle();case CheckoutCreatingOrder():
return creatingOrder();case CheckoutAwaitingApproval():
return awaitingApproval(_that.orderId,_that.approvalUrl,_that.purchaseId);case CheckoutCapturing():
return capturing(_that.orderId,_that.purchaseId);case CheckoutSuccess():
return success(_that.transactionId);case CheckoutFailure():
return failure(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  creatingOrder,TResult? Function( String orderId,  String approvalUrl,  String purchaseId)?  awaitingApproval,TResult? Function( String orderId,  String purchaseId)?  capturing,TResult? Function( String transactionId)?  success,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case CheckoutIdle() when idle != null:
return idle();case CheckoutCreatingOrder() when creatingOrder != null:
return creatingOrder();case CheckoutAwaitingApproval() when awaitingApproval != null:
return awaitingApproval(_that.orderId,_that.approvalUrl,_that.purchaseId);case CheckoutCapturing() when capturing != null:
return capturing(_that.orderId,_that.purchaseId);case CheckoutSuccess() when success != null:
return success(_that.transactionId);case CheckoutFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class CheckoutIdle implements CheckoutState {
  const CheckoutIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CheckoutState.idle()';
}


}




/// @nodoc


class CheckoutCreatingOrder implements CheckoutState {
  const CheckoutCreatingOrder();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutCreatingOrder);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CheckoutState.creatingOrder()';
}


}




/// @nodoc


class CheckoutAwaitingApproval implements CheckoutState {
  const CheckoutAwaitingApproval({required this.orderId, required this.approvalUrl, required this.purchaseId});
  

 final  String orderId;
 final  String approvalUrl;
 final  String purchaseId;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutAwaitingApprovalCopyWith<CheckoutAwaitingApproval> get copyWith => _$CheckoutAwaitingApprovalCopyWithImpl<CheckoutAwaitingApproval>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutAwaitingApproval&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.approvalUrl, approvalUrl) || other.approvalUrl == approvalUrl)&&(identical(other.purchaseId, purchaseId) || other.purchaseId == purchaseId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,orderId,approvalUrl,purchaseId);
}

@override
String toString() {
    return 'CheckoutState.awaitingApproval(orderId: $orderId, approvalUrl: $approvalUrl, purchaseId: $purchaseId)';
}


}

/// @nodoc
abstract mixin class $CheckoutAwaitingApprovalCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory $CheckoutAwaitingApprovalCopyWith(CheckoutAwaitingApproval value, $Res Function(CheckoutAwaitingApproval) _then) = _$CheckoutAwaitingApprovalCopyWithImpl;
@useResult
$Res call({
 String orderId, String approvalUrl, String purchaseId
});




}
/// @nodoc
class _$CheckoutAwaitingApprovalCopyWithImpl<$Res>
    implements $CheckoutAwaitingApprovalCopyWith<$Res> {
  _$CheckoutAwaitingApprovalCopyWithImpl(this._self, this._then);

  final CheckoutAwaitingApproval _self;
  final $Res Function(CheckoutAwaitingApproval) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? approvalUrl = null,Object? purchaseId = null,}) {
  return _then(CheckoutAwaitingApproval(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,approvalUrl: null == approvalUrl ? _self.approvalUrl : approvalUrl // ignore: cast_nullable_to_non_nullable
as String,purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CheckoutCapturing implements CheckoutState {
  const CheckoutCapturing({required this.orderId, required this.purchaseId});
  

 final  String orderId;
 final  String purchaseId;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutCapturingCopyWith<CheckoutCapturing> get copyWith => _$CheckoutCapturingCopyWithImpl<CheckoutCapturing>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutCapturing&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.purchaseId, purchaseId) || other.purchaseId == purchaseId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,orderId,purchaseId);
}

@override
String toString() {
    return 'CheckoutState.capturing(orderId: $orderId, purchaseId: $purchaseId)';
}


}

/// @nodoc
abstract mixin class $CheckoutCapturingCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory $CheckoutCapturingCopyWith(CheckoutCapturing value, $Res Function(CheckoutCapturing) _then) = _$CheckoutCapturingCopyWithImpl;
@useResult
$Res call({
 String orderId, String purchaseId
});




}
/// @nodoc
class _$CheckoutCapturingCopyWithImpl<$Res>
    implements $CheckoutCapturingCopyWith<$Res> {
  _$CheckoutCapturingCopyWithImpl(this._self, this._then);

  final CheckoutCapturing _self;
  final $Res Function(CheckoutCapturing) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? purchaseId = null,}) {
  return _then(CheckoutCapturing(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CheckoutSuccess implements CheckoutState {
  const CheckoutSuccess({required this.transactionId});
  

 final  String transactionId;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutSuccessCopyWith<CheckoutSuccess> get copyWith => _$CheckoutSuccessCopyWithImpl<CheckoutSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutSuccess&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,transactionId);
}

@override
String toString() {
    return 'CheckoutState.success(transactionId: $transactionId)';
}


}

/// @nodoc
abstract mixin class $CheckoutSuccessCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory $CheckoutSuccessCopyWith(CheckoutSuccess value, $Res Function(CheckoutSuccess) _then) = _$CheckoutSuccessCopyWithImpl;
@useResult
$Res call({
 String transactionId
});




}
/// @nodoc
class _$CheckoutSuccessCopyWithImpl<$Res>
    implements $CheckoutSuccessCopyWith<$Res> {
  _$CheckoutSuccessCopyWithImpl(this._self, this._then);

  final CheckoutSuccess _self;
  final $Res Function(CheckoutSuccess) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? transactionId = null,}) {
  return _then(CheckoutSuccess(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CheckoutFailure implements CheckoutState {
  const CheckoutFailure({required this.message});
  

 final  String message;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutFailureCopyWith<CheckoutFailure> get copyWith => _$CheckoutFailureCopyWithImpl<CheckoutFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'CheckoutState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $CheckoutFailureCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory $CheckoutFailureCopyWith(CheckoutFailure value, $Res Function(CheckoutFailure) _then) = _$CheckoutFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CheckoutFailureCopyWithImpl<$Res>
    implements $CheckoutFailureCopyWith<$Res> {
  _$CheckoutFailureCopyWithImpl(this._self, this._then);

  final CheckoutFailure _self;
  final $Res Function(CheckoutFailure) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CheckoutFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
