// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ranked_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductData {

@JsonKey(name: 'channel3_product_id') String? get channel3ProductId; String get name; double? get price; String? get currency; String? get merchant;@JsonKey(name: 'source_url') String? get sourceUrl;@JsonKey(name: 'image_url') String? get imageUrl; Map<String, dynamic>? get specs;@JsonKey(name: 'retrieved_at') String? get retrievedAt;
/// Create a copy of ProductData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDataCopyWith<ProductData> get copyWith => _$ProductDataCopyWithImpl<ProductData>(this as ProductData, _$identity);

  /// Serializes this ProductData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductData&&(identical(other.channel3ProductId, _this.channel3ProductId) || other.channel3ProductId == _this.channel3ProductId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.merchant, _this.merchant) || other.merchant == _this.merchant)&&(identical(other.sourceUrl, _this.sourceUrl) || other.sourceUrl == _this.sourceUrl)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&const DeepCollectionEquality().equals(other.specs, _this.specs)&&(identical(other.retrievedAt, _this.retrievedAt) || other.retrievedAt == _this.retrievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductData;
  return Object.hash(runtimeType,_this.channel3ProductId,_this.name,_this.price,_this.currency,_this.merchant,_this.sourceUrl,_this.imageUrl,const DeepCollectionEquality().hash(_this.specs),_this.retrievedAt);
}

@override
String toString() {
  final _this = this as ProductData;
  return 'ProductData(channel3ProductId: ${_this.channel3ProductId}, name: ${_this.name}, price: ${_this.price}, currency: ${_this.currency}, merchant: ${_this.merchant}, sourceUrl: ${_this.sourceUrl}, imageUrl: ${_this.imageUrl}, specs: ${_this.specs}, retrievedAt: ${_this.retrievedAt})';
}


}

