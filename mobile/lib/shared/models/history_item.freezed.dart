// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistoryItem {

@JsonKey(name: 'purchase_record') PurchaseRecord get purchaseRecord; ProductData? get product; ShoppingSession? get session;
/// Create a copy of HistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryItemCopyWith<HistoryItem> get copyWith => _$HistoryItemCopyWithImpl<HistoryItem>(this as HistoryItem, _$identity);

  /// Serializes this HistoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HistoryItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryItem&&(identical(other.purchaseRecord, _this.purchaseRecord) || other.purchaseRecord == _this.purchaseRecord)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.session, _this.session) || other.session == _this.session));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HistoryItem;
  return Object.hash(runtimeType,_this.purchaseRecord,_this.product,_this.session);
}

@override
String toString() {
  final _this = this as HistoryItem;
  return 'HistoryItem(purchaseRecord: ${_this.purchaseRecord}, product: ${_this.product}, session: ${_this.session})';
}


}

/// @nodoc
abstract mixin class $HistoryItemCopyWith<$Res>  {
  factory $HistoryItemCopyWith(HistoryItem value, $Res Function(HistoryItem) _then) = _$HistoryItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'purchase_record') PurchaseRecord purchaseRecord, ProductData? product, ShoppingSession? session
});


$PurchaseRecordCopyWith<$Res> get purchaseRecord;$ProductDataCopyWith<$Res>? get product;$ShoppingSessionCopyWith<$Res>? get session;

}
/// @nodoc
class _$HistoryItemCopyWithImpl<$Res>
    implements $HistoryItemCopyWith<$Res> {
  _$HistoryItemCopyWithImpl(this._self, this._then);

  final HistoryItem _self;
  final $Res Function(HistoryItem) _then;

/// Create a copy of HistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? purchaseRecord = null,Object? product = freezed,Object? session = freezed,}) {
  return _then(HistoryItem(
purchaseRecord: null == purchaseRecord ? _self.purchaseRecord : purchaseRecord // ignore: cast_nullable_to_non_nullable
as PurchaseRecord,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductData?,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ShoppingSession?,
  ));
}
/// Create a copy of HistoryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PurchaseRecordCopyWith<$Res> get purchaseRecord {
  
  return $PurchaseRecordCopyWith<$Res>(_self.purchaseRecord, (value) {
    return _then(_self.copyWith(purchaseRecord: value));
  });
}/// Create a copy of HistoryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductDataCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $ProductDataCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of HistoryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShoppingSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $ShoppingSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [HistoryItem].
extension HistoryItemPatterns on HistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _HistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'purchase_record')  PurchaseRecord purchaseRecord,  ProductData? product,  ShoppingSession? session)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryItem() when $default != null:
return $default(_that.purchaseRecord,_that.product,_that.session);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'purchase_record')  PurchaseRecord purchaseRecord,  ProductData? product,  ShoppingSession? session)  $default,) {final _that = this;
switch (_that) {
case _HistoryItem():
return $default(_that.purchaseRecord,_that.product,_that.session);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'purchase_record')  PurchaseRecord purchaseRecord,  ProductData? product,  ShoppingSession? session)?  $default,) {final _that = this;
switch (_that) {
case _HistoryItem() when $default != null:
return $default(_that.purchaseRecord,_that.product,_that.session);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoryItem implements HistoryItem {
  const _HistoryItem({@JsonKey(name: 'purchase_record') required this.purchaseRecord, this.product, this.session});
  factory _HistoryItem.fromJson(Map<String, dynamic> json) => _$HistoryItemFromJson(json);

@override@JsonKey(name: 'purchase_record') final  PurchaseRecord purchaseRecord;
@override final  ProductData? product;
@override final  ShoppingSession? session;

/// Create a copy of HistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryItemCopyWith<_HistoryItem> get copyWith => __$HistoryItemCopyWithImpl<_HistoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryItem&&(identical(other.purchaseRecord, purchaseRecord) || other.purchaseRecord == purchaseRecord)&&(identical(other.product, product) || other.product == product)&&(identical(other.session, session) || other.session == session));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,purchaseRecord,product,session);
}

@override
String toString() {
    return 'HistoryItem(purchaseRecord: $purchaseRecord, product: $product, session: $session)';
}


}

/// @nodoc
abstract mixin class _$HistoryItemCopyWith<$Res> implements $HistoryItemCopyWith<$Res> {
  factory _$HistoryItemCopyWith(_HistoryItem value, $Res Function(_HistoryItem) _then) = __$HistoryItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'purchase_record') PurchaseRecord purchaseRecord, ProductData? product, ShoppingSession? session
});


@override $PurchaseRecordCopyWith<$Res> get purchaseRecord;@override $ProductDataCopyWith<$Res>? get product;@override $ShoppingSessionCopyWith<$Res>? get session;

}
/// @nodoc
class __$HistoryItemCopyWithImpl<$Res>
    implements _$HistoryItemCopyWith<$Res> {
  __$HistoryItemCopyWithImpl(this._self, this._then);

  final _HistoryItem _self;
  final $Res Function(_HistoryItem) _then;

/// Create a copy of HistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? purchaseRecord = null,Object? product = freezed,Object? session = freezed,}) {
  return _then(_HistoryItem(
purchaseRecord: null == purchaseRecord ? _self.purchaseRecord : purchaseRecord // ignore: cast_nullable_to_non_nullable
as PurchaseRecord,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductData?,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ShoppingSession?,
  ));
}

/// Create a copy of HistoryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PurchaseRecordCopyWith<$Res> get purchaseRecord {
  
  return $PurchaseRecordCopyWith<$Res>(_self.purchaseRecord, (value) {
    return _then(_self.copyWith(purchaseRecord: value));
  });
}/// Create a copy of HistoryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductDataCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $ProductDataCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of HistoryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShoppingSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $ShoppingSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

// dart format on
