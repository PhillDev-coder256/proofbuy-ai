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
mixin _$ProductImage {

 String get url;@JsonKey(name: 'cleaned_url') String? get cleanedUrl;@JsonKey(name: 'is_main_image') bool get isMainImage;@JsonKey(name: 'shot_type') String? get shotType;@JsonKey(name: 'alt_text') String? get altText;
/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductImageCopyWith<ProductImage> get copyWith => _$ProductImageCopyWithImpl<ProductImage>(this as ProductImage, _$identity);

  /// Serializes this ProductImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductImage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductImage&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.cleanedUrl, _this.cleanedUrl) || other.cleanedUrl == _this.cleanedUrl)&&(identical(other.isMainImage, _this.isMainImage) || other.isMainImage == _this.isMainImage)&&(identical(other.shotType, _this.shotType) || other.shotType == _this.shotType)&&(identical(other.altText, _this.altText) || other.altText == _this.altText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductImage;
  return Object.hash(runtimeType,_this.url,_this.cleanedUrl,_this.isMainImage,_this.shotType,_this.altText);
}

@override
String toString() {
  final _this = this as ProductImage;
  return 'ProductImage(url: ${_this.url}, cleanedUrl: ${_this.cleanedUrl}, isMainImage: ${_this.isMainImage}, shotType: ${_this.shotType}, altText: ${_this.altText})';
}


}