/// @nodoc
abstract mixin class $ProductDataCopyWith<$Res>  {
  factory $ProductDataCopyWith(ProductData value, $Res Function(ProductData) _then) = _$ProductDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'channel3_product_id') String? channel3ProductId, String name, double? price, String? currency, String? merchant,@JsonKey(name: 'source_url') String? sourceUrl,@JsonKey(name: 'image_url') String? imageUrl, Map<String, dynamic>? specs,@JsonKey(name: 'retrieved_at') String? retrievedAt
});




}
/// @nodoc
class _$ProductDataCopyWithImpl<$Res>
    implements $ProductDataCopyWith<$Res> {
  _$ProductDataCopyWithImpl(this._self, this._then);

  final ProductData _self;
  final $Res Function(ProductData) _then;

/// Create a copy of ProductData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channel3ProductId = freezed,Object? name = null,Object? price = freezed,Object? currency = freezed,Object? merchant = freezed,Object? sourceUrl = freezed,Object? imageUrl = freezed,Object? specs = freezed,Object? retrievedAt = freezed,}) {
  return _then(ProductData(
channel3ProductId: freezed == channel3ProductId ? _self.channel3ProductId : channel3ProductId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,specs: freezed == specs ? _self.specs : specs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,retrievedAt: freezed == retrievedAt ? _self.retrievedAt : retrievedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductData].
extension ProductDataPatterns on ProductData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductData value)  $default,){
final _that = this;
switch (_that) {
case _ProductData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductData value)?  $default,){
final _that = this;
switch (_that) {
case _ProductData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'channel3_product_id')  String? channel3ProductId,  String name,  double? price,  String? currency,  String? merchant, @JsonKey(name: 'source_url')  String? sourceUrl, @JsonKey(name: 'image_url')  String? imageUrl,  Map<String, dynamic>? specs, @JsonKey(name: 'retrieved_at')  String? retrievedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductData() when $default != null:
return $default(_that.channel3ProductId,_that.name,_that.price,_that.currency,_that.merchant,_that.sourceUrl,_that.imageUrl,_that.specs,_that.retrievedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'channel3_product_id')  String? channel3ProductId,  String name,  double? price,  String? currency,  String? merchant, @JsonKey(name: 'source_url')  String? sourceUrl, @JsonKey(name: 'image_url')  String? imageUrl,  Map<String, dynamic>? specs, @JsonKey(name: 'retrieved_at')  String? retrievedAt)  $default,) {final _that = this;
switch (_that) {
case _ProductData():
return $default(_that.channel3ProductId,_that.name,_that.price,_that.currency,_that.merchant,_that.sourceUrl,_that.imageUrl,_that.specs,_that.retrievedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'channel3_product_id')  String? channel3ProductId,  String name,  double? price,  String? currency,  String? merchant, @JsonKey(name: 'source_url')  String? sourceUrl, @JsonKey(name: 'image_url')  String? imageUrl,  Map<String, dynamic>? specs, @JsonKey(name: 'retrieved_at')  String? retrievedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductData() when $default != null:
return $default(_that.channel3ProductId,_that.name,_that.price,_that.currency,_that.merchant,_that.sourceUrl,_that.imageUrl,_that.specs,_that.retrievedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductData implements ProductData {
  const _ProductData({@JsonKey(name: 'channel3_product_id') this.channel3ProductId, required this.name, this.price, this.currency, this.merchant, @JsonKey(name: 'source_url') this.sourceUrl, @JsonKey(name: 'image_url') this.imageUrl,  Map<String, dynamic>? specs, @JsonKey(name: 'retrieved_at') this.retrievedAt}): _specs = specs;
  factory _ProductData.fromJson(Map<String, dynamic> json) => _$ProductDataFromJson(json);

@override@JsonKey(name: 'channel3_product_id') final  String? channel3ProductId;
@override final  String name;
@override final  double? price;
@override final  String? currency;
@override final  String? merchant;
@override@JsonKey(name: 'source_url') final  String? sourceUrl;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
 final  Map<String, dynamic>? _specs;
@override Map<String, dynamic>? get specs {
  final value = _specs;
  if (value == null) return null;
  if (_specs is EqualUnmodifiableMapView) return _specs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'retrieved_at') final  String? retrievedAt;

/// Create a copy of ProductData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductDataCopyWith<_ProductData> get copyWith => __$ProductDataCopyWithImpl<_ProductData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductData&&(identical(other.channel3ProductId, channel3ProductId) || other.channel3ProductId == channel3ProductId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.specs, _specs)&&(identical(other.retrievedAt, retrievedAt) || other.retrievedAt == retrievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,channel3ProductId,name,price,currency,merchant,sourceUrl,imageUrl,const DeepCollectionEquality().hash(_specs),retrievedAt);
}

@override
String toString() {
    return 'ProductData(channel3ProductId: $channel3ProductId, name: $name, price: $price, currency: $currency, merchant: $merchant, sourceUrl: $sourceUrl, imageUrl: $imageUrl, specs: $specs, retrievedAt: $retrievedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductDataCopyWith<$Res> implements $ProductDataCopyWith<$Res> {
  factory _$ProductDataCopyWith(_ProductData value, $Res Function(_ProductData) _then) = __$ProductDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'channel3_product_id') String? channel3ProductId, String name, double? price, String? currency, String? merchant,@JsonKey(name: 'source_url') String? sourceUrl,@JsonKey(name: 'image_url') String? imageUrl, Map<String, dynamic>? specs,@JsonKey(name: 'retrieved_at') String? retrievedAt
});




}
/// @nodoc
class __$ProductDataCopyWithImpl<$Res>
    implements _$ProductDataCopyWith<$Res> {
  __$ProductDataCopyWithImpl(this._self, this._then);

  final _ProductData _self;
  final $Res Function(_ProductData) _then;

/// Create a copy of ProductData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channel3ProductId = freezed,Object? name = null,Object? price = freezed,Object? currency = freezed,Object? merchant = freezed,Object? sourceUrl = freezed,Object? imageUrl = freezed,Object? specs = freezed,Object? retrievedAt = freezed,}) {
  return _then(_ProductData(
channel3ProductId: freezed == channel3ProductId ? _self.channel3ProductId : channel3ProductId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,specs: freezed == specs ? _self._specs : specs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,retrievedAt: freezed == retrievedAt ? _self.retrievedAt : retrievedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RankedProduct {

@JsonKey(name: 'product') ProductData get productData;@JsonKey(name: 'constraint_results') Map<String, String> get constraintResults;@JsonKey(name: 'ranking_score') double get rankingScore;@JsonKey(name: 'ranking_confidence') double get rankingConfidence; String? get explanation;@JsonKey(name: 'id') String? get productResultId;
/// Create a copy of RankedProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankedProductCopyWith<RankedProduct> get copyWith => _$RankedProductCopyWithImpl<RankedProduct>(this as RankedProduct, _$identity);

  /// Serializes this RankedProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RankedProduct;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankedProduct&&(identical(other.productData, _this.productData) || other.productData == _this.productData)&&const DeepCollectionEquality().equals(other.constraintResults, _this.constraintResults)&&(identical(other.rankingScore, _this.rankingScore) || other.rankingScore == _this.rankingScore)&&(identical(other.rankingConfidence, _this.rankingConfidence) || other.rankingConfidence == _this.rankingConfidence)&&(identical(other.explanation, _this.explanation) || other.explanation == _this.explanation)&&(identical(other.productResultId, _this.productResultId) || other.productResultId == _this.productResultId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RankedProduct;
  return Object.hash(runtimeType,_this.productData,const DeepCollectionEquality().hash(_this.constraintResults),_this.rankingScore,_this.rankingConfidence,_this.explanation,_this.productResultId);
}

@override
String toString() {
  final _this = this as RankedProduct;
  return 'RankedProduct(productData: ${_this.productData}, constraintResults: ${_this.constraintResults}, rankingScore: ${_this.rankingScore}, rankingConfidence: ${_this.rankingConfidence}, explanation: ${_this.explanation}, productResultId: ${_this.productResultId})';
}


}

/// @nodoc
abstract mixin class $RankedProductCopyWith<$Res>  {
  factory $RankedProductCopyWith(RankedProduct value, $Res Function(RankedProduct) _then) = _$RankedProductCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'product') ProductData productData,@JsonKey(name: 'constraint_results') Map<String, String> constraintResults,@JsonKey(name: 'ranking_score') double rankingScore,@JsonKey(name: 'ranking_confidence') double rankingConfidence, String? explanation,@JsonKey(name: 'id') String? productResultId
});