/// @nodoc
abstract mixin class $ProductImageCopyWith<$Res>  {
  factory $ProductImageCopyWith(ProductImage value, $Res Function(ProductImage) _then) = _$ProductImageCopyWithImpl;
@useResult
$Res call({
 String url,@JsonKey(name: 'cleaned_url') String? cleanedUrl,@JsonKey(name: 'is_main_image') bool isMainImage,@JsonKey(name: 'shot_type') String? shotType,@JsonKey(name: 'alt_text') String? altText
});




}
/// @nodoc
class _$ProductImageCopyWithImpl<$Res>
    implements $ProductImageCopyWith<$Res> {
  _$ProductImageCopyWithImpl(this._self, this._then);

  final ProductImage _self;
  final $Res Function(ProductImage) _then;

/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? cleanedUrl = freezed,Object? isMainImage = null,Object? shotType = freezed,Object? altText = freezed,}) {
  return _then(ProductImage(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,cleanedUrl: freezed == cleanedUrl ? _self.cleanedUrl : cleanedUrl // ignore: cast_nullable_to_non_nullable
as String?,isMainImage: null == isMainImage ? _self.isMainImage : isMainImage // ignore: cast_nullable_to_non_nullable
as bool,shotType: freezed == shotType ? _self.shotType : shotType // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductImage].
extension ProductImagePatterns on ProductImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductImage value)  $default,){
final _that = this;
switch (_that) {
case _ProductImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductImage value)?  $default,){
final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'cleaned_url')  String? cleanedUrl, @JsonKey(name: 'is_main_image')  bool isMainImage, @JsonKey(name: 'shot_type')  String? shotType, @JsonKey(name: 'alt_text')  String? altText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
return $default(_that.url,_that.cleanedUrl,_that.isMainImage,_that.shotType,_that.altText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'cleaned_url')  String? cleanedUrl, @JsonKey(name: 'is_main_image')  bool isMainImage, @JsonKey(name: 'shot_type')  String? shotType, @JsonKey(name: 'alt_text')  String? altText)  $default,) {final _that = this;
switch (_that) {
case _ProductImage():
return $default(_that.url,_that.cleanedUrl,_that.isMainImage,_that.shotType,_that.altText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url, @JsonKey(name: 'cleaned_url')  String? cleanedUrl, @JsonKey(name: 'is_main_image')  bool isMainImage, @JsonKey(name: 'shot_type')  String? shotType, @JsonKey(name: 'alt_text')  String? altText)?  $default,) {final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
return $default(_that.url,_that.cleanedUrl,_that.isMainImage,_that.shotType,_that.altText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductImage implements ProductImage {
  const _ProductImage({required this.url, @JsonKey(name: 'cleaned_url') this.cleanedUrl, @JsonKey(name: 'is_main_image') this.isMainImage = false, @JsonKey(name: 'shot_type') this.shotType, @JsonKey(name: 'alt_text') this.altText});
  factory _ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);

@override final  String url;
@override@JsonKey(name: 'cleaned_url') final  String? cleanedUrl;
@override@JsonKey(name: 'is_main_image') final  bool isMainImage;
@override@JsonKey(name: 'shot_type') final  String? shotType;
@override@JsonKey(name: 'alt_text') final  String? altText;

/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductImageCopyWith<_ProductImage> get copyWith => __$ProductImageCopyWithImpl<_ProductImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductImageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductImage&&(identical(other.url, url) || other.url == url)&&(identical(other.cleanedUrl, cleanedUrl) || other.cleanedUrl == cleanedUrl)&&(identical(other.isMainImage, isMainImage) || other.isMainImage == isMainImage)&&(identical(other.shotType, shotType) || other.shotType == shotType)&&(identical(other.altText, altText) || other.altText == altText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,cleanedUrl,isMainImage,shotType,altText);
}

@override
String toString() {
    return 'ProductImage(url: $url, cleanedUrl: $cleanedUrl, isMainImage: $isMainImage, shotType: $shotType, altText: $altText)';
}


}

/// @nodoc
abstract mixin class _$ProductImageCopyWith<$Res> implements $ProductImageCopyWith<$Res> {
  factory _$ProductImageCopyWith(_ProductImage value, $Res Function(_ProductImage) _then) = __$ProductImageCopyWithImpl;
@override @useResult
$Res call({
 String url,@JsonKey(name: 'cleaned_url') String? cleanedUrl,@JsonKey(name: 'is_main_image') bool isMainImage,@JsonKey(name: 'shot_type') String? shotType,@JsonKey(name: 'alt_text') String? altText
});




}
/// @nodoc
class __$ProductImageCopyWithImpl<$Res>
    implements _$ProductImageCopyWith<$Res> {
  __$ProductImageCopyWithImpl(this._self, this._then);

  final _ProductImage _self;
  final $Res Function(_ProductImage) _then;

/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? cleanedUrl = freezed,Object? isMainImage = null,Object? shotType = freezed,Object? altText = freezed,}) {
  return _then(_ProductImage(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,cleanedUrl: freezed == cleanedUrl ? _self.cleanedUrl : cleanedUrl // ignore: cast_nullable_to_non_nullable
as String?,isMainImage: null == isMainImage ? _self.isMainImage : isMainImage // ignore: cast_nullable_to_non_nullable
as bool,shotType: freezed == shotType ? _self.shotType : shotType // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductOffer {

 String get url; String get domain; double get price;@JsonKey(name: 'compare_at_price') double? get compareAtPrice; String get currency; String get availability; String? get condition;
/// Create a copy of ProductOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductOfferCopyWith<ProductOffer> get copyWith => _$ProductOfferCopyWithImpl<ProductOffer>(this as ProductOffer, _$identity);

  /// Serializes this ProductOffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductOffer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductOffer&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.domain, _this.domain) || other.domain == _this.domain)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.compareAtPrice, _this.compareAtPrice) || other.compareAtPrice == _this.compareAtPrice)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.condition, _this.condition) || other.condition == _this.condition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductOffer;
  return Object.hash(runtimeType,_this.url,_this.domain,_this.price,_this.compareAtPrice,_this.currency,_this.availability,_this.condition);
}

@override
String toString() {
  final _this = this as ProductOffer;
  return 'ProductOffer(url: ${_this.url}, domain: ${_this.domain}, price: ${_this.price}, compareAtPrice: ${_this.compareAtPrice}, currency: ${_this.currency}, availability: ${_this.availability}, condition: ${_this.condition})';
}


}

/// @nodoc
abstract mixin class $ProductOfferCopyWith<$Res>  {
  factory $ProductOfferCopyWith(ProductOffer value, $Res Function(ProductOffer) _then) = _$ProductOfferCopyWithImpl;
@useResult
$Res call({
 String url, String domain, double price,@JsonKey(name: 'compare_at_price') double? compareAtPrice, String currency, String availability, String? condition
});




}
/// @nodoc
class _$ProductOfferCopyWithImpl<$Res>
    implements $ProductOfferCopyWith<$Res> {
  _$ProductOfferCopyWithImpl(this._self, this._then);

  final ProductOffer _self;
  final $Res Function(ProductOffer) _then;

/// Create a copy of ProductOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? domain = null,Object? price = null,Object? compareAtPrice = freezed,Object? currency = null,Object? availability = null,Object? condition = freezed,}) {
  return _then(ProductOffer(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,compareAtPrice: freezed == compareAtPrice ? _self.compareAtPrice : compareAtPrice // ignore: cast_nullable_to_non_nullable
as double?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as String,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductOffer].
extension ProductOfferPatterns on ProductOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductOffer value)  $default,){
final _that = this;
switch (_that) {
case _ProductOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductOffer value)?  $default,){
final _that = this;
switch (_that) {
case _ProductOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String domain,  double price, @JsonKey(name: 'compare_at_price')  double? compareAtPrice,  String currency,  String availability,  String? condition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductOffer() when $default != null:
return $default(_that.url,_that.domain,_that.price,_that.compareAtPrice,_that.currency,_that.availability,_that.condition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String domain,  double price, @JsonKey(name: 'compare_at_price')  double? compareAtPrice,  String currency,  String availability,  String? condition)  $default,) {final _that = this;
switch (_that) {
case _ProductOffer():
return $default(_that.url,_that.domain,_that.price,_that.compareAtPrice,_that.currency,_that.availability,_that.condition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String domain,  double price, @JsonKey(name: 'compare_at_price')  double? compareAtPrice,  String currency,  String availability,  String? condition)?  $default,) {final _that = this;
switch (_that) {
case _ProductOffer() when $default != null:
return $default(_that.url,_that.domain,_that.price,_that.compareAtPrice,_that.currency,_that.availability,_that.condition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductOffer implements ProductOffer {
  const _ProductOffer({required this.url, required this.domain, required this.price, @JsonKey(name: 'compare_at_price') this.compareAtPrice, required this.currency, required this.availability, this.condition});
  factory _ProductOffer.fromJson(Map<String, dynamic> json) => _$ProductOfferFromJson(json);

@override final  String url;
@override final  String domain;
@override final  double price;
@override@JsonKey(name: 'compare_at_price') final  double? compareAtPrice;
@override final  String currency;
@override final  String availability;
@override final  String? condition;

/// Create a copy of ProductOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductOfferCopyWith<_ProductOffer> get copyWith => __$ProductOfferCopyWithImpl<_ProductOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductOfferToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductOffer&&(identical(other.url, url) || other.url == url)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.price, price) || other.price == price)&&(identical(other.compareAtPrice, compareAtPrice) || other.compareAtPrice == compareAtPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.condition, condition) || other.condition == condition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,domain,price,compareAtPrice,currency,availability,condition);
}

@override
String toString() {
    return 'ProductOffer(url: $url, domain: $domain, price: $price, compareAtPrice: $compareAtPrice, currency: $currency, availability: $availability, condition: $condition)';
}


}

/// @nodoc
abstract mixin class _$ProductOfferCopyWith<$Res> implements $ProductOfferCopyWith<$Res> {
  factory _$ProductOfferCopyWith(_ProductOffer value, $Res Function(_ProductOffer) _then) = __$ProductOfferCopyWithImpl;
@override @useResult
$Res call({
 String url, String domain, double price,@JsonKey(name: 'compare_at_price') double? compareAtPrice, String currency, String availability, String? condition
});




}
/// @nodoc
class __$ProductOfferCopyWithImpl<$Res>
    implements _$ProductOfferCopyWith<$Res> {
  __$ProductOfferCopyWithImpl(this._self, this._then);

  final _ProductOffer _self;
  final $Res Function(_ProductOffer) _then;

/// Create a copy of ProductOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? domain = null,Object? price = null,Object? compareAtPrice = freezed,Object? currency = null,Object? availability = null,Object? condition = freezed,}) {
  return _then(_ProductOffer(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,compareAtPrice: freezed == compareAtPrice ? _self.compareAtPrice : compareAtPrice // ignore: cast_nullable_to_non_nullable
as double?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as String,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductRatings {

 double get value; int get count;@JsonKey(name: 'source_count') int get sourceCount;
/// Create a copy of ProductRatings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductRatingsCopyWith<ProductRatings> get copyWith => _$ProductRatingsCopyWithImpl<ProductRatings>(this as ProductRatings, _$identity);

  /// Serializes this ProductRatings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductRatings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductRatings&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.sourceCount, _this.sourceCount) || other.sourceCount == _this.sourceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductRatings;
  return Object.hash(runtimeType,_this.value,_this.count,_this.sourceCount);
}

@override
String toString() {
  final _this = this as ProductRatings;
  return 'ProductRatings(value: ${_this.value}, count: ${_this.count}, sourceCount: ${_this.sourceCount})';
}


}

/// @nodoc
abstract mixin class $ProductRatingsCopyWith<$Res>  {
  factory $ProductRatingsCopyWith(ProductRatings value, $Res Function(ProductRatings) _then) = _$ProductRatingsCopyWithImpl;
@useResult
$Res call({
 double value, int count,@JsonKey(name: 'source_count') int sourceCount
});




}
/// @nodoc
class _$ProductRatingsCopyWithImpl<$Res>
    implements $ProductRatingsCopyWith<$Res> {
  _$ProductRatingsCopyWithImpl(this._self, this._then);

  final ProductRatings _self;
  final $Res Function(ProductRatings) _then;

/// Create a copy of ProductRatings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? count = null,Object? sourceCount = null,}) {
  return _then(ProductRatings(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,sourceCount: null == sourceCount ? _self.sourceCount : sourceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductRatings].
extension ProductRatingsPatterns on ProductRatings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductRatings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductRatings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductRatings value)  $default,){
final _that = this;
switch (_that) {
case _ProductRatings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductRatings value)?  $default,){
final _that = this;
switch (_that) {
case _ProductRatings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double value,  int count, @JsonKey(name: 'source_count')  int sourceCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductRatings() when $default != null:
return $default(_that.value,_that.count,_that.sourceCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double value,  int count, @JsonKey(name: 'source_count')  int sourceCount)  $default,) {final _that = this;
switch (_that) {
case _ProductRatings():
return $default(_that.value,_that.count,_that.sourceCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double value,  int count, @JsonKey(name: 'source_count')  int sourceCount)?  $default,) {final _that = this;
switch (_that) {
case _ProductRatings() when $default != null:
return $default(_that.value,_that.count,_that.sourceCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductRatings implements ProductRatings {
  const _ProductRatings({required this.value, required this.count, @JsonKey(name: 'source_count') required this.sourceCount});
  factory _ProductRatings.fromJson(Map<String, dynamic> json) => _$ProductRatingsFromJson(json);

@override final  double value;
@override final  int count;
@override@JsonKey(name: 'source_count') final  int sourceCount;

/// Create a copy of ProductRatings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductRatingsCopyWith<_ProductRatings> get copyWith => __$ProductRatingsCopyWithImpl<_ProductRatings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductRatingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductRatings&&(identical(other.value, value) || other.value == value)&&(identical(other.count, count) || other.count == count)&&(identical(other.sourceCount, sourceCount) || other.sourceCount == sourceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,value,count,sourceCount);
}

@override
String toString() {
    return 'ProductRatings(value: $value, count: $count, sourceCount: $sourceCount)';
}


}

/// @nodoc
abstract mixin class _$ProductRatingsCopyWith<$Res> implements $ProductRatingsCopyWith<$Res> {
  factory _$ProductRatingsCopyWith(_ProductRatings value, $Res Function(_ProductRatings) _then) = __$ProductRatingsCopyWithImpl;
@override @useResult
$Res call({
 double value, int count,@JsonKey(name: 'source_count') int sourceCount
});




}
/// @nodoc
class __$ProductRatingsCopyWithImpl<$Res>
    implements _$ProductRatingsCopyWith<$Res> {
  __$ProductRatingsCopyWithImpl(this._self, this._then);

  final _ProductRatings _self;
  final $Res Function(_ProductRatings) _then;

/// Create a copy of ProductRatings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? count = null,Object? sourceCount = null,}) {
  return _then(_ProductRatings(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,sourceCount: null == sourceCount ? _self.sourceCount : sourceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProductData {

@JsonKey(name: 'channel3_product_id') String? get channel3ProductId; String get name; double? get price; String? get currency; String? get merchant;@JsonKey(name: 'source_url') String? get sourceUrl;@JsonKey(name: 'image_url') String? get imageUrl; Map<String, dynamic>? get specs;@JsonKey(name: 'retrieved_at') String? get retrievedAt;@JsonKey(name: 'all_images') List<ProductImage> get allImages;@JsonKey(name: 'all_offers') List<ProductOffer> get allOffers; ProductRatings? get ratings; List<String>? get materials;@JsonKey(name: 'key_features') List<String>? get keyFeatures;@JsonKey(name: 'structured_attributes') Map<String, dynamic>? get structuredAttributes;@JsonKey(name: 'category_title') String? get categoryTitle; String? get description;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductData&&(identical(other.channel3ProductId, _this.channel3ProductId) || other.channel3ProductId == _this.channel3ProductId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.merchant, _this.merchant) || other.merchant == _this.merchant)&&(identical(other.sourceUrl, _this.sourceUrl) || other.sourceUrl == _this.sourceUrl)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&const DeepCollectionEquality().equals(other.specs, _this.specs)&&(identical(other.retrievedAt, _this.retrievedAt) || other.retrievedAt == _this.retrievedAt)&&const DeepCollectionEquality().equals(other.allImages, _this.allImages)&&const DeepCollectionEquality().equals(other.allOffers, _this.allOffers)&&(identical(other.ratings, _this.ratings) || other.ratings == _this.ratings)&&const DeepCollectionEquality().equals(other.materials, _this.materials)&&const DeepCollectionEquality().equals(other.keyFeatures, _this.keyFeatures)&&const DeepCollectionEquality().equals(other.structuredAttributes, _this.structuredAttributes)&&(identical(other.categoryTitle, _this.categoryTitle) || other.categoryTitle == _this.categoryTitle)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductData;
  return Object.hash(runtimeType,_this.channel3ProductId,_this.name,_this.price,_this.currency,_this.merchant,_this.sourceUrl,_this.imageUrl,const DeepCollectionEquality().hash(_this.specs),_this.retrievedAt,const DeepCollectionEquality().hash(_this.allImages),const DeepCollectionEquality().hash(_this.allOffers),_this.ratings,const DeepCollectionEquality().hash(_this.materials),const DeepCollectionEquality().hash(_this.keyFeatures),const DeepCollectionEquality().hash(_this.structuredAttributes),_this.categoryTitle,_this.description);
}

@override
String toString() {
  final _this = this as ProductData;
  return 'ProductData(channel3ProductId: ${_this.channel3ProductId}, name: ${_this.name}, price: ${_this.price}, currency: ${_this.currency}, merchant: ${_this.merchant}, sourceUrl: ${_this.sourceUrl}, imageUrl: ${_this.imageUrl}, specs: ${_this.specs}, retrievedAt: ${_this.retrievedAt}, allImages: ${_this.allImages}, allOffers: ${_this.allOffers}, ratings: ${_this.ratings}, materials: ${_this.materials}, keyFeatures: ${_this.keyFeatures}, structuredAttributes: ${_this.structuredAttributes}, categoryTitle: ${_this.categoryTitle}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $ProductDataCopyWith<$Res>  {
  factory $ProductDataCopyWith(ProductData value, $Res Function(ProductData) _then) = _$ProductDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'channel3_product_id') String? channel3ProductId, String name, double? price, String? currency, String? merchant,@JsonKey(name: 'source_url') String? sourceUrl,@JsonKey(name: 'image_url') String? imageUrl, Map<String, dynamic>? specs,@JsonKey(name: 'retrieved_at') String? retrievedAt,@JsonKey(name: 'all_images') List<ProductImage> allImages,@JsonKey(name: 'all_offers') List<ProductOffer> allOffers, ProductRatings? ratings, List<String>? materials,@JsonKey(name: 'key_features') List<String>? keyFeatures,@JsonKey(name: 'structured_attributes') Map<String, dynamic>? structuredAttributes,@JsonKey(name: 'category_title') String? categoryTitle, String? description
});


$ProductRatingsCopyWith<$Res>? get ratings;

}
/// @nodoc
class _$ProductDataCopyWithImpl<$Res>
    implements $ProductDataCopyWith<$Res> {
  _$ProductDataCopyWithImpl(this._self, this._then);

  final ProductData _self;
  final $Res Function(ProductData) _then;

/// Create a copy of ProductData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channel3ProductId = freezed,Object? name = null,Object? price = freezed,Object? currency = freezed,Object? merchant = freezed,Object? sourceUrl = freezed,Object? imageUrl = freezed,Object? specs = freezed,Object? retrievedAt = freezed,Object? allImages = null,Object? allOffers = null,Object? ratings = freezed,Object? materials = freezed,Object? keyFeatures = freezed,Object? structuredAttributes = freezed,Object? categoryTitle = freezed,Object? description = freezed,}) {
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
as String?,allImages: null == allImages ? _self.allImages : allImages // ignore: cast_nullable_to_non_nullable
as List<ProductImage>,allOffers: null == allOffers ? _self.allOffers : allOffers // ignore: cast_nullable_to_non_nullable
as List<ProductOffer>,ratings: freezed == ratings ? _self.ratings : ratings // ignore: cast_nullable_to_non_nullable
as ProductRatings?,materials: freezed == materials ? _self.materials : materials // ignore: cast_nullable_to_non_nullable
as List<String>?,keyFeatures: freezed == keyFeatures ? _self.keyFeatures : keyFeatures // ignore: cast_nullable_to_non_nullable
as List<String>?,structuredAttributes: freezed == structuredAttributes ? _self.structuredAttributes : structuredAttributes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,categoryTitle: freezed == categoryTitle ? _self.categoryTitle : categoryTitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ProductData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRatingsCopyWith<$Res>? get ratings {
    if (_self.ratings == null) {
    return null;
  }

  return $ProductRatingsCopyWith<$Res>(_self.ratings!, (value) {
    return _then(_self.copyWith(ratings: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'channel3_product_id')  String? channel3ProductId,  String name,  double? price,  String? currency,  String? merchant, @JsonKey(name: 'source_url')  String? sourceUrl, @JsonKey(name: 'image_url')  String? imageUrl,  Map<String, dynamic>? specs, @JsonKey(name: 'retrieved_at')  String? retrievedAt, @JsonKey(name: 'all_images')  List<ProductImage> allImages, @JsonKey(name: 'all_offers')  List<ProductOffer> allOffers,  ProductRatings? ratings,  List<String>? materials, @JsonKey(name: 'key_features')  List<String>? keyFeatures, @JsonKey(name: 'structured_attributes')  Map<String, dynamic>? structuredAttributes, @JsonKey(name: 'category_title')  String? categoryTitle,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductData() when $default != null:
return $default(_that.channel3ProductId,_that.name,_that.price,_that.currency,_that.merchant,_that.sourceUrl,_that.imageUrl,_that.specs,_that.retrievedAt,_that.allImages,_that.allOffers,_that.ratings,_that.materials,_that.keyFeatures,_that.structuredAttributes,_that.categoryTitle,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'channel3_product_id')  String? channel3ProductId,  String name,  double? price,  String? currency,  String? merchant, @JsonKey(name: 'source_url')  String? sourceUrl, @JsonKey(name: 'image_url')  String? imageUrl,  Map<String, dynamic>? specs, @JsonKey(name: 'retrieved_at')  String? retrievedAt, @JsonKey(name: 'all_images')  List<ProductImage> allImages, @JsonKey(name: 'all_offers')  List<ProductOffer> allOffers,  ProductRatings? ratings,  List<String>? materials, @JsonKey(name: 'key_features')  List<String>? keyFeatures, @JsonKey(name: 'structured_attributes')  Map<String, dynamic>? structuredAttributes, @JsonKey(name: 'category_title')  String? categoryTitle,  String? description)  $default,) {final _that = this;
switch (_that) {
case _ProductData():
return $default(_that.channel3ProductId,_that.name,_that.price,_that.currency,_that.merchant,_that.sourceUrl,_that.imageUrl,_that.specs,_that.retrievedAt,_that.allImages,_that.allOffers,_that.ratings,_that.materials,_that.keyFeatures,_that.structuredAttributes,_that.categoryTitle,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'channel3_product_id')  String? channel3ProductId,  String name,  double? price,  String? currency,  String? merchant, @JsonKey(name: 'source_url')  String? sourceUrl, @JsonKey(name: 'image_url')  String? imageUrl,  Map<String, dynamic>? specs, @JsonKey(name: 'retrieved_at')  String? retrievedAt, @JsonKey(name: 'all_images')  List<ProductImage> allImages, @JsonKey(name: 'all_offers')  List<ProductOffer> allOffers,  ProductRatings? ratings,  List<String>? materials, @JsonKey(name: 'key_features')  List<String>? keyFeatures, @JsonKey(name: 'structured_attributes')  Map<String, dynamic>? structuredAttributes, @JsonKey(name: 'category_title')  String? categoryTitle,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _ProductData() when $default != null:
return $default(_that.channel3ProductId,_that.name,_that.price,_that.currency,_that.merchant,_that.sourceUrl,_that.imageUrl,_that.specs,_that.retrievedAt,_that.allImages,_that.allOffers,_that.ratings,_that.materials,_that.keyFeatures,_that.structuredAttributes,_that.categoryTitle,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductData implements ProductData {
  const _ProductData({@JsonKey(name: 'channel3_product_id') this.channel3ProductId, required this.name, this.price, this.currency, this.merchant, @JsonKey(name: 'source_url') this.sourceUrl, @JsonKey(name: 'image_url') this.imageUrl,  Map<String, dynamic>? specs, @JsonKey(name: 'retrieved_at') this.retrievedAt, @JsonKey(name: 'all_images')  List<ProductImage> allImages = const [], @JsonKey(name: 'all_offers')  List<ProductOffer> allOffers = const [], this.ratings,  List<String>? materials, @JsonKey(name: 'key_features')  List<String>? keyFeatures, @JsonKey(name: 'structured_attributes')  Map<String, dynamic>? structuredAttributes, @JsonKey(name: 'category_title') this.categoryTitle, this.description}): _specs = specs,_allImages = allImages,_allOffers = allOffers,_materials = materials,_keyFeatures = keyFeatures,_structuredAttributes = structuredAttributes;
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
 final  List<ProductImage> _allImages;
@override@JsonKey(name: 'all_images') List<ProductImage> get allImages {
  if (_allImages is EqualUnmodifiableListView) return _allImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allImages);
}

 final  List<ProductOffer> _allOffers;
@override@JsonKey(name: 'all_offers') List<ProductOffer> get allOffers {
  if (_allOffers is EqualUnmodifiableListView) return _allOffers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allOffers);
}

@override final  ProductRatings? ratings;
 final  List<String>? _materials;
@override List<String>? get materials {
  final value = _materials;
  if (value == null) return null;
  if (_materials is EqualUnmodifiableListView) return _materials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _keyFeatures;
@override@JsonKey(name: 'key_features') List<String>? get keyFeatures {
  final value = _keyFeatures;
  if (value == null) return null;
  if (_keyFeatures is EqualUnmodifiableListView) return _keyFeatures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _structuredAttributes;
@override@JsonKey(name: 'structured_attributes') Map<String, dynamic>? get structuredAttributes {
  final value = _structuredAttributes;
  if (value == null) return null;
  if (_structuredAttributes is EqualUnmodifiableMapView) return _structuredAttributes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'category_title') final  String? categoryTitle;
@override final  String? description;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductData&&(identical(other.channel3ProductId, channel3ProductId) || other.channel3ProductId == channel3ProductId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.specs, _specs)&&(identical(other.retrievedAt, retrievedAt) || other.retrievedAt == retrievedAt)&&const DeepCollectionEquality().equals(other.allImages, _allImages)&&const DeepCollectionEquality().equals(other.allOffers, _allOffers)&&(identical(other.ratings, ratings) || other.ratings == ratings)&&const DeepCollectionEquality().equals(other.materials, _materials)&&const DeepCollectionEquality().equals(other.keyFeatures, _keyFeatures)&&const DeepCollectionEquality().equals(other.structuredAttributes, _structuredAttributes)&&(identical(other.categoryTitle, categoryTitle) || other.categoryTitle == categoryTitle)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,channel3ProductId,name,price,currency,merchant,sourceUrl,imageUrl,const DeepCollectionEquality().hash(_specs),retrievedAt,const DeepCollectionEquality().hash(_allImages),const DeepCollectionEquality().hash(_allOffers),ratings,const DeepCollectionEquality().hash(_materials),const DeepCollectionEquality().hash(_keyFeatures),const DeepCollectionEquality().hash(_structuredAttributes),categoryTitle,description);
}

@override
String toString() {
    return 'ProductData(channel3ProductId: $channel3ProductId, name: $name, price: $price, currency: $currency, merchant: $merchant, sourceUrl: $sourceUrl, imageUrl: $imageUrl, specs: $specs, retrievedAt: $retrievedAt, allImages: $allImages, allOffers: $allOffers, ratings: $ratings, materials: $materials, keyFeatures: $keyFeatures, structuredAttributes: $structuredAttributes, categoryTitle: $categoryTitle, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ProductDataCopyWith<$Res> implements $ProductDataCopyWith<$Res> {
  factory _$ProductDataCopyWith(_ProductData value, $Res Function(_ProductData) _then) = __$ProductDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'channel3_product_id') String? channel3ProductId, String name, double? price, String? currency, String? merchant,@JsonKey(name: 'source_url') String? sourceUrl,@JsonKey(name: 'image_url') String? imageUrl, Map<String, dynamic>? specs,@JsonKey(name: 'retrieved_at') String? retrievedAt,@JsonKey(name: 'all_images') List<ProductImage> allImages,@JsonKey(name: 'all_offers') List<ProductOffer> allOffers, ProductRatings? ratings, List<String>? materials,@JsonKey(name: 'key_features') List<String>? keyFeatures,@JsonKey(name: 'structured_attributes') Map<String, dynamic>? structuredAttributes,@JsonKey(name: 'category_title') String? categoryTitle, String? description
});


@override $ProductRatingsCopyWith<$Res>? get ratings;

}
/// @nodoc
class __$ProductDataCopyWithImpl<$Res>
    implements _$ProductDataCopyWith<$Res> {
  __$ProductDataCopyWithImpl(this._self, this._then);

  final _ProductData _self;
  final $Res Function(_ProductData) _then;

/// Create a copy of ProductData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channel3ProductId = freezed,Object? name = null,Object? price = freezed,Object? currency = freezed,Object? merchant = freezed,Object? sourceUrl = freezed,Object? imageUrl = freezed,Object? specs = freezed,Object? retrievedAt = freezed,Object? allImages = null,Object? allOffers = null,Object? ratings = freezed,Object? materials = freezed,Object? keyFeatures = freezed,Object? structuredAttributes = freezed,Object? categoryTitle = freezed,Object? description = freezed,}) {
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
as String?,allImages: null == allImages ? _self._allImages : allImages // ignore: cast_nullable_to_non_nullable
as List<ProductImage>,allOffers: null == allOffers ? _self._allOffers : allOffers // ignore: cast_nullable_to_non_nullable
as List<ProductOffer>,ratings: freezed == ratings ? _self.ratings : ratings // ignore: cast_nullable_to_non_nullable
as ProductRatings?,materials: freezed == materials ? _self._materials : materials // ignore: cast_nullable_to_non_nullable
as List<String>?,keyFeatures: freezed == keyFeatures ? _self._keyFeatures : keyFeatures // ignore: cast_nullable_to_non_nullable
as List<String>?,structuredAttributes: freezed == structuredAttributes ? _self._structuredAttributes : structuredAttributes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,categoryTitle: freezed == categoryTitle ? _self.categoryTitle : categoryTitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProductData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRatingsCopyWith<$Res>? get ratings {
    if (_self.ratings == null) {
    return null;
  }

  return $ProductRatingsCopyWith<$Res>(_self.ratings!, (value) {
    return _then(_self.copyWith(ratings: value));
  });
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