$ProductDataCopyWith<$Res> get productData;

}
/// @nodoc
class _$RankedProductCopyWithImpl<$Res>
    implements $RankedProductCopyWith<$Res> {
  _$RankedProductCopyWithImpl(this._self, this._then);

  final RankedProduct _self;
  final $Res Function(RankedProduct) _then;

/// Create a copy of RankedProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productData = null,Object? constraintResults = null,Object? rankingScore = null,Object? rankingConfidence = null,Object? explanation = freezed,Object? productResultId = freezed,}) {
  return _then(RankedProduct(
productData: null == productData ? _self.productData : productData // ignore: cast_nullable_to_non_nullable
as ProductData,constraintResults: null == constraintResults ? _self.constraintResults : constraintResults // ignore: cast_nullable_to_non_nullable
as Map<String, String>,rankingScore: null == rankingScore ? _self.rankingScore : rankingScore // ignore: cast_nullable_to_non_nullable
as double,rankingConfidence: null == rankingConfidence ? _self.rankingConfidence : rankingConfidence // ignore: cast_nullable_to_non_nullable
as double,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,productResultId: freezed == productResultId ? _self.productResultId : productResultId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RankedProduct
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductDataCopyWith<$Res> get productData {
  
  return $ProductDataCopyWith<$Res>(_self.productData, (value) {
    return _then(_self.copyWith(productData: value));
  });
}
}


/// Adds pattern-matching-related methods to [RankedProduct].
extension RankedProductPatterns on RankedProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankedProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankedProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankedProduct value)  $default,){
final _that = this;
switch (_that) {
case _RankedProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankedProduct value)?  $default,){
final _that = this;
switch (_that) {
case _RankedProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'product')  ProductData productData, @JsonKey(name: 'constraint_results')  Map<String, String> constraintResults, @JsonKey(name: 'ranking_score')  double rankingScore, @JsonKey(name: 'ranking_confidence')  double rankingConfidence,  String? explanation, @JsonKey(name: 'id')  String? productResultId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankedProduct() when $default != null:
return $default(_that.productData,_that.constraintResults,_that.rankingScore,_that.rankingConfidence,_that.explanation,_that.productResultId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'product')  ProductData productData, @JsonKey(name: 'constraint_results')  Map<String, String> constraintResults, @JsonKey(name: 'ranking_score')  double rankingScore, @JsonKey(name: 'ranking_confidence')  double rankingConfidence,  String? explanation, @JsonKey(name: 'id')  String? productResultId)  $default,) {final _that = this;
switch (_that) {
case _RankedProduct():
return $default(_that.productData,_that.constraintResults,_that.rankingScore,_that.rankingConfidence,_that.explanation,_that.productResultId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'product')  ProductData productData, @JsonKey(name: 'constraint_results')  Map<String, String> constraintResults, @JsonKey(name: 'ranking_score')  double rankingScore, @JsonKey(name: 'ranking_confidence')  double rankingConfidence,  String? explanation, @JsonKey(name: 'id')  String? productResultId)?  $default,) {final _that = this;
switch (_that) {
case _RankedProduct() when $default != null:
return $default(_that.productData,_that.constraintResults,_that.rankingScore,_that.rankingConfidence,_that.explanation,_that.productResultId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankedProduct implements RankedProduct {
  const _RankedProduct({@JsonKey(name: 'product') required this.productData, @JsonKey(name: 'constraint_results') required  Map<String, String> constraintResults, @JsonKey(name: 'ranking_score') required this.rankingScore, @JsonKey(name: 'ranking_confidence') required this.rankingConfidence, this.explanation, @JsonKey(name: 'id') this.productResultId}): _constraintResults = constraintResults;
  factory _RankedProduct.fromJson(Map<String, dynamic> json) => _$RankedProductFromJson(json);

@override@JsonKey(name: 'product') final  ProductData productData;
 final  Map<String, String> _constraintResults;
@override@JsonKey(name: 'constraint_results') Map<String, String> get constraintResults {
  if (_constraintResults is EqualUnmodifiableMapView) return _constraintResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_constraintResults);
}

@override@JsonKey(name: 'ranking_score') final  double rankingScore;
@override@JsonKey(name: 'ranking_confidence') final  double rankingConfidence;
@override final  String? explanation;
@override@JsonKey(name: 'id') final  String? productResultId;

/// Create a copy of RankedProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankedProductCopyWith<_RankedProduct> get copyWith => __$RankedProductCopyWithImpl<_RankedProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankedProductToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankedProduct&&(identical(other.productData, productData) || other.productData == productData)&&const DeepCollectionEquality().equals(other.constraintResults, _constraintResults)&&(identical(other.rankingScore, rankingScore) || other.rankingScore == rankingScore)&&(identical(other.rankingConfidence, rankingConfidence) || other.rankingConfidence == rankingConfidence)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.productResultId, productResultId) || other.productResultId == productResultId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,productData,const DeepCollectionEquality().hash(_constraintResults),rankingScore,rankingConfidence,explanation,productResultId);
}

@override
String toString() {
    return 'RankedProduct(productData: $productData, constraintResults: $constraintResults, rankingScore: $rankingScore, rankingConfidence: $rankingConfidence, explanation: $explanation, productResultId: $productResultId)';
}


}

/// @nodoc
abstract mixin class _$RankedProductCopyWith<$Res> implements $RankedProductCopyWith<$Res> {
  factory _$RankedProductCopyWith(_RankedProduct value, $Res Function(_RankedProduct) _then) = __$RankedProductCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'product') ProductData productData,@JsonKey(name: 'constraint_results') Map<String, String> constraintResults,@JsonKey(name: 'ranking_score') double rankingScore,@JsonKey(name: 'ranking_confidence') double rankingConfidence, String? explanation,@JsonKey(name: 'id') String? productResultId
});


@override $ProductDataCopyWith<$Res> get productData;

}
/// @nodoc
class __$RankedProductCopyWithImpl<$Res>
    implements _$RankedProductCopyWith<$Res> {
  __$RankedProductCopyWithImpl(this._self, this._then);

  final _RankedProduct _self;
  final $Res Function(_RankedProduct) _then;

/// Create a copy of RankedProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productData = null,Object? constraintResults = null,Object? rankingScore = null,Object? rankingConfidence = null,Object? explanation = freezed,Object? productResultId = freezed,}) {
  return _then(_RankedProduct(
productData: null == productData ? _self.productData : productData // ignore: cast_nullable_to_non_nullable
as ProductData,constraintResults: null == constraintResults ? _self._constraintResults : constraintResults // ignore: cast_nullable_to_non_nullable
as Map<String, String>,rankingScore: null == rankingScore ? _self.rankingScore : rankingScore // ignore: cast_nullable_to_non_nullable
as double,rankingConfidence: null == rankingConfidence ? _self.rankingConfidence : rankingConfidence // ignore: cast_nullable_to_non_nullable
as double,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,productResultId: freezed == productResultId ? _self.productResultId : productResultId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RankedProduct
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductDataCopyWith<$Res> get productData {
  
  return $ProductDataCopyWith<$Res>(_self.productData, (value) {
    return _then(_self.copyWith(productData: value));
  });
}
}

// dart format on
